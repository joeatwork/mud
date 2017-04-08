# frozen_string_literal: true

require 'mud/version'
require 'mud/enumerate'
require 'mud/forms'
require 'mud/renderer'
require 'mud/mesher'

module Mud
  # Allow callers to just use some arbitrary block for samples
  class Fn
    attr_accessor :bounds

    def initialize(bounds, &block)
      @fn = block
      @bounds = bounds
    end

    def sample(*pt)
      @fn.call(*pt)
    end
  end

  # Saves results of potentially expensive child sources
  class Memo
    attr_accessor :bounds

    def initialize(source)
      @bounds = source.bounds

      memo_enum = Mud.enumerate(source).map do |(row, col, sample)|
        [[row, col], sample]
      end

      @memo = memo_enum.to_h
    end

    def sample(*pt)
      @memo[pt]
    end
  end

  # operation on two samples
  class And
    def initialize(a, b)
      @a = a
      @b = b
    end

    def bounds
      @a.bounds.zip(@b.bounds).map(&:max)
    end

    def sample(*pt)
      @a.sample(*pt) && @b.sample(*pt)
    end
  end
end
