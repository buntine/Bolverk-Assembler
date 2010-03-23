require File.dirname(__FILE__) + "/stream"
require File.dirname(__FILE__) + "/lexer"
require File.dirname(__FILE__) + "/parser"
require File.dirname(__FILE__) + "/generator"

class Bolverk::ASM::Compiler

  # The compiler accepts a raw string or a file-like
  # object.
  def initialize(stream)
    contents = stream.respond_to?(:read) ? stream.read : stream
    @stream = Bolverk::ASM::Stream.new(contents)
  end

  # Scans, parses and generates source from the contents
  # of the stream. See the corresponding classes for the
  # real work.
  def compile
    lexer = Bolverk::ASM::Lexer.new(@stream)
    tokens = lexer.scan

    parser = Bolverk::ASM::Parser.new(tokens)
    parse_tree = parser.parse

    generator = Bolverk::ASM::Generator.new(parse_tree)
    source = generator.generate

    return source
  end

end
