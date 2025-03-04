module RbDig
  class DNSMessageError < StandardError; end
end

require_relative 'rbdig/reader'
require_relative 'rbdig/query'
require_relative 'rbdig/response'
