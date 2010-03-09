require 'test/unit'
require File.join(File.dirname(__FILE__), "../..", "lib", "asm")

class ParserTest < Test::Unit::TestCase

  # We just need to parse a few programs and verify that the parser
  # behaves appropriately.

  def setup
    path = lambda { |file| File.join(File.dirname(__FILE__), "data", file) }
    @program_a = Bolverk::ASM::Parser.new(File.open(path.call("valid_a.basm")))
    @program_b = Bolverk::ASM::Parser.new(File.open(path.call("valid_b.basm")))
    @program_c = Bolverk::ASM::Parser.new(File.open(path.call("invalid_a.basm")))
    @program_d = Bolverk::ASM::Parser.new(File.open(path.call("invalid_b.basm")))
  end

  def test_program_a_parses_correctly
    # Here is the valid (except for terminal structure) parse tree
    # for the program stored in ./data/valid_c.basm
    [:program,
      [:statement_list,
        [:statement,
          ["KEYWORD"],
          [:number_list,
            ["NUMBER]",
            [:number_list_tail,
              ["COMMA"],
              ["NUMBER"],
              [:number_list_tail,
                ["EPSILON"]]]]],
        [:statement_list,
          [:statement,
            ["KEYWORD"],
            [:number_list,
              ["NUMBER"],
              [:number_list_tail,
                ["EPSILON"]]]],
          [:statement_list,
            ["EPSILON"]]]],
      [:eof]]]

      tree = @program_a.parse

      # Just test that a bunch of the program tokens are in the correct indexes.
      assert(tree[0] == :program, "Expected tree[0] to be :program")
      assert(tree[1][0] == :statement_list, "Expected tree[1][0] to be :statement_list")
      assert(tree[1][1][1][0].class == Hash, "Expected tree[1][1][1] to be a Hash")
      assert(tree[1][1][2][2][0] == :number_list_tail, "Expected tree[1][1][2][2] to be :number_list_tail")
      assert(tree[1][1][2][1][0].class == Hash, "Expected tree[1][1][2][1][0] to be a Hash")
      assert(tree[1][1][2][2][3][1][0] == :epsilon, "Expected tree[1][1][2][2][3][1][0] to be :epsilon")
  end

#  def test_program_b_parses_correctly
#    assert(@program_b.parse, "Expected Program B to parse successfully")
#  end

#  def test_program_c_causes_lexical_error
#    assert_raise Bolverk::ASM::LexicalError do
#      @program_c.parse
#    end
#  end
#
#  def test_program_d_causes_syntax_error
#    assert_raise Bolverk::ASM::SyntaxError do
#      @program_d.parse
#    end
#  end

end
