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

  def test_generator_c_should_generate_valid_machine_code
    @tree_c = @program_c.parse

    @generator_c = Bolverk::ASM::Generator.new(@tree_c)

    assert_equal(@generator_c.generate, "111 111 111 111")
  end

end
