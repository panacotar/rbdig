require 'socket'
require_relative './reader'

INITIAL_DNS_SERVER = '8.8.8.8'
DOMAIN = ARGV[0]
# INITIAL_DNS_SERVER = '8.8.8.8'
ROOT_DNS_SERVER = '199.7.83.42' # l.root-servers.net
DNS_PORT = 53
MAX_LOOKUPS = 15

class DNSQuery
  def initialize(query_id, q_type = "\x00\x01")
    @query_id = query_id 
    @q_type = q_type # The type of query (ex: A, NS, CNAME)
  end

  def query_message(domain)
    (query_header + query_question(domain)).b
  end

  private

  def query_header
    flags = encode_flags
    qd_count = "\x00\x01" # the # of entries in the question section
    an_count = "\x00\x00" # the # of resource records in the answer session
    ns_count = "\x00\x00" # the # of name server resource records (in authority records section)
    ar_count = "\x00\x00" # the # of resource records
    @query_id + flags + qd_count + an_count + ns_count + ar_count
  end

  def query_question(domain)
    question = encode_domain(domain)
    q_class = "\x00\x01"  # The class of query (ex: IN, CS)
    question + @q_type + q_class
  end

  #                                 1  1  1  1  1  1
  #   0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  # |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
  # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  def encode_flags
    # qr = 0b0          # Query (0) or Response (1)
    # opcode = 0b0000   # 4-bit, the kind of query, 0 - a standard query
    # aa = 0b0          # Authoritative Answer
    # tc = 0b0          # TrunCation
    # rd = 0b0          # Recursive Desired
    # ra = 0b0          # Recursive Available
    # z = 0b000         # Reserved (must be 0)
    # rcode = 0b0000    # 4-bit part of response (for error checking)

    "\x00\x00"
  end

  # google.com > 6google3com0 > \x06google\x03com\x00
  def encode_domain(domain)
    enc = domain.strip.split('.').map { |s| [s.length].pack("C") + s }.join
    enc + "\x00"
  end
end

class DNSResponse
  attr_reader :header, :body, :answers, :authorities, :additional
  def initialize(dns_reply)
    @buffer = Reader.new(dns_reply)
    @header = {}
    @body = {}
    @answers = []
    @authorities = []
    @additional = []
  end

  def parse
    @header = parse_header
    @body = parse_body
    @answers = parse_resource_records(@header[:an_count])
    @authorities = parse_resource_records(@header[:ns_count])
    @additional = parse_resource_records(@header[:ar_count])
    self
  end

  private

  def parse_header
    query_id, flags, qd_count, an_count, ns_count, ar_count = @buffer.read(12).unpack('n6')
    { query_id:, flags:, qd_count:, an_count:, ns_count:, ar_count: }
  end

  def parse_body
    question = extract_dns_name(@buffer)
    q_type = @buffer.read(2).unpack('n').first
    q_class = @buffer.read(2).unpack('n').first
    { question:, q_type:, q_class: }
  end

  def parse_resource_records(num_records)
    num_records.times.collect do
      rr_name = extract_dns_name(@buffer)
      rr_type, rr_class = @buffer.read(4).unpack('n2')
      ttl = @buffer.read(4).unpack('N').first
      rr_data_length = @buffer.read(2).unpack('n').first
      rr_data = extract_record_data(@buffer, rr_type, rr_data_length)
      next unless [1, 2, 5].include?(rr_type)
      { rr_name:, rr_type:, rr_class:, ttl:, rr_data_length:, rr_data: }
    end.compact
  end

  # \x03dns\x06google\x03com\x00 > dns.google.com
  # Handle also the DNS message compression cases (the read_length byte is 192 or 11000000)
  def extract_dns_name(buffer)
    domain_parts = []
    loop do
      # Add a check for max loops
      read_length = buffer.read(1).bytes.first
      break if read_length == 0
      if read_length == 0b11000000
        # Byte is pointer (DNS compression)
        pointing_to = buffer.read(1).bytes.first
        current_pos = buffer.pos
        buffer.pos = pointing_to
        domain_parts << extract_dns_name(buffer)
        buffer.pos = current_pos
        break
      else
        domain_parts << buffer.read(read_length)
      end
    end
    domain_parts.join(".")
  end

  def extract_record_data(buffer, type, length)
    if type == 1 # A
      buffer.read(length).unpack('C*').join(".")
    elsif type == 2 || type == 5 # NS || CNAME
      extract_dns_name(buffer)
    else
      buffer.read(length)
    end
  end
end

def connect(message, server = INITIAL_DNS_SERVER, port = DNS_PORT)
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
