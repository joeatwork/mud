# frozen_string_literal: true

require 'set'

require 'mud/version'
require 'mud/enumerate'
require 'mud/forms'
require 'mud/volumes'
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

  # A pile of explicit sample points
  class Bag
    attr_accessor :bounds

    # empty bags should provide explicit bounds
    # (remember, bounds are exclusive!)
    def initialize(samples, bounds=nil)
      @bag = Set.new samples
      @bounds = if bounds
                  bounds
                else
                  sample_bounds = @bag.reduce do |maxes, pt|
                    maxes.zip(pt).map { |a_b| a_b.max }
                  end
                  sample_bounds.map { |b| b + 1 }
                end
    end

    def sample(*pt)
      @bag.include? pt
    end
  end

  # all samples inside of the circle are visible
  class NSphere
    attr_accessor :bounds

    def initialize(radius, dimensions)
      @radius = radius
      @center = [@radius] * dimensions
      @bounds = @center.map { |c| (c + @radius).ceil + 1}
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

      memo_enum = Mud.enumerate(source).map do |key|
        sample = key.pop
        [key, sample]
      end

      @memo = memo_enum.to_h
    end

    def sample(*pt)
      @memo[pt]
    end
  end

  # Position source inside of some volume. Can translate or crop
  class Arrange
    attr_accessor :bounds

    def initialize(source, location, bounds)
      @source = source
      @source_bounds = source.bounds
      @location = location
      @bounds = bounds

      if location.length != bounds.length
        raise RangeError.new('Location and bounds must have same dimension')
      end
    end

    def sample(*pt)
      if pt.length != @bounds.length
        raise RangeError.new("Form in #{@bounds.length} dimensions can't sample #{pt}")
      end

      translated = @location.zip(pt).map { |(a, b)| b - a }
      in_bounds = translated.zip(@source_bounds).all? do |(p_x, bound_x)|
        p_x < bound_x
      end

      in_bounds && @source.sample(*translated)
    end
  end

  # operation on two samples
  class And
    attr_accessor :bounds

    def initialize(a, b)
      @a = a
      @b = b
      abound = a.bounds
      bbound = b.bounds
      if abound != bbound
        raise RangeError.new("Bounds #{abound} and #{bbound} must match")
      end

      @bounds = abound.zip(bbound).map(&:max)
    end

    def sample(*pt)
      @a.sample(*pt) && @b.sample(*pt)
    end
  end

  # smoother
  class Smooth
    attr_accessor :bounds

    def initialize(source, degree = 1, rounds = 1)
      @source = if rounds > 1
                  Mud::Memo.new(Smooth.new(source, degree, rounds - 1))
                else
                  source
                end
      @degree = degree
      @bounds = @source.bounds
      @offsets = offsets(bounds.length)
    end

    def sample(*pt)
      raise RangeError, 'Bad sample pt arity' if pt.length != @bounds.length

      neighbors = neighborhood(pt)
      raw = @source.sample(*pt)
      count = neighbors.count { |spot| @source.sample(*spot) == raw }

      if count >= @degree
        raw
      elsif neighbors.length <= @degree
        # Don't smooth places where running out of form
        # could cause artifacts
        raw
      else
        !raw
      end
    end

    private

    def offsets(dimension)
      return [[-1], [1]] if dimension == 1

      roots = offsets(dimension - 1) + [[0] * (dimension - 1)]
      area = roots.flat_map do |root|
        [root + [-1], root + [0], root + [1]]
      end

      area.reject { |pt| pt.all?(&:zero?) }
    end

    def neighborhood(pt)
      region = @offsets.map do |off|
        off.zip(pt).map { |off_x, pt_x| off_x + pt_x }
      end

      region.select do |spot|
        spot.zip(@bounds).all? do |spot_x, bound_x|
          spot_x >= 0 && spot_x < bound_x
        end
      end
    end
  end
end
