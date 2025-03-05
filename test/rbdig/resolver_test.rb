require 'test_helper'

class ResolverTest < Minitest::Test
  SETUP = begin
    options = RbDig::DEFAULTS
    options[:print] = 0
    @@server_query_result = RbDig::Resolver.new(options).query('example.com')
    # options[:recursive] = true
    # @@lookup_result = RbDig::Resolver.new(options).query('example.com')
  end

  def test_query
    refute_nil @@server_query_result
  end

  def test_query_returns_response_class
    assert_kind_of RbDig::Response, @@server_query_result
  end
end
