module Bolverk::ASM::Procedures

  # This module provides a substitution method for each procedure
  # defined in Bolverk assembly.
  # Each member of the hash in the procedures method should
  # define the method of evaluation and additional metadata such as
  # the number of arguments required, etc.

  def procedures
    { "meml" => { :args => 2,
                  :method => lambda do |r, mc|
                               "1" + h(r) + h(mc)
                             end },
      "vall" => { :args => 2,
                  :method => lambda do |r, mc|
                               "2" + h(r) + h(mc)
                             end },
      "stor" => { :args => 2,
                  :method => lambda do |r, mc|
                               "3" + h(r) + h(mc)
                             end },
      "move" => { :args => 2,
                  :method => lambda do |ra, rb|
                               "40" + h(ra) + h(rb)
                             end },
      "badd" => { :args => 3,
                  :method => lambda do |ra, rb, rc|
                               "5" + h(ra) + h(rb) + h(rc)
                             end },
      "fadd" => { :args => 3,
                  :method => lambda do |ra, rb, rc|
                               "6" + h(ra) + h(rb) + h(rc)
                             end },
      "or"   => { :args => 3,
                  :method => lambda do |ra, rb, rc|
                               "7" + h(ra) + h(rb) + h(rc)
                             end },
      "and"  => { :args => 3,
                  :method => lambda do |ra, rb, rc|
                               "8" + h(ra) + h(rb) + h(rc)
                             end },
      "xor"  => { :args => 3,
                  :method => lambda do |ra, rb, rc|
                               "9" + h(ra) + h(rb) + h(rc)
                             end },
      "rot"  => { :args => 2,
                  :method => lambda do |r, n|
                               "a" + h(r) + h(n)
                             end },
      "jump" => { :args => 2,
                  :method => lambda do |r, mc|
                               "b" + h(r) + h(mc)
                             end },
      "halt" => { :args => 0,
                  :method => lambda do
                               "c000"
                             end },
      "pmch" => { :args => 1,
                  :method => lambda do |mc|
                               "d0" + h(mc)
                             end },
      "pmde" => { :args => 1,
                  :method => lambda do |mc|
                               "d1" + h(mc)
                             end },
      "pmfp" => { :args => 1,
                  :method => lambda do |mc|
                               "d2" + h(mc)
                             end },
      "pvch" => { :args => 1,
                  :method => lambda do |mc|
                               "e0" + h(mc)
                             end },
      "pvde" => { :args => 1,
                  :method => lambda do |mc|
                               "e1" + h(mc)
                             end },
      "pvfp" => { :args => 1,
                  :method => lambda do |mc|
                               "e2" + h(mc)
                             end },
      "writ" => { :args => 2,
                  :method => lambda do |v, mc|
                               [ "2f" + h(v),
                                 "3f" + h(mc) ].join("\n")
                             end } }
  end

  # Semantic check to ensure given procedure exists.
  def assert_proc_exists(token)
    name = p_name(token)
    unless procedures.include?(name)
      raise Bolverk::ASM::SemanticError, "Unknown procedure: #{name}"
    end
  end

  # Sementic check to ensure the given procedure
  # will accept the given arguments.
  def assert_correct_args(token, args)
    name = p_name(token)

    unless procedures[name][:args] == args.length
      raise Bolverk::ASM::SemanticError, "Procedure #{name} requires #{procedures[name][:args]} arguments. Given #{args.length}."
    end
  end

  # Accepts a valid program token and applies the corresponding
  # generating method to it.
  def eval_procedure(token, args=[])
    # Convert signed integers and ASCII characters.
    arguments = args.map do |a|
      if a.value =~ /^\-?\d+$/
        twos_complement(a.value.to_i)
      else
        a.value[0]
      end
    end

    procedures[p_name(token)][:method].call(*arguments)
  end

 private

  # Converts number to base-16. It's name is so short as it's utilised
  # very often.
  def h(number)
    number.to_s(16)
  end

  def p_name(token)
    token.value.downcase
  end

  # Converts a signed integer into a number ready for encoding in two's
  # complement. Raises a SemanticError if the value falls outside of the
  # acceptable range.
  def twos_complement(signed_int)
    if (-128..0).include?(signed_int)
      (128 + (128 - signed_int.abs))
    elsif (1..127).include?(signed_int)
      signed_int
    else
      raise Bolverk::ASM::SemanticError, "Cannot store signed integer #{signed_int} in 8 bits."
    end
  end

end
