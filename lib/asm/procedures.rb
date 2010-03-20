module Bolverk::ASM::Procedures

  # This module provides a substitution method for each procedure
  # defined in Bolverk assembly.
  # Each method starting with "proc_" should generate and return
  # the correct machine code for it's operation.

  def proc_meml(register, memory_cell)
    "1" + h(register) + h(memory_cell)
  end

  def proc_vall(register, value)
    "2" + h(register) + h(value)
  end

  def proc_stor(register, memory_cell)
    "3" + h(register) + h(memory_cell)
  end

  def proc_move(a, b)
    "40" + h(a) + h(b)
  end

  def proc_badd(a, b, result)
    "5" + h(a) + h(b) + h(result)
  end

  def proc_fadd(a, b, result)
    "6" + h(a) + h(b) + h(result)
  end

  def proc_or(a, b, result)
    "7" + h(a) + h(b) + h(result)
  end

  def proc_and(a, b, result)
    "8" + h(a) + h(b) + h(result)
  end

  def proc_xor(a, b, result)
    "9" + h(a) + h(b) + h(result)
  end

  def proc_rot(register, times)
    "a" + h(register) + "0" + h(times)
  end

  def proc_jump(register, memory_cell)
    "b" + h(register) + h(memory_cell)
  end

  def proc_pmch(memory_cell)
    "d0" + h(memory_cell)
  end

  def proc_pmde(memory_cell)
    "d1" + h(memory_cell)
  end

  def proc_pmfp(memory_cell)
    "d2" + h(memory_cell)
  end

  def proc_pvch(memory_cell)
    "e0" + h(memory_cell)
  end

  def proc_pvde(memory_cell)
    "e1" + h(memory_cell)
  end

  def proc_pvfp(memory_cell)
    "e2" + h(memory_cell)
  end

  def proc_writ(value, memory_cell)
    [ proc_vall("F", value),
      proc_stor("F", memory_cell) ].join("\n")
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
  # TODO: Work out better way to encode the argument
  #       count for each procedure.
  def assert_correct_args(token, args)
    name = p_name(token)
    arg_count = { "meml" => 2, "vall" => 2, "stor" => 2, "move" => 2,
                  "badd" => 3, "fadd" => 3, "or" => 3, "and" => 3,
                  "xor" => 3, "rot" => 2, "jump" => 2, "pmch" => 1,
                  "pmde" => 1, "pmfp" => 1, "pvch" => 1, "pvde" => 1,
                  "pvfp" => 1 }

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
