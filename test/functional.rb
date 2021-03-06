#! /usr/bin/env ruby

# Just run these from terminal: $ ./test/functional.rb

require 'test/unit/ui/console/testrunner'
require File.join(File.dirname(__FILE__), "functional", "lexer")
require File.join(File.dirname(__FILE__), "functional", "parser")
require File.join(File.dirname(__FILE__), "functional", "generator")
require File.join(File.dirname(__FILE__), "functional", "compiler")

Test::Unit::UI::Console::TestRunner.run(LexerTest)
Test::Unit::UI::Console::TestRunner.run(ParserTest)
Test::Unit::UI::Console::TestRunner.run(GeneratorTest)
Test::Unit::UI::Console::TestRunner.run(CompilerTest)
