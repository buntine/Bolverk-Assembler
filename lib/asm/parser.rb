require File.dirname(__FILE__) + "/lexer"

class Bolverk::ASM::Parser

  # A table-driven parser for Bolverk assembly. Consumes an input program
  # and generates a parse tree from it's contents.

  attr_reader :parse_tree

  # Parse table used to predict the next production, given an input token and expected
  # symbol.
  @@parse_table = {
    :program =>          { :keyword => 1,   :number => nil, :comma => nil, :eof => 1 },
    :statement_list =>   { :keyword => 2,   :number => nil, :comma => nil, :eof => 3 },
    :statement =>        { :keyword => 4,   :number => nil, :comma => nil, :eof => nil },
    :number_list =>      { :keyword => nil, :number => 5,   :comma => nil, :eof => nil },
    :number_list_tail => { :keyword => 7,   :number => nil, :comma => 6,   :eof => 7 }
  }

  @@production_table = [
    [:statement_list, :eof],              # program
    [:statement, :statement_list],        # statement_list
    [],                                   # statement_list (epsilon)
    [:keyword, :number_list],             # statement
    [:number, :number_list_tail],         # number_list
    [:comma, :number, :number_list_tail], # number_list_tail
    []                                    # number_list_tail (epsilon)
  ]

  def initialize(stream)
    @stream = stream
    @parse_tree = []
  end

  def parse
    scanner = Bolverk::ASM::Lexer.new(@stream)

    @tokens = scanner.scan
    @stack = [:program]
    
    parse_tokens(0)
  end

 private

  # Recursively parses the input tokens, always looking for syntax
  # errors.
  def parse_tokens(current_token)
    expected_symbol = @stack.fpop

    if is_terminal?(expected_symbol)
      match(expected_symbol, current_token)

      if @tokens[current_token]["type"] == :eof
        true
      else
        parse_tokens(current_token + 1)
      end
    else
      prediction = @@parse_table[expected_symbol][@tokens[current_token]["type"]]

      if prediction
        production = @@production_table[prediction - 1]
        production.reverse.each do |p|
          @stack.fpush(p)
        end

        parse_tokens(current_token)
      else
        raise Bolverk::ASM::SyntaxError, "Unexpected token: #{@tokens[current_token]["value"]}"
      end
    end
  end

  # Matches the current token with whatever the parse table
  # has predicted. A non-match results in a syntax error.
  def match(expected_token, current_token)
    token = @tokens[current_token]
    if expected_token == token["type"]
      true
    else
      raise Bolverk::ASM::SyntaxError, "Wrong token: #{token["value"]}. Expected: #{expected_token}"
    end
  end

  def is_terminal?(symbol)
    [ :comma, :number, :keyword, :eof ].include?(symbol)
  end
end

class Array
  def fpop
    self.reverse!
    v = self.pop
    self.reverse!
    return v
  end

  def fpush(value)
    self.insert(0, value)
  end
end
