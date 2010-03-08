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
    parse_tree = [:program,
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

    assert_nothing_raised do
      tree = @program_a.parse

      assert(tree[0] == :program, "Expected Program A to parse successfully")
      assert(tree[1][0] == :statement_list, "Expected Program A to parse successfully")
      assert(tree[1][1][1].class == Hash, "Expected Program A to parse successfully")
    end
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
