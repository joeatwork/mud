
module Mud::Util
  class UnionFind
    attr_accessor :rank, :parent, :val

    def initialize(val, parent)
      @val = val
      @parent = parent
      @rank = 0
    end

    def root
      p = self
      p = p.parent while p.parent
      p
    end

    def union(other)
      a_root = root
      b_root = other.root

      if a_root == b_root
        # Do nothing, we're already together
      elsif a_root.rank < b_root.rank
        a_root.parent = b_root
      elsif b_root.rank < a_root.rank
        b_root.parent = a_root
      else
        b_root.parent = a_root
        a_root.rank += 1
      end
    end
  end

  def self.offsets(dimension)
    return [[-1], [0], [1]] if dimension == 1

    roots = offsets(dimension - 1)
    roots.flat_map do |root|
      [root + [-1], root + [0], root + [1]]
    end
  end
end
