class RbDig::Response
  attr_reader :header, :body, :answers, :authorities, :additional

  def initialize(dns_reply)
    # byebug
    @buffer = RbDig::Reader.new(dns_reply.b)
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
    q_type = @buffer.read(2).unpack1('n')
    q_class = @buffer.read(2).unpack1('n')
    { question:, q_type:, q_class: }
  end

  def parse_resource_records(num_records)
    num_records.times.collect do
      rr_name = extract_domain_name(@buffer)
      rr_type, rr_class = @buffer.read(4).unpack('n2')
      ttl = @buffer.read(4).unpack1('N')
      rr_data_length = @buffer.read(2).unpack1('n')
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

      if read_length >= 0b11000000
        # Byte is pointer (DNS compression)
        pointing_to = read_length - 0b11000000
        pointing_to += buffer.read(1).bytes.first # Second byte
        raise 'Invalid compression label' if pointing_to < 12 || pointing_to >= 512
        raise 'Non-backward compression pointer' if pointing_to >= buffer.pos - 1

        current_pos = buffer.pos
        buffer.pos = pointing_to
        raise 'Invalid compression label, offset to a pointer' if buffer.rest[0] == "\xc0".b

        domain_labels << extract_domain_name(buffer)
        buffer.pos = current_pos
        break
      else
        domain_labels << buffer.read(read_length)
      end
    end
    domain_labels.join('.')
  end

  def extract_record_data(buffer, type, length)
    if type == 1 # A
      buffer.read(length).unpack('C*').join('.')
    elsif [2, 5].include?(type) # NS || CNAME
      extract_domain_name(buffer)
    else
      buffer.read(length)
    end
  end
end
