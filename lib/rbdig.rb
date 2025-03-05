require 'optparse'

module RbDig
  ROOT_DNS_SERVER = '199.7.83.42' # l.root-servers.net

  QUERY_TYPES = {
    1 => 'A',
    2 => 'NS',
    5 => 'CNAME'
  }

  PRINT_OPTIONS = {
    0 => 'silent',
    1 => 'short',
    2 => 'noall',
    3 => 'all'
  }

  DEFAULTS = {
    port: 53,
    dns_server: ROOT_DNS_SERVER,
    q_type: 'A',
    q_class: 'IN',
    print: 3,
    trace: false,
    recursive: true
  }

  class DNSMessageError < StandardError; end
end

require_relative 'rbdig/reader'
require_relative 'rbdig/options'
require_relative 'rbdig/query'
require_relative 'rbdig/response'
require_relative 'rbdig/resolver'
require_relative 'rbdig/display'
require_relative 'rbdig/version'
