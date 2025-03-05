require 'test_helper'

class OptionTest < Minitest::Test
  def setup
    @original_argv = ARGV.dup
  end

  def test_accept_correct_domain_name
    ARGV.replace(['abc.com'])
    assert_kind_of Hash, RbDig::Options.parse(ARGV)
  end

  def test_reject_invalid_domain
    assert_raises(ArgumentError) do
      ARGV.replace(['abc'])
      RbDig::Options.parse(ARGV)
    end
    assert_raises(ArgumentError) do
      ARGV.replace(['abc .com'])
      RbDig::Options.parse(ARGV)
    end
    assert_raises(ArgumentError) do
      ARGV.replace(['abc-.com'])
      RbDig::Options.parse(ARGV)
    end
    assert_raises(ArgumentError) do
      ARGV.replace(['abc.'])
      RbDig::Options.parse(ARGV)
    end
  end

  def test_reject_missing_domain
    assert_raises(ArgumentError) do
      ARGV.replace([])
      RbDig::Options.parse(ARGV)
    end
  end

  def test_accept_missing_type
    ARGV.replace(['abc.com'])
    assert_kind_of Hash, RbDig::Options.parse(ARGV)
  end

  def test_accept_supported_types
    ARGV.replace(['abc.com', 'A'])
    assert_kind_of Hash, RbDig::Options.parse(ARGV)
  end

  def test_reject_unsupported_type
    assert_raises(ArgumentError) do
      ARGV.replace(['abc.com', 'MX'])
      RbDig::Options.parse(ARGV)
    end
  end
end
