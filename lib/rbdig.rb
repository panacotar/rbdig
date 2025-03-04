module RbDig
  class DNSMessageError < StandardError; end
end

require 'rbdig/query'
require 'rbdig/response'
require 'rbdig/reader'
