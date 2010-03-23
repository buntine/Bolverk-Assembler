class Bolverk::ASM::Token

  # A tiny class to represent a single token during the compilation process.

  attr_reader :type
  attr_reader :value
  attr_reader :line

  def initialize(type, value, line=0)
    @type = type
    @value = value
    @line = line

    # In later phases of compilation, characters are treated
    # as numbers. Here we keep the original character value,
    # but update the type.
    if type == :char
      @type = :number
      @value = value.gsub("\'", "")
    end
  end

  def is_eof?
    @type == :eof
  end

  def is_halt?
    @type == :keyword and @value.downcase == "halt"
  end

end
