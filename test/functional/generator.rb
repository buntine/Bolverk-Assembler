require 'test/unit'
require File.join(File.dirname(__FILE__), "../..", "lib", "asm")

class GeneratorTest < Test::Unit::TestCase

  # Lets generate some programs from differing parse trees.

  def setup
    path = lambda { |file| File.join(File.dirname(__FILE__), "data", file) }
    @program_a = Bolverk::ASM::Parser.new(File.open(path.call("valid_a.basm")))
    @program_b = Bolverk::ASM::Parser.new(File.open(path.call("valid_b.basm")))
    @program_c = Bolverk::ASM::Parser.new(File.open(path.call("valid_c.basm")))
  end

  def test_program_a_should_generate_valid_machine_code
    @tree_a = @program_a.parse
    @generator_a = Bolverk::ASM::Generator.new(@tree_a)

    assert_equal(@generator_a.generate, "2143\n227c\n5123\n3363\nd163")
  end

  # One of the calls to LOAD only supplies one argument.
  def test_program_c_should_cause_semantic_error
    @tree_c = @program_c.parse
    @generator_c = Bolverk::ASM::Generator.new(@tree_c)

    assert_raise(Bolverk::ASM::SemanticError) do
      @generator_c.generate
    end
  end

end
