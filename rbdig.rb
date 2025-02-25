require 'socket'

DOMAIN = "example.com"
INITIAL_DNS_SERVER = '8.8.8.8'
DNS_PORT = 53

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
    # rd = 0b1          # Recursive Desired
    # ra = 0b0          # Recursive Available
    # z = 0b000         # Reserved (must be 0)
    # rcode = 0b0000    # 4-bit part of response (for error checking)

    "\x01\x00" # Standard flag
  end

  # google.com > 6google3com0 > \x06google\x03com\x00
  def encode_domain(domain)
    enc = domain.strip.split('.').map { |s| [s.length].pack("C") + s }.join
    enc + "\x00"
  end
end
