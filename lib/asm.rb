# Setup root namespace.
module Bolverk; end
module Bolverk::ASM; end

# Setup custom exceptions.
class Bolverk::ASM::LexicalError < Exception; end
class Bolverk::ASM::SyntaxError < Exception; end
class Bolverk::ASM::SemanticError < Exception; end

# Begin the loading sequence.
require File.dirname(__FILE__) + "/monkeypatches/array"
require File.dirname(__FILE__) + "/monkeypatches/file"
require File.dirname(__FILE__) + "/asm/parser"
