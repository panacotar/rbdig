require 'socket'
require_relative './lib/reader'
require_relative './lib/message'

DOMAIN = ARGV[0]
# INITIAL_DNS_SERVER = '8.8.8.8'
ROOT_DNS_SERVER = '199.7.83.42' # l.root-servers.net
DNS_PORT = 53
MAX_LOOKUPS = 15

def connect(message, server = ROOT_DNS_SERVER, port = DNS_PORT)
  socket = UDPSocket.new
  socket.send(message, 0, server, port)
  response, _ = socket.recvfrom(512)

  socket.close
  response
end

# LOOKUP
def lookup(domain)
  nameserver = ROOT_DNS_SERVER

  for i in 1..MAX_LOOKUPS do
    puts "Querying #{nameserver} for #{domain}"
    query_id = [i].pack('n')
    msg = DNSQuery.new(query_id).query_message(domain)
    socket_response = connect(msg, nameserver)
    if socket_response[0..1] != query_id
      p socket_response
      raise "Invalid response"
    end  

    dns_response = DNSResponse.new(socket_response).parse
    if dns_response.answers.any?
      return dns_response.answers[0][:rr_data]
    end

    if dns_response.additional.any?
      nameserver = dns_response.additional[0][:rr_data]
      next
    end

    if dns_response.authorities.any?
      ns_name = dns_response.authorities[0][:rr_data]
      nameserver = lookup(ns_name)
      next
    end
  end

  raise "Max lookups reached"
end

answer = lookup(DOMAIN)
puts "\n###\n\n✅ Found answer: "
puts answer
