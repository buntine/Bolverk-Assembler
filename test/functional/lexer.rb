require 'test/unit'

require File.join(File.dirname(__FILE__), "../..", "lib", "asm")

class LexerTest < Test::Unit::TestCase

  # This is easy. We just need to scan a few programs and verify that
  # the lexer responds appropriately.

  def setup
    path = lambda { |file| File.join(File.dirname(__FILE__), "data", file) }
    @program_a = Bolverk::ASM::Lexer.new(File.open(path.call("valid_a.basm")))
    @program_b = Bolverk::ASM::Lexer.new(File.open(path.call("valid_b.basm")))
    @program_c = Bolverk::ASM::Lexer.new(File.open(path.call("invalid_a.basm")))
  end

  def test_program_a_has_correct_number_of_tokens
    @program_a.scan
    assert(@program_a.tokens.length == 21, "Expected 21 tokens")
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

    assert(token_a["type"] == :keyword, "Expected :keyword at token 1")
    assert(token_b["type"] == :number, "Expected :number at token 9")
    assert(token_c["type"] == :comma, "Expected :comma at token 10")
    assert(token_d["type"] == :number, "Expected :number at token 15")

    assert(token_a["value"] == "LOAD", "Expected value 'LOAD' at token 1")
    assert(token_b["value"] == "1", "Expected value '1' at token 9")
    assert(token_c["value"] == ",", "Expected value ',' at token 10")
    assert(token_d["value"] == "3", "Expected value '3' at token 15")
  end

  def test_program_a_ends_with_trailing_pseudotoken
    @program_a.scan
    eof_token = @program_a.tokens.last

    assert(eof_token["type"] == :eof)
  end

  def test_program_b_has_correct_number_of_tokens
    @program_b.scan
    assert(@program_b.tokens.length == 23, "Expected 23 tokens")
  end

  def test_program_b_saves_tokens_after_scanning
    @program_b.scan
    assert(@program_b.tokens.is_a?(Array), "Expected token data to be available")
  end

  # We just need to look for a few, not all of them.
  def test_program_b_has_correct_tokens
    @program_b.scan

    token_a = @program_b.tokens[0]
    token_b = @program_b.tokens[9]
    token_c = @program_b.tokens[10]
    token_d = @program_b.tokens[16]

    assert(token_a["type"] == :keyword, "Expected :keyword at token 1")
    assert(token_b["type"] == :number, "Expected :number at token 9")
    assert(token_c["type"] == :comma, "Expected :comma at token 10")
    assert(token_d["type"] == :keyword, "Expected :keyword at token 16")

    assert(token_a["value"] == "LOAD", "Expected value 'LOAD' at token 1")
    assert(token_b["value"] == "2", "Expected value '2' at token 9")
    assert(token_c["value"] == ",", "Expected value ',' at token 10")
    assert(token_d["value"] == "STOR", "Expected value 'STOR' at token 16")
  end

  def test_program_b_ends_with_trailing_pseudotoken
    @program_b.scan
    eof_token = @program_b.tokens.last

    assert(eof_token["type"] == :eof)
  end

end