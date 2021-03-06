class Array
  # Push, but on the first index.
  def fpush(value)
    self.insert(0, value)
  end

  # Returns everything except the last element.
  def butlast
    if self.empty?
      []
    else
      self[0..-2]
    end
  end

  # Returns everything except the first element (Lisp-style cdr).
  def butfirst
    if self.empty?
      []
    else
      self[1..-1]
    end
  end

end
