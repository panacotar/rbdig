require_relative './reader'
class DNSQuery
  def initialize(query_id, q_type: "\x00\x01")
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

  # example.com > \x07example\x03com\x00
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
    question = extract_domain_name(@buffer)
    q_type = @buffer.read(2).unpack('n').first
    q_class = @buffer.read(2).unpack('n').first
    { question:, q_type:, q_class: }
  end

  def parse_resource_records(num_records)
    num_records.times.collect do
      rr_name = extract_domain_name(@buffer)
      rr_type, rr_class = @buffer.read(4).unpack('n2')
      ttl = @buffer.read(4).unpack('N').first
      rr_data_length = @buffer.read(2).unpack('n').first
      rr_data = extract_record_data(@buffer, rr_type, rr_data_length)
      next unless [1, 2, 5].include?(rr_type)
      { rr_name:, rr_type:, rr_class:, ttl:, rr_data_length:, rr_data: }
    end.compact
  end

  # \x03www\x07example\03com\x00 > www.example.com
  # Handle also the DNS message compression cases (the read_length byte is 192 or 11000000)
  def extract_domain_name(buffer)
    domain_labels = []
    loop do
      # Add a check for max loops
      read_length = buffer.read(1).bytes.first
      break if read_length == 0
      if read_length == 0b11000000
        # Byte is pointer (DNS compression)
        pointing_to = buffer.read(1).bytes.first
        current_pos = buffer.pos
        buffer.pos = pointing_to
        domain_labels << extract_domain_name(buffer)
        buffer.pos = current_pos
        break
      else
        domain_labels << buffer.read(read_length)
      end
    end
    domain_labels.join(".")
  end

  def extract_record_data(buffer, type, length)
    if type == 1 # A
      buffer.read(length).unpack('C*').join(".")
    elsif type == 2 || type == 5 # NS || CNAME
      extract_domain_name(buffer)
    else
      buffer.read(length)
    end
  end
end
