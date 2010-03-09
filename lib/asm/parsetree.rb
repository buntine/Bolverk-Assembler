class Bolverk::ASM::ParseTree < Array

  # An abstraction of the typical array to help build and maintain
  # a parse tree data structure.

  def initialize(root_node)
    super()
    self << root_node
  end

  # Updates the node at 'path' with the given token.
  # The token is wrapped in an array to preserve the tree
  # tree structure.
  def set_node_by_path(path, token)
    parent = self.node_for_path(path.butlast)
    parent[path.last] = [token]
  end

  # Returns the node of the parse tree that corresponds to the given
  # path. [1 2 1] --> self[1][2][1]
  def node_for_path(path, subtree=self, index=0)
    if index == path.length
      subtree
    else
      node_for_path(path, subtree[path[index]], index + 1)
    end
  end

  # Inserts a prediction (in the form of a production rule) into the
  # tree at the given path.
  def insert_prediction(path, production)
    node = self.node_for_path(path)
    production.each do |p|
      node << [p]
    end
  end

  # Searches back up the tree until a non-expended branch is found.
  # Returns a path to said branch or nil.
  def find_suitable_branch(remaining_path, index)
    butlast = remaining_path.butlast
    node = self.node_for_path(butlast)

    # Base-case - We found one!
    if node.length > index + 1
      butlast + [remaining_path.last + 1]
    else
      find_suitable_branch(butlast, butlast.last)
    end
  end

  # Helper method to increment the given tree path:
  #  [1 2 1] --> [1 2 2]
  def increment_path(path)
    path.butlast + [path.last + 1]
  end

  # Helper method to extend the given tree path:
  # [1 2 1] -> [1 2 1 1]
  def extend_path(path)
    path + [1]
  end

end
