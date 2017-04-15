# frozen_string_literal: true

require 'set'

require 'mud/enumerate'

# Two-dimensional bodies of samples
module Mud::Forms

  class Noise
    attr_accessor :bounds

    def initialize(size, dimensions, probability, seed = nil)
      seed ||= Random.new_seed
      p = [probability, 1.0 - probability].min

      @bounds = [size] * dimensions
      @invert = p < probability
      @pts = Set.new

      randoms = Random.new(seed)
      Mud.enumerate_bounds(bounds).each do |pt|
        @pts.add(pt) if randoms.rand < p
      end
    end

    def sample(*pt)
      @pts.include?(pt) ^ @invert
    end
  end

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
      pt_distance = pt.zip(@center).reduce(0) do |s, (x, c)|
        dx = x - c
        s += dx * dx
        s
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

  class Filter
    attr_accessor :bounds

    # Block should take a region and return a boolean sample
    def initialize(source, &block)
      @bounds = source.bounds
      @offsets = offsets(@bounds.length)
      @source = Memo.new(source)
      @fn = block
    end

    def sample(*pt)
      r = region(pt)
      @fn.call(r)
    end

    private

    def offsets(dimension)
      return [[-1], [0], [1]] if dimension == 1

      roots = offsets(dimension - 1)
      roots.flat_map do |root|
        [root + [-1], root + [0], root + [1]]
      end
    end

    def region(pt)
      mapped = @offsets.map do |off|
        spot = off.zip(pt).map { |off_x, pt_x| off_x + pt_x }
        inbounds = spot.zip(@bounds).all? do |spot_x, bound_x|
          spot_x >= 0 && spot_x < bound_x
        end

        if inbounds
          sampled = @source.sample(*spot)
          [off, sampled]
        else
          nil
        end
      end

      mapped.compact
    end
  end
end
