require 'socket'

class RbDig::Resolver
  MAX_LOOKUPS = 10

  def initialize(opts)
    @opts = opts
    @trace = opts[:trace]
    @dns_server = opts[:dns_server]
    @port = opts[:port]
    @q_type = opts[:q_type]
  end

  def query(domain)
    result = if @opts[:recursive]
               lookup(domain)
             else
               server_query(domain)
             end

    RbDig::Display.new(result, @opts).print
    result
  end

  def server_query(domain)
    nameserver = @dns_server
    puts "Querying #{nameserver} for #{domain}" if @trace
    msg = build_message(domain)
    socket_response = connect(msg, nameserver)
    raise 'Invalid response: query Id mismatch' if socket_response[0..1] != msg[0..1]

    RbDig::Response.new(socket_response)
  end

  def lookup(domain)
    nameserver = @dns_server

    MAX_LOOKUPS.times do
      puts "Querying #{nameserver} for #{domain}" if @trace
      msg = build_message(domain)
      socket_response = connect(msg, nameserver)
      raise Resolver::Error, 'Invalid response: query Id mismatch' if socket_response[0..1] != msg[0..1]

      dns_response = RbDig::Response.new(socket_response)
      return dns_response if dns_response.answers.any?

      if dns_response.additional.any?
        nameserver = dns_response.additional[0][:rr_data]
        next
      end

      next unless dns_response.authorities.any?

      ns_name = dns_response.authorities[0][:rr_data]
      nameserver = lookup(ns_name).answers[0][:rr_data]
    end

    raise 'Max lookups reached'
  end

  private

  def build_message(domain)
    query_id = [rand(65_535)].pack('n')
    RbDig::Query.new(query_id, q_type: @q_type).query_message(domain)
  end

  def connect(message, server = @dns_server)
    socket = UDPSocket.new
    socket.send(message, 0, server, @port)
    response, = socket.recvfrom(512)

    socket.close
    response
  end

  class Error < StandardError; end
end
