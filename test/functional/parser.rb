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
#    [:program]
#    []p: [:program, [:statement_list], [:eof]]
#    [1]p: [:program, [:statement_list, [:statement], [:statement_list]], [:eof]]
#    [1 1]p: [:program, [:statement_list, [:statement, [:keyword], [:number_list]], [:statement_list]], [:eof]]
#    [1 1 1]m: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list]], [:statement_list]], [:eof]]
#    [1 1 2]p: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [:number], [:number_list]]], [:statement_list]], [:eof]]
#    [1 1 2 1]m: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail]]], [:statement_list]], [:eof]]
#    [1 1 2 2]p: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, ["COMMA"], ["NUMBER"], [:number_list_tail]]]], [:statement_list]], [:eof]]
#    [1 1 2 2 1]m: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], ["NUMBER"], [:number_list_tail]]]], [:statement_list]], [:eof]]
#    [1 1 2 2 2]m: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], [NUMBER], [:number_list_tail]]]], [:statement_list]], [:eof]]
#    [1 1 2 2 3]p: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], [NUMBER], [:number_list_tail, [:epsilon]]]]], [:statement_list]], [:eof]]
##    [1 1 2 2 3 1]p: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], [NUMBER], [:number_list_tail, [:epsilon]]]]], [:statement_list]], [:eof]]
#    [1 2]p: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], [NUMBER], [:number_list_tail, [:epsilon]]]]], [:statement_list, [:statement], [:statement_list]]], [:eof]]
#    [1 2 1]p: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], [NUMBER], [:number_list_tail, [:epsilon]]]]], [:statement_list, [:statement, [:keyword], [:number_list]], [:statement_list]]], [:eof]]
#    [1 2 1 1]m: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], [NUMBER], [:number_list_tail, [:epsilon]]]]], [:statement_list, [:statement, [KEYWORD], [:number_list]], [:statement_list]]], [:eof]]
#    [1 2 1 2]p: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], [NUMBER], [:number_list_tail, [:epsilon]]]]], [:statement_list, [:statement, [KEYWORD], [:number_list, [:number], [:number_list_tail]]], [:statement_list]]], [:eof]]
#    [1 2 1 2 1]m: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], [NUMBER], [:number_list_tail, [:epsilon]]]]], [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail]]], [:statement_list]]], [:eof]]
#    [1 2 1 2 2]p: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], [NUMBER], [:number_list_tail, [:epsilon]]]]], [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [:epsilon]]]], [:statement_list]]], [:eof]]
#    [1 2 1 2 2 1]p: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], [NUMBER], [:number_list_tail, [:epsilon]]]]], [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [:epsilon]]]], [:statement_list]]], [:eof]]
#    [1 2 2]p: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], [NUMBER], [:number_list_tail, [:epsilon]]]]], [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [:epsilon]]]], [:statement_list, [:epsilon]]]], [:eof]]
#    [1 2 2 1]p: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], [NUMBER], [:number_list_tail, [:epsilon]]]]], [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [:epsilon]]]], [:statement_list, [:epsilon]]]], [:eof]]
#    [2]p: [:program, [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [COMMA], [NUMBER], [:number_list_tail, [:epsilon]]]]], [:statement_list, [:statement, [KEYWORD], [:number_list, [NUMBER], [:number_list_tail, [:epsilon]]]], [:statement_list, [:epsilon]]]], [:eof]]

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

  #  assert_not_raise Bolverk::ASM::SyntaxError do
  #    assert(@program_a.parse == parse_tree, "Expected Program A to parse successfully")
  #  end
    assert(@program_a.parse)
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
