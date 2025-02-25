class Reader
  attr_reader :buffer
  attr_accessor :pos
  def initialize(buffer)
    @buffer = buffer
    @pos = 0
  end

  def read(num_bytes = false)
    return "" if !num_bytes || num_bytes <= 0

    old_pos = @pos
    @pos += num_bytes
    @buffer[old_pos..@pos - 1]
  end

  def rest
    @buffer[@pos..]
  end
end
