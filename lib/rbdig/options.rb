class RbDig::Options
  def initialize(argv)
    @argv = argv
  end

  def self.parse(argv)
    options = {}.merge(RbDig::DEFAULTS)
    OptionParser.new do |opts|
      opts.banner = "\nUsage: rbdig.rb [options] [DOMAIN] [#{RbDig::QUERY_TYPES.keys.join('|')}]"

      opts.separator ''
      opts.separator 'Specific options:'
      opts.on('-a [SERVER]', '--at [SERVER]',
              "Specify the DNS server to query, example: rbdig.rb -a 8.8.8.8 example.com (default: #{RbDig::ROOT_DNS_SERVER})") do |s|
        options[:dns_server] = s
        options[:recursive] = false
      end
      opts.on('-s', '--short', 'Return only the found IP address (Default: false)') do
        options[:print] = 1
      end
      opts.on('-n', '--noall', 'Clears all displayed flags (Default: all)') do
        options[:print] = 2
      end
      opts.on('-t', '--trace',
              'Enable tracing, showing the iterative queries, disabled when --at specified (Default: false)') do
        options[:trace] = true
      end

      opts.separator ''
      opts.separator 'Common options:'

      opts.on_tail('--version', 'Show version') do
        puts RbDig::VERSION
        exit
      end
    end.parse!(argv)
    domain, q_type = ARGV
    validate(domain, q_type)
    options[:q_type] = RbDig::QUERY_TYPES[q_type] unless q_type.nil?
    options
  end

  def self.validate(domain, q_type)
    domain_regex = /\A(?=.{1,253}\z)(?:(?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6}\z/
    raise ArgumentError, "Invalid domain: #{domain}" unless domain =~ domain_regex

    return unless q_type

    raise ArgumentError, "Invalid/unsupported query type: #{q_type}" if RbDig::QUERY_TYPES[q_type].nil?
  end

  def valid_domain?(domain); end
end
