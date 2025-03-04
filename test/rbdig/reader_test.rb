require 'test_helper'

class ReaderTest < Minitest::Test
  def setup
    @string = 'abcdefghijklmnopqrstuvwxy'
    @default_reader = RbDig::Reader.new(@string)
  end

  def test_return_buffer
    assert_equal @string, @default_reader.buffer
  end

  def test_can_read_one_byte
    assert_equal @string[0], @default_reader.read(1)
    assert_equal 1, @default_reader.pos
  end

  def test_can_read_multiple_bytes
    assert_equal @string[0..1], @default_reader.read(2)
    assert_equal 2, @default_reader.pos
  end

  def test_return_empty_default_read
    assert_equal '', @default_reader.read, "\nIt should return empty string when num bytes not specified"
  end

  def test_return_empty_negative_read
    assert_equal '', @default_reader.read(-1), "\nIt should return empty string reading negative numbers"
  end

  def test_returns_rest_of_buffer
    assert_equal @string, @default_reader.rest
    @default_reader.read(5)
    assert_equal @string[5..], @default_reader.rest
    assert_equal 5, @default_reader.pos
  end
end
