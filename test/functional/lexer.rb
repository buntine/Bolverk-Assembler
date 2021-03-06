require 'test/unit'
require File.join(File.dirname(__FILE__), "../..", "lib", "asm")

class LexerTest < Test::Unit::TestCase

  # This is easy. We just need to scan a few programs and verify that
  # the lexer responds appropriately.

  def setup
    path = lambda { |file| File.join(File.dirname(__FILE__), "data", file) }
    @program_a = Bolverk::ASM::Lexer.new(Bolverk::ASM::Stream.new(File.read(path.call("valid_a.basm"))))
    @program_b = Bolverk::ASM::Lexer.new(Bolverk::ASM::Stream.new(File.read(path.call("valid_b.basm"))))
    @program_c = Bolverk::ASM::Lexer.new(Bolverk::ASM::Stream.new(File.read(path.call("invalid_a.basm"))))
    @program_d = Bolverk::ASM::Lexer.new(Bolverk::ASM::Stream.new(File.read(path.call("valid_d.basm"))))
  end

  def test_program_a_has_correct_number_of_tokens
    @program_a.scan
    assert(@program_a.tokens.length == 22, "Expected 22 tokens")
  end

  def test_program_a_saves_tokens_after_scanning
    @program_a.scan
    assert(@program_a.tokens.is_a?(Array), "Expected token data to be available")
  end

  # We just need to look for a few, not all of them.
  def test_program_a_has_correct_tokens
    @program_a.scan

    token_a = @program_a.tokens[0]
    token_b = @program_a.tokens[9]
    token_c = @program_a.tokens[10]
    token_d = @program_a.tokens[15]

    assert(token_a.type == :keyword, "Expected :keyword at token 1")
    assert(token_b.type == :number, "Expected :number at token 9")
    assert(token_c.type == :comma, "Expected :comma at token 10")
    assert(token_d.type == :number, "Expected :number at token 15")

    assert(token_a.value == "VALL", "Expected value 'VALL' at token 1")
    assert(token_b.value == "1", "Expected value '1' at token 9")
    assert(token_c.value == ",", "Expected value ',' at token 10")
    assert(token_d.value == "3", "Expected value '3' at token 15")
  end

  def test_program_a_reports_tokens_on_the_correct_line
    @program_a.scan

    assert(@program_a.tokens[1].line == 2, "Expected token[1] to be on line 2")
    assert(@program_a.tokens[6].line == 3, "Expected token[6] to be on line 3")
    assert(@program_a.tokens[12].line == 4, "Expected token[12] to be on line 4")
    assert(@program_a.tokens[13].line == 4, "Expected token[13] to be on line 4")
    assert(@program_a.tokens[15].line == 5, "Expected token[15] to be on line 5")
  end

  def test_program_a_ends_with_trailing_pseudotoken
    @program_a.scan
    eof_token = @program_a.tokens.last

    assert(eof_token.type == :eof)
  end

  def test_program_a_has_only_one_eof_token
    @program_a.scan
    eofs = @program_a.tokens.find_all { |t| t.type == :eof }

    assert_equal(eofs.length, 1)
  end

  def test_lexer_gave_program_a_one_halt_mnemonic
    @program_a.scan

    # Should have been placed before the final :eof token.
    assert(@program_a.tokens[-2].value.downcase == "halt", "Expected compiler to add HALT")
  end

  def test_program_b_has_correct_number_of_tokens
    @program_b.scan
    assert(@program_b.tokens.length == 24, "Expected 24 tokens")
  end

  def test_program_b_saves_tokens_after_scanning
    @program_b.scan
    assert(@program_b.tokens.is_a?(Array), "Expected token data to be available")
  end

  # We just need to look for a few, not all of them.
  def test_program_b_has_correct_tokens
    @program_b.scan

    token_a = @program_b.tokens[0]
    token_b = @program_b.tokens[3]
    token_c = @program_b.tokens[9]
    token_d = @program_b.tokens[10]
    token_e = @program_b.tokens[16]

    assert(token_a.type == :keyword, "Expected :keyword at token 1")
    assert(token_b.type == :char, "Expected :char at token 4")
    assert(token_c.type == :number, "Expected :number at token 10")
    assert(token_d.type == :comma, "Expected :comma at token 11")
    assert(token_e.type == :keyword, "Expected :keyword at token 17")

    assert(token_a.value == "VALL", "Expected value 'VALL' at token 1")
    assert(token_b.value == "H", "Expected value 'H' at token 4")
    assert(token_c.value == "2", "Expected value '2' at token 10")
    assert(token_d.value == ",", "Expected value ',' at token 11")
    assert(token_e.value == "STOR", "Expected value 'STOR' at token 17")
  end

  def test_program_b_reports_tokens_on_the_correct_line
    @program_b.scan

    assert(@program_b.tokens[1].line == 3, "Expected token[1] to be on line 3")
    assert(@program_b.tokens[6].line == 4, "Expected token[6] to be on line 4")
    assert(@program_b.tokens[15].line == 6, "Expected token[15] to be on line 6")
    assert(@program_b.tokens[17].line == 7, "Expected token[17] to be on line 7")
    assert(@program_b.tokens[19].line == 7, "Expected token[19] to be on line 7")
    assert(@program_b.tokens[20].line == 8, "Expected token[20] to be on line 8")
  end

  def test_program_b_ends_with_trailing_pseudotoken
    @program_b.scan
    eof_token = @program_b.tokens.last

    assert(eof_token.type == :eof)
  end

  def test_program_b_has_only_one_eof_token
    @program_b.scan
    eofs = @program_b.tokens.find_all { |t| t.type == :eof }

    assert_equal(eofs.length, 1)
  end

  def test_lexer_gave_program_b_one_halt_mnemonic
    @program_b.scan

    # Should have been placed before the final :eof token.
    assert(@program_b.tokens[-2].value.downcase == "halt", "Expected compiler to add HALT")
  end

  def test_program_c_dies_with_lexical_error
    assert_raise Bolverk::ASM::LexicalError do
      @program_c.scan
    end
  end

  def test_program_d_has_correct_number_of_tokens
    @program_d.scan
    assert(@program_d.tokens.length == 26, "Expected 26 tokens")
  end

  def test_program_d_saves_tokens_after_scanning
    @program_d.scan
    assert(@program_d.tokens.is_a?(Array), "Expected token data to be available")
  end

  # We just need to look for a few, not all of them.
  def test_program_a_has_correct_tokens
    @program_d.scan

    token_a = @program_d.tokens[0]
    token_b = @program_d.tokens[9]
    token_c = @program_d.tokens[10]
    token_d = @program_d.tokens[7]

    assert(token_a.type == :keyword, "Expected :keyword at token 1")
    assert(token_b.type == :number, "Expected :number at token 10")
    assert(token_c.type == :comma, "Expected :comma at token 11")
    assert(token_d.type == :char, "Expected :char at token 8")

    assert(token_a.value == "VALL", "Expected value 'VALL' at token 1")
    assert(token_b.value == "2", "Expected value '2' at token 10")
    assert(token_c.value == ",", "Expected value ',' at token 11")
    assert(token_d.value == "i", "Expected value 'i' at token 9")
  end

  def test_program_d_reports_tokens_on_the_correct_line
    @program_d.scan

    assert(@program_d.tokens[1].line == 5, "Expected token[1] to be on line 5")
    assert(@program_d.tokens[6].line == 6, "Expected token[6] to be on line 6")
    assert(@program_d.tokens[12].line == 8, "Expected token[12] to be on line 8")
    assert(@program_d.tokens[13].line == 9, "Expected token[13] to be on line 9")
    assert(@program_d.tokens[15].line == 9, "Expected token[15] to be on line 9")
  end

  def test_program_d_ends_with_trailing_pseudotoken
    @program_d.scan
    eof_token = @program_d.tokens.last

    assert(eof_token.type == :eof)
  end

  def test_program_d_has_only_one_eof_token
    @program_d.scan
    eofs = @program_d.tokens.find_all { |t| t.type == :eof }

    assert_equal(eofs.length, 1)
  end

  def test_lexer_did_not_give_program_d_one_halt_mnemonic
    @program_d.scan

    # This program already has a HALT, so it should not have been added by the compiler.
    assert(@program_d.tokens[-2].value.downcase != "halt", "Expected compiler to NOT add HALT")
  end

end
