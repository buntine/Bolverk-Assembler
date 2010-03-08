require File.dirname(__FILE__) + "/lexer"

class Bolverk::ASM::Parser

  # A table-driven LL(1) parser for Bolverk assembly. Consumes an input
  # program and generates a parse tree from it's contents.

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
    @parse_tree << :program
    
    parse_tokens
  end

 private

  # Recursively parses the input tokens, always looking for syntax
  # errors.
  def parse_tokens(current_token=0, tree_path=[])
    expected_symbol = @stack.shift
    if is_terminal?(expected_symbol)
      match(expected_symbol, current_token)

      node_for_path(tree_path[0..-2])[tree_path.last] = [@tokens[current_token]]

      # If true, we are finished and can clean up.
      if is_eof?(current_token) 
        puts @parse_tree.inspect
        true
      else
        parse_tokens(current_token + 1, tree_path[0..-2] + [tree_path.last + 1])
      end
    # We are dealing with a non-terminal, which may need to be expanded.
    else
      make_prediction(expected_symbol, current_token, tree_path)
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
  def make_prediction(expected_symbol, index, tree_path)
    prediction = fetch_prediction(expected_symbol, index) 

    if prediction
      production = @@production_table[prediction - 1]
      production.reverse.each do |p|
        @stack.fpush(p)
      end

      node = node_for_path(tree_path)

      # Epsilon production, look back up the tree for the next branch.
      if production.empty?
        node << [:epsilon]
        parse_tokens(index, find_suitable_branch(tree_path[0..-2], tree_path.last))
      else
        production.each { |p| node << [p] }
        parse_tokens(index, tree_path + [1])
      end
    else
      raise Bolverk::ASM::SyntaxError, "Unexpected token: #{token_value(index)}. Line #{token_line(index)}"
    end
  end

  def find_suitable_branch(remaining_path, index)
    node = node_for_path(remaining_path[0..-2])

    if node.length > index + 1
      remaining_path[0..-2] + [remaining_path.last + 1]
    else
      find_suitable_branch(remaining_path[0..-2], remaining_path[0..-2].last)
    end
  end

  # Returns the node of the parse tree that corresponds to the given
  # path. [1 2 1] --> @parse_tree[1][2][1]
  def node_for_path(path, subtree=@parse_tree, index=0)
    if index == path.length
      subtree
    else
      node_for_path(path, subtree[path[index]], index + 1)
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
