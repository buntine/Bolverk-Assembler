require File.dirname(__FILE__) + "/token"

class Bolverk::ASM::Lexer

  # Table-driven lexical analyser for Bolverk assembly. Scans an input program and returns an
  # array of program tokens. This makes the parsers job a lot easier.

  attr_reader :tokens

  # Scan table as translated from a deterministic state automaton. This table is used
  # to find the next state given a current state and input character. A nil value denotes
  # that no action can be taken. Each outer-index represents the corresponding state.
  @@scan_table = [
    [[/,/, 2],   [/-/, 7],   [/'/, 9],   [/[a-zA-Z]/, 3],   [/[0-9]/, 4],   [/\n/, 12],  [/\s|\t/, 12],  [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/'/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, nil], [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/'/, nil], [/[a-zA-Z]/, 3],   [/[0-9]/, nil], [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/'/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, 5],   [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/'/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, 6],   [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/'/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, nil], [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, nil], [/-/, 8],   [/'/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, 4],   [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, 8],   [/-/, 8],   [/'/, 8],   [/[a-zA-Z]/, 8],   [/[0-9]/, 8],   [/\n/, 13],  [/\s|\t/, 8],   [/.*/, 8]],
    [[/,/, 10],  [/-/, 10],  [/'/, 10],  [/[a-zA-Z]/, 10],  [/[0-9]/, 10],  [/\n/, 10],  [/\s|\t/, 10],  [/.*/, 10]],
    [[/,/, nil], [/-/, nil], [/'/, 11],  [/[a-zA-Z]/, nil], [/[0-9]/, nil], [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/'/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, nil], [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/'/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, nil], [/\n/, 12],  [/\s|\t/, 12],  [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/'/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, nil], [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]]
  ]

  # Token table. Each index, n, represents the token that can be recognised when the
  # lexer is at state n+1.
  @@token_list = [ nil, :comma, :keyword,
                   :number, :number, :number, 
                   nil, nil, nil, nil, :char,
                   :whitespace, :comment ]

  def initialize(stream)
    @stream = stream
    @tokens = []
  end

  # Scans the program input and returns an array of token objects
  # with the following data:
  #   type (:keyword), value ("STOR"), "line" (3)
  #
  # Produces a LexicalError exception when lexically invalid input
  # is received.
  def scan
    @tokens << next_token

    if @tokens.last.is_eof?
      unless has_halt?
        @tokens.insert(-2, Bolverk::ASM::Token.new(:keyword, "HALT"))
      end

      @tokens
    else
      scan
    end
  end

 private

  # Attempts to find the next token in the stream.
  # This algorithm respects the "longest possible token" rule and
  # is capable of detecting lexical errors.
  def next_token
    @state = 1
    value = ""
    recovery_data = [0, 0]

    while !@stream.eof?
      char = @stream.read(1)
      next_state = get_next_state(char)

      # Move to the next state.
      if next_state
        if recognizable?
          recovery_data = [@state, 0]
        end

        value << char
        recovery_data[1] += 1
        @state = next_state
      else
        # Recognise the final token.
        if recognizable?
          @stream.seek(@stream.pos - 1)
          break
        else
          # Recoverable error.
          if recovery_data[0] > 0
            value = recover_from_error!(recovery_data, value)
            break
          # Fatal lexical error.
          else
            raise Bolverk::ASM::LexicalError, "Disallowed token: #{char} on line #{@stream.line_number}"
          end
        end
      end
    end

    build_token(value)
  end

  def recognizable?
    !!get_token_name
  end

  # Recovers from a lexical error by "unreading" the remembered
  # input and falling back to the remembered state.
  def recover_from_error!(recovery_data, current_value)
    @state = recovery_data[0]
    @stream.seek(@stream.pos - recovery_data[1])

    current_value[0..-(recovery_data[1] + 1)]
  end

  # Builds a token structure or continues scanning, depending on state.
  def build_token(value)
    # If we have recognised whitespace or a comment, just ignore it and try
    # to find the next token.
    if is_whitespace_or_comment?
      next_token
    else
      # Here we append a token from the input programs content, or an EOF
      # token to help the parser match the end of the input.
      type = (value.empty?) ? :eof : get_token_name
      Bolverk::ASM::Token.new(type, value, @stream.line_number)
    end
  end

  # Returns the token (if any) for the current state.
  def get_token_name
    @@token_list[@state - 1]
  end

  # Attempts to match the character against one of the scan rules.
  def get_next_state(char)
    @@scan_table[@state - 1].find(lambda {[0, 1]}) { |rule| char =~ rule[0] }[1]
  end

  def is_whitespace_or_comment?
    [:whitespace, :comment].include?(get_token_name)
  end

  # Returns true if the token array contains a HALT mnemonic.
  def has_halt?
    @tokens.any? { |t| t.is_halt? }
  end
end
