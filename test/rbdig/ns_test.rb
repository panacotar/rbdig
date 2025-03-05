require 'test_helper'

class NSTest < Minitest::Test
  SETUP = begin
    @@lookup_result = RbDig::NS.new(trace: false).lookup('example.com')
    @@resolve_result = RbDig::NS.new(trace: false).resolve('example.com')
  end

  def test_resolve
    ips = ['96.7.128.198', '23.192.228.80', '23.215.0.138', '23.192.228.84', '23.215.0.136', '96.7.128.175']
    assert_includes ips, @@resolve_result, 'It should correctly find IP address of example.com'
  end

  def test_lookup
    refute_nil @@lookup_result
  end

  def test_lookup_returns_response_class
    assert_kind_of RbDig::Response, @@lookup_result
  end
end
