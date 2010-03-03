# Lexical analyser for Bolverk assembly.

class Bolverk::ASM::Lexer

  @@scan_table = [
    {"," => 2,   "-" => 6,   /a-zA-Z/ => 3,   /0-9/ => 4,   /\n/ => 9,   /\s|\t/ => 9}
    {"," => nil, "-" => nil, /a-zA-Z/ => nil, /0-9/ => nil, /\n/ => nil, /\s|\t/ => nil}
    {"," => nil, "-" => nil, /a-zA-Z/ => 3,   /0-9/ => nil, /\n/ => nil, /\s|\t/ => nil}
    {"," => nil, "-" => nil, /a-zA-Z/ => nil, /0-9/ => 5,   /\n/ => nil, /\s|\t/ => nil}
    {"," => nil, "-" => nil, /a-zA-Z/ => nil, /0-9/ => nil, /\n/ => nil, /\s|\t/ => nil}
    {"," => nil, "-" => 7,   /a-zA-Z/ => nil, /0-9/ => nil, /\n/ => nil, /\s|\t/ => nil}
    {"," => 7,   "-" => 7,   /a-zA-Z/ => 7,   /0-9/ => 7,   /\n/ => 10,  /\s|\t/ => 7}
    {"," => nil, "-" => nil, /a-zA-Z/ => nil, /0-9/ => nil, /\n/ => 8,   /\s|\t/ => 8}
    {"," => nil, "-" => nil, /a-zA-Z/ => nil, /0-9/ => nil, /\n/ => nil, /\s|\t/ => nil}
  ]

  @@token_tab = [
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

end
