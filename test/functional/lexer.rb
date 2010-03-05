require 'test/unit'

class LexerTest < Test::Unit::TestCase

  # This is easy. We just need to scan a few programs and verify that
  # the lexer responds appropriately.

  def setup
    path = lambda { |file| File.join(File.dirname(__FILE__), "data", file) }
    @program_a = path.call("valid_a.basm")
    @program_b = path.call("valid_b.basm")
    @program_c = path.call("invalid_a.basm")
  end

  def test_program_a_has_correct_number_of_tokens
    @program_a.scan
    assert(@program_a.tokens.length == 21, "Expected 21 tokens")
  end

  # We just need to look for a few, not all of them.
  def test_program_a_has_correct_tokens

  end

  def test_program_a_ends_with_trailing_pseudotoken

  end

end

