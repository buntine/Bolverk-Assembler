require 'test/unit'
require File.join(File.dirname(__FILE__), "../..", "lib", "asm")

class CompilerTest < Test::Unit::TestCase

  # Here we just try to compile each program and make sure we get the 
  # correct response (success or failure).
  # See the other files for more in-depth testing.

  def setup
    path = lambda { |file| File.join(File.dirname(__FILE__), "data", file) }

    @stream_a = File.open(path.call("valid_a.basm"))
    @stream_b = File.open(path.call("valid_b.basm"))
    @stream_c = File.open(path.call("valid_c.basm"))
    @stream_d = File.open(path.call("valid_d.basm"))
    @stream_e = File.open(path.call("invalid_a.basm"))
    @stream_f = File.open(path.call("invalid_b.basm"))
  end

  def test_program_a_should_compile_successfully
    @program_a = Bolverk::ASM::Compiler.new(@stream_a)

    assert_nothing_raised do
      @program_a.compile
    end
  end

  def test_program_b_should_cause_semantic_error
    @program_b = Bolverk::ASM::Compiler.new(@stream_b)

    assert_raise Bolverk::ASM::SemanticError do
      @program_b.compile
    end
  end

  def test_program_c_should_cause_semantic_error
    @program_c = Bolverk::ASM::Compiler.new(@stream_c)

    assert_raise Bolverk::ASM::SemanticError do
      @program_c.compile
    end
  end

  def test_program_d_should_compile_successfully
    @program_d = Bolverk::ASM::Compiler.new(@stream_d)

    assert_nothing_raised do
      @program_d.compile
    end
  end

  def test_program_e_should_cause_lexical_error
    @program_e = Bolverk::ASM::Compiler.new(@stream_e)

    assert_raise Bolverk::ASM::LexicalError do
      @program_e.compile
    end
  end

  def test_program_f_should_cause_syntax_error
    @program_f = Bolverk::ASM::Compiler.new(@stream_f)

    assert_raise Bolverk::ASM::SyntaxError do
      @program_f.compile
    end
  end

end
