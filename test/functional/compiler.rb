require 'stringio'
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


  # And now lets test every primitive/mnemonic.

  def test_meml_generates_correct_source
    program = StringIO.new("MEML 10, 100")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "1a64\nc000")
  end

  def test_vall_generates_correct_source
    program = StringIO.new("VALL 10, -100")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "2a9c\nc000")
  end

  def test_stor_generates_correct_source
    program = StringIO.new("STOR 10, 104")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "3a68\nc000")
  end

  def test_move_generates_correct_source
    program = StringIO.new("MOVE 10, 11")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "40ab\nc000")
  end

  def test_badd_generates_correct_source
    program = StringIO.new("BADD 10, 11, 12")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "5abc\nc000")
  end

  def test_fadd_generates_correct_source
    program = StringIO.new("FADD 10, 11, 12")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "6abc\nc000")
  end

  def test_or_generates_correct_source
    program = StringIO.new("OR 11, 12, 13")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "7bcd\nc000")
  end

  def test_and_generates_correct_source
    program = StringIO.new("AND 1, 2, 3")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "8123\nc000")
  end

  def test_xor_generates_correct_source
    program = StringIO.new("XOR 11, 12, 13")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "9bcd\nc000")
  end

  def test_rot_generates_correct_source
    program = StringIO.new("ROT 1, 3")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "a103\nc000")
  end

  def test_jump_generates_correct_source
    program = StringIO.new("JUMP 15, 16")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "bf10\nc000")
  end

  def test_halt_generates_correct_source
    program = StringIO.new("HALT")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "c000")
  end

  def test_pmch_generates_correct_source
    program = StringIO.new("PMCH 250")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "d0fa\nc000")
  end

  def test_pmde_generates_correct_source
    program = StringIO.new("PMDE 250")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "d1fa\nc000")
  end

  def test_pmfp_generates_correct_source
    program = StringIO.new("PMFP 250")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "d2fa\nc000")
  end

  def test_pvch_generates_correct_source
    program = StringIO.new("PVCH 251")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "e0fb\nc000")
  end

  def test_pvde_generates_correct_source
    program = StringIO.new("PVDE 252")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "e1fc\nc000")
  end

  def test_pvfp_generates_correct_source
    program = StringIO.new("PVFP 251")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "e2fb\nc000")
  end

  def test_writ_generates_correct_source
    program = StringIO.new("WRIT '%', 251")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "2f25\n3ffb\nc000")
  end

  def test_pvds_generates_correct_source
    program = StringIO.new("PVDS 5, 6")
    compiler = Bolverk::ASM::Compiler.new(program)
    source = compiler.compile

    assert_equal(source, "556f\n3fff\nd1ff\nc000")
  end


  # And now lets test a few semantic errors.

  def test_invalid_memory_cell_should_cause_semantic_error
    program = StringIO.new("WRIT '$', 300")
    compiler = Bolverk::ASM::Compiler.new(program)

    assert_raise Bolverk::ASM::SemanticError do
      compiler.compile
    end
  end

  def test_invalid_register_should_cause_semantic_error
    program = StringIO.new("PVDS 15, 19")
    compiler = Bolverk::ASM::Compiler.new(program)

    assert_raise Bolverk::ASM::SemanticError do
      compiler.compile
    end
  end

  def test_invalid_number_should_cause_semantic_error
    program = StringIO.new("VALL 4, -130")
    compiler = Bolverk::ASM::Compiler.new(program)

    assert_raise Bolverk::ASM::SemanticError do
      compiler.compile
    end
  end

end
