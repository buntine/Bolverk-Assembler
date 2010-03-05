class Bolverk::ASM::Lexer

  # Table-driven lexical analyser for Bolverk assembly. Scans an input program and returns an
  # array of program tokens. This makes the parsers job a lot easier.

  attr_reader :tokens

  # Scan table as translated from a deterministic state automaton. This table is used
  # to find the next state given a current state and input character. A nil value denotes
  # that no action can be taken.
  @@scan_table = [
    [[/,/, 2],   [/-/, 7],   [/[a-zA-Z]/, 3],   [/[0-9]/, 4],   [/\n/, 9],   [/\s|\t/, 9],   [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, nil], [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/[a-zA-Z]/, 3],   [/[0-9]/, nil], [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, 5],   [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, 6],   [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, nil], [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, nil], [/-/, 8],   [/[a-zA-Z]/, nil], [/[0-9]/, nil], [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]],
    [[/,/, 8],   [/-/, 8],   [/[a-zA-Z]/, 8],   [/[0-9]/, 8],   [/\n/, 10],   [/\s|\t/, 8],  [/.*/, 8]],
    [[/,/, nil], [/-/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, nil], [/\n/, 9],   [/\s|\t/, 9],   [/.*/, nil]],
    [[/,/, nil], [/-/, nil], [/[a-zA-Z]/, nil], [/[0-9]/, nil], [/\n/, nil], [/\s|\t/, nil], [/.*/, nil]]
  ]

  # Token table. Each index, n, represents the token that can be recognised when the
  # lexer is at state n+1.
  @@token_list = [ nil, :comma, :keyword, :number, :number,
                   :number, nil, nil, :whitespace, :comment ]

  def initialize(stream)
    @stream = stream
    @tokens = []
  end

  # Scans the program input and returns an array of tokens in the
  # following format:
  #   { "type" => :keyword, "value" => "STOR", "line" => 3 }
  # Produces a LexicalError exception when lexically invalid input
  # is received.
  def scan
    @tokens << next_token

    if is_eof?
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
            raise Bolverk::ASM::LexicalError, "Disallowed token: #{char}"
          end
        end
      end
    end

    build_token(value)
  end

  def recognizable?
    !!get_token
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
      if value != ""
        { "type" => get_token, "value" => value }
      else
        # Here we append an EOF token to help the parser match the
        # end of the input.
        { "type" => :eof, "value" => nil }
      end
    end
  end

  # Returns the token (if any) for the current state.
  def get_token
    @@token_list[@state - 1]
  end

  # Attempts to match the character against one of the scan rules.
  def get_next_state(char)
    @@scan_table[@state - 1].find(lambda {[0, 1]}) { |rule| char =~ rule[0] }[1]
  end

  def is_whitespace_or_comment?
    [:whitespace, :comment].include?(get_token)
  end

  def is_eof?
    @tokens.last["type"] == :eof
  end

end
