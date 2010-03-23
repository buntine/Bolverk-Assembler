module Bolverk::ASM::Procedures

  # This module provides a substitution method for each procedure
  # defined in Bolverk assembly.
  # Each member of the hash in the procedures method should
  # define the method of evaluation and additional metadata such as
  # the number and type of arguments required, etc.

  def procedures
    { "meml" => { :args => [:register, :memory_cell],
                  :method => lambda do |r, mc|
                               "1" + h(r) + h(mc)
                             end },
      "vall" => { :args => [:register, :value],
                  :method => lambda do |r, v|
                               "2" + h(r) + h(v)
                             end },
      "stor" => { :args => [:register, :memory_cell],
                  :method => lambda do |r, mc|
                               "3" + h(r) + h(mc)
                             end },
      "move" => { :args => [:register, :register],
                  :method => lambda do |ra, rb|
                               "40" + h(ra) + h(rb)
                             end },
      "badd" => { :args => [:register, :register, :register],
                  :method => lambda do |ra, rb, rc|
                               "5" + h(ra) + h(rb) + h(rc)
                             end },
      "fadd" => { :args => [:register, :register, :register],
                  :method => lambda do |ra, rb, rc|
                               "6" + h(ra) + h(rb) + h(rc)
                             end },
      "or"   => { :args => [:register, :register, :register],
                  :method => lambda do |ra, rb, rc|
                               "7" + h(ra) + h(rb) + h(rc)
                             end },
      "and"  => { :args => [:register, :register, :register],
                  :method => lambda do |ra, rb, rc|
                               "8" + h(ra) + h(rb) + h(rc)
                             end },
      "xor"  => { :args => [:register, :register, :register],
                  :method => lambda do |ra, rb, rc|
                               "9" + h(ra) + h(rb) + h(rc)
                             end },
      "rot"  => { :args => [:register, :register],
                  :method => lambda do |r, n|
                               "a" + h(r) + "0" + h(n)
                             end },
      "jump" => { :args => [:register, :memory_cell],
                  :method => lambda do |r, mc|
                               "b" + h(r) + h(mc)
                             end },
      "halt" => { :args => [],
                  :method => lambda do
                               "c000"
                             end },
      "pmch" => { :args => [:memory_cell],
                  :method => lambda do |mc|
                               "d0" + h(mc)
                             end },
      "pmde" => { :args => [:memory_cell],
                  :method => lambda do |mc|
                               "d1" + h(mc)
                             end },
      "pmfp" => { :args => [:memory_cell],
                  :method => lambda do |mc|
                               "d2" + h(mc)
                             end },
      "pvch" => { :args => [:memory_cell],
                  :method => lambda do |mc|
                               "e0" + h(mc)
                             end },
      "pvde" => { :args => [:memory_cell],
                  :method => lambda do |mc|
                               "e1" + h(mc)
                             end },
      "pvfp" => { :args => [:memory_cell],
                  :method => lambda do |mc|
                               "e2" + h(mc)
                             end },
      "writ" => { :args => [:value, :memory_cell],
                  :method => lambda do |v, mc|
                               [ "2f" + h(v),
                                 "3f" + h(mc) ].join("\n")
                             end },
      "pvds" => { :args => [:register, :register],
                  :method => lambda do |ra, rb|
                               [ "5" + h(ra) + h(rb) + "f",
                                 "3fff",
                                 "d1ff" ].join("\n")
                             end } }
  end

  # Returns true if the given procedure/mnemonic exists.
  def mnemonic_exists?(token)
    procedures.include?(p_name(token))
  end

  # Accepts a valid program token and applies the corresponding
  # generating method to it.
  def eval_procedure(token, args=[])
    arguments = validate_and_format_args(token, args)

    procedures[p_name(token)][:method].call(*arguments)
  end

 private

  # Converts arguments into valid numbers.
  # Also asserts each argument falls within it's valid
  # range. Otherwise, a SemanticError is raised.
  def validate_and_format_args(token, args)
    arguments = []
    name = p_name(token)
    arg_types = procedures[name][:args]

    ranges = { :memory_cell => (0..255),
               :value      => (-128..127),
               :register    => (0..15) }

    unless arg_types.length == args.length
      raise Bolverk::ASM::SemanticError, "Procedure #{name} requires #{arg_types.length} arguments. Given #{args.length}."
    end

    # Format each argument into a valid number. Also make sure
    # it fits within the range we expect.
    arg_types.each_with_index do |arg_type, i|
      range = ranges[arg_type]
      value = args[i].value

      # If it's a character, just convert it to an integer and let it through.
      if value =~ /^\D$/ and arg_type == :value
        arguments << value[0]
      else
        v = value.to_i
        if range.include?(v)
          arguments << ((arg_type == :value) ? twos_complement(v) : v)
        else
          raise Bolverk::ASM::SemanticError, "Cannot store signed integer #{v} in one byte."
        end
      end
    end

    arguments
  end

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
    if signed_int < 0
      (128 + (128 - signed_int.abs))
    else
      signed_int
    end
  end

end
