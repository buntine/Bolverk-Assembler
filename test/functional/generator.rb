require 'test/unit'
require File.join(File.dirname(__FILE__), "../..", "lib", "asm")

class GeneratorTest < Test::Unit::TestCase

  # Lets generate some programs from differing parse trees.

  def setup
    path = lambda { |file| File.join(File.dirname(__FILE__), "data", file) }

    @tokens_a = Bolverk::ASM::Lexer.new(Bolverk::ASM::Stream.new(File.read(path.call("valid_a.basm")))).scan
    @tokens_c = Bolverk::ASM::Lexer.new(Bolverk::ASM::Stream.new(File.read(path.call("valid_c.basm")))).scan
    @tokens_d = Bolverk::ASM::Lexer.new(Bolverk::ASM::Stream.new(File.read(path.call("valid_d.basm")))).scan

    @program_a = Bolverk::ASM::Parser.new(@tokens_a)
    @program_c = Bolverk::ASM::Parser.new(@tokens_c)
    @program_d = Bolverk::ASM::Parser.new(@tokens_d)
  end

  def test_program_a_should_generate_valid_machine_code
    @tree_a = @program_a.parse
    @generator_a = Bolverk::ASM::Generator.new(@tree_a)

    assert_equal(@generator_a.generate, "2143\n22ec\n5123\n3363\nd163\nc000")
  end

  def test_program_d_should_generate_valid_machine_code
    @tree_d = @program_d.parse
    @generator_d = Bolverk::ASM::Generator.new(@tree_d)

    assert_equal(@generator_d.generate, "2548\n2669\n22fe\nc000\n5123\n3363\nd163")
  end

  # One of the calls to VALL only supplies one argument.
  def test_program_c_should_cause_semantic_error
    @tree_c = @program_c.parse
    @generator_c = Bolverk::ASM::Generator.new(@tree_c)

    assert_raise(Bolverk::ASM::SemanticError) do
      @generator_c.generate
    end
  end

end
