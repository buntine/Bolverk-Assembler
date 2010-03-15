class Bolverk::ASM::Generator

  # A code-generator. This constitutes the back-end of the compiler.
  # I'm taking a bit of an ad-hoc approach here, but basically the
  # generator accepts a Parse Tree and simplifies it into a Syntax
  # Tree. The Syntax Tree is then parsed and code is generated on
  # the fly.
  #
  # Some semantic analysis (procedure exists? correct number of
  # arguments?) takes place during the first pass.

  def initialize(parse_tree)
    @parse_tree = parse_tree
  end

  # Analyses the parse tree and produces the final source for the
  # target machine.
  def generate

  end

end
