require 'test_helper'

class ResolverTest < Minitest::Test
  SETUP = begin
    @@query_result = RbDig::Resolver.new(trace: false).query('example.com')
    @@lookup_result = RbDig::Resolver.new(trace: false).lookup('example.com')
  end

  def test_lookup
    ips = ['96.7.128.198', '23.192.228.80', '23.215.0.138', '23.192.228.84', '23.215.0.136', '96.7.128.175']
    assert_includes ips, @@lookup_result, 'It should correctly find IP address of example.com'
  end

  def test_query
    refute_nil @@query_result
  end

  def test_query_returns_response_class
    assert_kind_of RbDig::Response, @@query_result
  end
end
