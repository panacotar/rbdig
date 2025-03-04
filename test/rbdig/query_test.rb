require 'test_helper'

class QueryTest < Minitest::Test
  def setup
    @query_id = "\xbe\xef".b
    @query_examplecom = RbDig::Query.new(@query_id).query_message('example.com')
    @header = @query_examplecom[0..11]
  end

  def test_assign_default_query_id
    default_query_id = "\x00\x01".b
    q = RbDig::Query.new.query_message('example.com')
    assert_equal default_query_id, q[0..1]
  end

  def test_query_id
    assert_equal @query_id, @query_examplecom[0..1]
  end

  def test_encode_header
    assert [48_879, 0, 1, 0, 0, 0], @header.unpack('n*')
  end

  def test_encode_domain
    encoded_domain = @query_examplecom[12..24]
    assert_equal "\x07\x65\x78\x61\x6d\x70\x6c\x65\x03\x63\x6f\x6d\x00".b, encoded_domain
  end
end
