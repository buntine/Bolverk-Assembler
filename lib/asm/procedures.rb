module Bolverk::ASM::Procedures

  # This module provides a substitution method for each procedure
  # defined in Bolverk assembly.
  # Each method starting with "proc_" should generate and return
  # the correct machine code for it's operation.

  def proc_stor(register, memory_cell)
    "3" + h(register) + h(memory_cell)
  end

  # Semantic check to ensure given procedure exists.
  def assert_proc_exists(name)
    self.respond_to?("proc_#{name}")
  end

  # Sementic check to ensure the given procedure
  # will accept the given arguments.
  def assert_correct_args(name, args)
    # TODO: Implement.
    true
  end

 private

  # Converts number to base-16. It's name is so short as it's utilised
  # very often.
  def h(number)
    number.to_s(16)
  end

end
