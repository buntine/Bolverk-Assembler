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

  def initialize

  end

end
