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

  # Configures the object for parsing. Returns the constructed parse tree
  # or dies with a Syntax Error.
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
    expected_symbol = @stack.shift

    if is_terminal?(expected_symbol)
      match(expected_symbol, current_token)

      # If true, we are finished and can clean up.
      if is_eof?(current_token) 
        true
      else
        parse_tokens(current_token + 1)
      end
    # We are dealing with a non-terminal, which may need to be expanded.
    else
      make_prediction(expected_symbol, current_token)
    end
  end

  # Matches the current token with whatever the parse table
  # has predicted. A non-match results in a syntax error.
  def match(expected_token, index)
    if expected_token == token_type(index)
      true
    else
      raise Bolverk::ASM::SyntaxError, "Wrong token: #{token_value(index)}. Expected a #{expected_token}. Line #{token_line(index)}"
    end
  end

  # Makes a suitable prediction for the next production and prefixes
  # it to the parse stack for further inspection on subsequent recursions.
  def make_prediction(expected_symbol, index)
    prediction = fetch_prediction(expected_symbol, index) 

    if prediction
      production = @@production_table[prediction - 1]
      production.reverse.each do |p|
        @stack.fpush(p)
      end

      parse_tokens(index)
    else
      raise Bolverk::ASM::SyntaxError, "Unexpected token: #{token_value(index)}. Line #{token_line(index)}"
    end
  end

  # Consults the parse table for a prediction, given an expected symbol
  # and token.
  def fetch_prediction(expected_symbol, index)
    @@parse_table[expected_symbol][token_type(index)]
  end

  def is_terminal?(symbol)
    [ :comma, :number, :keyword, :eof ].include?(symbol)
  end

  def token_type(index)
    @tokens[index]["type"]
  end

  def token_value(index)
    @tokens[index]["value"]
  end

  def token_line(index)
    @tokens[index]["line"]
  end

  def is_eof?(index)
    token_type(index) == :eof
  end

end
