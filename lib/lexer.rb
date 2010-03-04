# Lexical analyser for Bolverk assembly.

module Bolverk
  module ASM
  end
end

class Bolverk::ASM::LexicalError < RuntimeError
end

class Bolverk::ASM::Lexer

  @@scan_table = [
    [[/,/, 2],   [/-/, 6],   [/a-zA-Z/, 3],   [/0-9/, 4],   [/\n/, 9],   [/\s|\t/, 9]],
    [[/,/, nil], [/-/, nil], [/a-zA-Z/, nil], [/0-9/, nil], [/\n/, nil], [/\s|\t/, nil]],
    [[/,/, nil], [/-/, nil], [/a-zA-Z/, 3],   [/0-9/, nil], [/\n/, nil], [/\s|\t/, nil]],
    [[/,/, nil], [/-/, nil], [/a-zA-Z/, nil], [/0-9/, 5],   [/\n/, nil], [/\s|\t/, nil]],
    [[/,/, nil], [/-/, nil], [/a-zA-Z/, nil], [/0-9/, nil], [/\n/, nil], [/\s|\t/, nil]],
    [[/,/, nil], [/-/, 7],   [/a-zA-Z/, nil], [/0-9/, nil], [/\n/, nil], [/\s|\t/, nil]],
    [[/,/, 7],   [/-/, 7],   [/a-zA-Z/, 7],   [/0-9/, 7],   [/\n/, 9],   [/\s|\t/, 7]],
    [[/,/, nil], [/-/, nil], [/a-zA-Z/, nil], [/0-9/, nil], [/\n/, 8],   [/\s|\t/, 8]],
    [[/,/, nil], [/-/, nil], [/a-zA-Z/, nil], [/0-9/, nil], [/\n/, nil], [/\s|\t/, nil]]
  ]

  @@token_list = [
    nil,
    :comma,
    :keyword,
    :number,
    :number,
    nil,
    nil,
    :whitespace,
    :comment,
  ]

  def initialize(stream)
    @stream = stream
    @tokens = []
    @state = 1
  end

  # Scans the program input and returns an array of tokens in the
  # following format:
  #   { "type" => :keyword, "value" => "STOR", "line" => 3 }
  def scan
  end

 private

  # Attempts to find the next token in the stream.
  def next_token()
    char = @stream.read(1)
    value = []
    next_state = get_next_state(char)
    remembered_state = 0
    remembered_chars = []

    while true
      # Move to the next state.
      if next_state
        if recognizable?
          remembered_chars = []
          remembered_state = @state
        end

        value << char
        remembered_chars << char
        @state = next_state
        next
      else
        # Recognise the final token.
        if recognizable?
          @stream.seek(@stream.pos - 1)
          break
        else
          # Recoverable error.
          if remembered_state > 0
            @state = remembered_state
            @stream.seek(@stream.pos - remembered_chars.length)
            value = value.filter { |c| !remembered_chars.include?(c) }
            break
          # Fatal lexical error.
          else
            raise Bolverk::ASM::LexicalError "Disallowed token: #{char}"
          end
        end
      end
    end

    if is_whitespace_or_comment?
      @state = 1
      next_token
    else
      { "type" => @@token_list[@state], "value" => value.join("") }
    end
  end

  def recognizable?
    !!@@token_list[@state]
  end

  # Attempts to match the character against one of the scan rules.
  def get_next_state(char)
    @@scan_table[@state].find(lambda {[0, 1]}) { |rule| char =~ rule[0] }[1]
  end

  def is_whitespace_or_comment?
    [8, 9].include?(@state)
  end

end
