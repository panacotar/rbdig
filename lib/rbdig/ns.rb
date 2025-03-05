require 'socket'

class RbDig::NS
  MAX_LOOKUPS = 15
  ROOT_DNS_SERVER = '199.7.83.42' # l.root-servers.net
  DNS_PORT = 53

  def initialize(trace: true)
    @trace = trace
  end

  def lookup(domain)
    nameserver = ROOT_DNS_SERVER
    query_id = "\x00\x01"
    msg = RbDig::Query.new(query_id).query_message(domain)
    socket_response = connect(msg, nameserver)
    raise 'Invalid response: query Id mismatch' if socket_response[0..1] != query_id

    RbDig::Response.new(socket_response)
  end

  def resolve(domain)
    nameserver = ROOT_DNS_SERVER

    MAX_LOOKUPS.times do
      puts "Querying #{nameserver} for #{domain}" if @trace
      query_id = [rand(65_535)].pack('n')
      msg = RbDig::Query.new(query_id).query_message(domain)
      socket_response = connect(msg, nameserver)
      raise 'Invalid response: query Id mismatch' if socket_response[0..1] != query_id

      dns_response = RbDig::Response.new(socket_response)
      return dns_response.answers[0][:rr_data] if dns_response.answers.any?

      if dns_response.additional.any?
        nameserver = dns_response.additional[0][:rr_data]
        next
      end

      next unless dns_response.authorities.any?

      ns_name = dns_response.authorities[0][:rr_data]
      nameserver = resolve(ns_name)
      next
    end

    raise 'Max lookups reached'
  end

  private

  def connect(message, server = ROOT_DNS_SERVER, port = DNS_PORT)
    socket = UDPSocket.new
    socket.send(message, 0, server, port)
    response, = socket.recvfrom(512)

    socket.close
    response
  end
end
