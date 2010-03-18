module Bolverk::ASM::Procedures

  # This module provides a substitution method for each procedure
  # defined in Bolverk assembly.
  # Each method starting with "proc_" should generate and return
  # the correct machine code for it's operation.

  def proc_stor(register, memory_cell)
    "3" + h(register) + h(memory_cell)
  end

  def proc_load(register, value)
    "2" + h(register) + h(value)
  end

  def proc_badd(a, b, result)
    "5" + h(a) + h(b) + h(result)
  end

  def proc_pmde(memory_cell)
    "d1" + h(memory_cell)
  end

  # Semantic check to ensure given procedure exists.
  def assert_proc_exists(token)
    name = p_name(token)
    unless self.respond_to?("proc_#{name}")
      raise Bolverk::ASM::SemanticError, "Unknown procedure: #{name}"
    end
  end

  # Sementic check to ensure the given procedure
  # will accept the given arguments.
  def assert_correct_args(token, args)
    name = p_name(token)
    arg_count = { "load" => 2, "stor" => 2, "badd" => 3, "pmde" => 1 }

    unless arg_count[name] == args.length
      raise Bolverk::ASM::SemanticError, "Procedure #{name} requires #{arg_count[name]} arguments. Given #{args.length}."
    end
  end

  # Accepts a valid program token and applies the corresponding
  # generating method to it.
  def eval_procedure(token, args)
    # This will convert ASCII chars to their decimal equivelent, also.
    arguments = args.map do |a|
      v = a.value
      (v =~ /^\d+$/) ? v.to_i : v[0]
    end

    self.send("proc_#{p_name(token)}", *arguments)
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
end
