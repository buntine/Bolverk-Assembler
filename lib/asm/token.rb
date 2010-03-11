class Bolverk::ASM::Token

  # A tiny class to represent a single token during the compilation process.

  attr_reader :type
  attr_reader :value
  attr_reader :line

  def initialize(type, value, line)
    @type = type
    @value = value
    @line = line
  end

  def is_eof?
    @type == :eof
  end

end
