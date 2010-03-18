module Bolverk::ASM::Procedures

  # This module provides a substitution method for each procedure
  # defined in Bolverk assembly.
  # Each method starting with "proc_" should generate and return
  # the correct machine code for it's operation.

  def proc_stor(register, memory_cell)
    "3" + h(register) + h(memory_cell)
  end

  def proc_load(register, value)
    puts register
    puts value
    "2" + h(register) + h(value)
  end

  # Semantic check to ensure given procedure exists.
  def assert_proc_exists(token)
    name = proc_name(token)
    unless self.respond_to?("proc_#{name}")
      raise Bolverk::ASM::SemanticError, "Unknown procedure: #{name}"
    end
  end

  # Sementic check to ensure the given procedure
  # will accept the given arguments.
  def assert_correct_args(token, args)
    name = proc_name(token)
    arg_count = { "load" => 2, "stor" => 2 }

    unless arg_count[name] == args.length
      raise Bolverk::ASM::SemanticError, "Procedure #{name} requires #{arg_count[name]} arguments. Given #{args.length}."
    end
  end

  # Accepts a valid program token and applies the corresponding
  # generating method to it.
  def eval_procedure(token, args)
    arguments = args.map { |a| a.value }

    self.send("proc_#{proc_name(token)}", *arguments)
  end

 private

  # Converts number to base-16. It's name is so short as it's utilised
  # very often.
  def h(number)
    number.to_s(16)
  end

  def proc_name(token)
    token.value.downcase
  end
end
