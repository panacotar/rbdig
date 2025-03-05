module RbDig
  QUERY_TYPES = {
    1 => 'A',
    2 => 'NS',
    5 => 'CNAME'
  }
  class DNSMessageError < StandardError; end
end

require_relative 'rbdig/reader'
require_relative 'rbdig/query'
require_relative 'rbdig/response'
require_relative 'rbdig/resolver'
require_relative 'rbdig/display'
