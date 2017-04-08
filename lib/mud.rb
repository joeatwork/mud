# frozen_string_literal: true

require 'set'

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

  class Bag
    attr_accessor :bounds

    # empty bags should provide explicit bounds
    def initialize(samples, bounds=nil)
      @bag = Set.new samples
      @bounds = bounds || @bag.reduce do |maxes, pt|
        maxes.zip(pt).map { |a_b| a_b.max }
      end
    end

    def sample(*pt)
      @bag.include? pt
    end
  end

  # all samples inside of the circle are visible
  class NSphere
    def initialize(radius, center)
      @radius = radius
      @center = center
    end

    def bounds
      @center.map { |c| (c + @radius).ceil }
    end

    def sample(*pt)
      pt_distance = pt.zip(@center).sum do |x, c|
        dx = x - c
        dx * dx
      end
      pt_distance < @radius * @radius
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
