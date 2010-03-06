class Bolverk::ASM::Parser

  # A table-driven parser for Bolverk assembly. Consumes an input program
  # and generates a parse tree from it's contents.

  # FIRST
  #  program { keyword $ }
  #  statement_list { keyword }
  #  statement { keyword }
  #  number_list { number }
  #  number_list_tail { , }

  # FOLLOW
  #  "comma" { number }
  #  "keyword" { number }
  #  "number" { comma keyword $ }
  #  "$" { }
  #  program { }
  #  statement_list { $ }
  #  statement { keyword $ }
  #  number_list { keyword $ }
  #  number_list_tail { keyword $ }

  # PREDICT
  #  1. program           --> statement_list $ { keyword $ }
  #  2. statement_list    --> statement statement_list { keyword }
  #  3. statement_list    --> EPS { $ }
  #  4. statement         --> "keyword" number_list { keyword }
  #  5. number_list       --> "number" number_list_tail { number }
  #  6. number_list_tail  --> "comma" "number" number_list_tail { comma }
  #  7. number_list_tail  --> EPS { keyword $ }

  @@parse_table = {
    :program =>          { :keyword => nil, :number => nil, :comma => nil, :eof => nil },
    :statement_list =>   { :keyword => nil, :number => nil, :comma => nil, :eof => nil },
    :statement =>        { :keyword => nil, :number => nil, :comma => nil, :eof => nil },
    :number_list =>      { :keyword => nil, :number => nil, :comma => nil, :eof => nil },
    :number_list_tail => { :keyword => nil, :number => nil, :comma => nil, :eof => nil }
  }

  @production_table = [
    [:statement_list, :eof],              # program
    [:statement, :statement_list],        # statement_list
    [:eof],                               # statement_list
    [:keyword, :number_list],             # statement
    [:number, :number_list_tail],         # number_list
    [:comma, :number, :number_list_tail], # number_list_tail
    [:eof]                                # number_list_tail
  ]

  def initialize

  end

end
