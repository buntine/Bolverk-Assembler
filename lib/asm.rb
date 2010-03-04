# Setup root namespace.
module Bolverk; end
module Bolverk::ASM; end

# Setup custom exceptions.
class Bolverk::ASM::LexicalError < Exception; end

# Begin the loading sequence.
require File.dirname(__FILE__) + "/asm/lexer"
