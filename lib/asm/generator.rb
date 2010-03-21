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

    tree.butfirst.each do |production|
      non_terminal = production.first

      if non_terminal == :statement
        terminals = production.butfirst
        procedure = terminals.first
        arguments = terminals.butfirst

        # Check some semantics.
        assert_proc_exists(procedure)
        assert_correct_args(procedure, arguments)

        source << eval_procedure(procedure, arguments)
      end
    end

    source.join("\n")
  end

 private

  # Simplifies the parse tree into an abstract syntax tree
  # for evaluation.
  def generate_syntax_tree
    ast = build_ast(@parse_tree).first

    # Append a HALT instruction to the end of the program input.
    ast.push([ :statement, Bolverk::ASM::Token.new(:keyword, "HALT") ])
  end

  # Actually builds the AST from the parse tree. This method
  # is mutually recursive with build_ast_in_forest.
  def build_ast(tree)
    if leaf?(tree)
      is_useful_terminal?(tree.first) ? tree : []
    else
      if is_useful_non_terminal?(tree.first)
        [[tree.first] + build_ast_in_forest(tree.butfirst)]
      else
        build_ast_in_forest(tree.butfirst)
      end
    end
  end

  # Helper method for build_ast.
  def build_ast_in_forest(trees)
    if trees.empty?
      []
    else
      build_ast(trees.first) + build_ast_in_forest(trees.butfirst)
    end
  end

  # These are the only non-terminals we really need to keep in
  # the AST.
  def is_useful_non_terminal?(symbol)
    [ :program, :statement ].include?(symbol)
  end

  # We will keep all terminals except for the EOF pseudo-token and
  # commas, which are only useful for syntax verification.
  def is_useful_terminal?(symbol)
    symbol.is_a?(Bolverk::ASM::Token) and !([ :eof, :comma ].include?(symbol.type))
  end

  def leaf?(tree)
    tree.length == 1
  end

end
