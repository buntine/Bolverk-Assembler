class File

  # This is a naive, non-portable mixin to allow File objects to
  # keep track of the current line number in the buffer. The built-in
  # functionality only counts the calls to "gets" (equally as stupid).
  # This solution is specific to this application and lacks some
  # important things:
  #   - Line number only kept track of with "read" and "seek" methods
  #   - It defaults to nil. Only set to 1+ after the first call to "read".

  alias_method :old_read, :read
  alias_method :old_seek, :seek

  attr_reader :line_number

  def read(bytes)
    @line_number ||= 1

    data = self.old_read(bytes)
    update_line_number(data)

    data
  end

  def seek(position)
    p = self.pos
    inc = 1

    if position > p
      data = self.old_read(position - p)
    else
      data = read_from_pos(position, p - position)
      inc = -1
    end

    update_line_number(data, inc)
    position
  end

private

  # Reads 'length' number of bytes from the specified position
  # and returns the buffer to the original character.
  def read_from_pos(position, length)
    self.old_seek(position)
    data = self.old_read(length)
    self.old_seek(position)

    data
  end

  # Searches through the given characters and updates @line_number
  # by "inc" on each occurance of a newline. Returns the original data.
  def update_line_number(data, inc=1)
    data.each_char do |char|
      if char == "\n"
        @line_number += inc
      end
    end

    data
  end

end
