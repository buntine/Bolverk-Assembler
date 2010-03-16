require File.dirname(__FILE__) + "/procedures"

class Bolverk::ASM::Generator

  include Bolverk::ASM::Procedures

  # A code-generator. This constitutes the back-end of the compiler.
  # I'm taking a bit of an ad-hoc approach here, but basically the
  # generator accepts a Parse Tree and simplifies it into a Syntax
  # Tree. The members of the Syntax Tree are then evaluated to
  # produce the final program source.
  #
  # Some semantic analysis (procedure exists? correct number of
  # arguments?) takes place during the evaluation pass.

  def initialize(parse_tree)
    @parse_tree = parse_tree
  end

  # Analyses the parse tree and produces the final source for the
  # target machine.
  def generate
    tree = generate_syntax_tree
    source = []
  
    tree[0..-1].each do |statement|
      procedure = statement[1]

      # Check some semantics.
      assert_proc_exists(procedure)
      assert_correct_args(procedure, statement[2..-1])

      source << self.send("proc_#{procedure}", statement[2..-1])
    end

    source.join("\n")
  end

 private

  # Simplifies the parse tree into an abstract syntax tree
  # for evaluation.
  def generate_syntax_tree
    [:program,
      [:statement,
        "KEYWORD",
        "NUMBER",
        "NUMBER"],
      [:statement,
        "KEYWORD",
        "NUMBER"]]
  end

end
