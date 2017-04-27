# frozen_string_literal: true

require 'set'

require 'mud/enumerate'
require 'mud/util'

# Two-dimensional bodies of samples
module Mud::Forms

  # Random pixelated noise
  class Noise
    attr_reader :offset
    attr_reader :bounds

    def initialize(size, dimensions, probability, seed = nil)
      seed ||= Random.new_seed
      p = [probability, 1.0 - probability].min

      @offset = [0] * dimensions
      @bounds = [size] * dimensions
      @invert = p < probability
      @pts = Set.new

      randoms = Random.new(seed)
      Mud.enumerate_bounds(offset, bounds).each do |pt|
        @pts.add(pt) if randoms.rand < p
      end
    end

    def sample(*pt)
      @pts.include?(pt) ^ @invert
    end
  end

  # Allow callers to just use some arbitrary block for samples
  class Fn
    attr_reader :offset
    attr_reader :bounds

    def initialize(offset, bounds, &block)
      @fn = block
      @bounds = bounds
      @offset = offset
    end

    def sample(*pt)
      @fn.call(*pt)
    end
  end

  # A pile of explicit sample points
  class Bag
    attr_reader :offset
    attr_reader :bounds

    # empty bags should provide explicit bounds
    # (remember, bounds are exclusive!)
    def initialize(samples, offset = nil, bounds = nil)
      if (bounds || offset) && !(bounds && offset)
        raise 'Must provide both or neither of bounds and offset'
      end

      @bag = Set.new samples
      if bounds
        @bounds, @offset = bounds, offset
      else
        @offset = @bag.reduce do |m, pt|
          m.zip(pt).map(&:min)
        end

        maxes = @bag.reduce do |m, pt|
          m.zip(pt).map(&:max)
        end

        maxes_plus = maxes.map { |b| b + 1 }

        @bounds = maxes_plus.zip(@offset).map { |x, off| x - off }
      end
    end

    def sample(*pt)
      @bag.include? pt
    end
  end

  # Saves results of potentially expensive child sources
  class Memo
    attr_reader :offset
    attr_reader :bounds

    def initialize(source)
      @offset = source.offset
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

  # Expands or contracts the "canvas" around a source, protecting the source bounds.
  # Can be used to crop or pad a form
  class Arrange
    attr_reader :offset
    attr_reader :bounds

    def initialize(source, offset, bounds)
      if offset.length != bounds.length
        raise(RangeError, 'offset and bounds must have same dimension')
      end

      @source = source
      @s_bounds = source.bounds
      @s_offset = source.offset
      @offset = offset
      @bounds = bounds
    end

    def sample(*pt)
      in_bounds = pt.zip(@s_offset, @s_bounds).all? do |(x, off, bound)|
        x >= off && x < (off + bound)
      end

      in_bounds && @source.sample(*translated)
    end
  end

  # operation on two samples
  class And
    attr_reader :offset
    attr_reader :bounds

    def initialize(a, b)
      abound = a.bounds
      bbound = b.bounds
      raise(RangeError, 'Bounds must match') if abound != bbound

      aoffset = a.offset
      boffset = b.offset
      raise(RangeError, 'Offsets must match') if aoffset != boffset

      @a = a
      @b = b
      @offset = aoffset
      @bounds = abound
    end

    def sample(*pt)
      @a.sample(*pt) && @b.sample(*pt)
    end
  end

  class Layers
    attr_reader :bounds
    attr_reader :offset

    def initialize(ls)
      @ls = ls.to_a

      raise(RangeError, 'Zero layers not supported') if @ls.empty?

      b0 = @ls[0].bounds
      off0 = @ls[0].offset

      unless @ls.all? { |layer| layer.bounds == b0 && layer.offset == off0 }
        raise(ArgumentError, 'Layer bounds and offsets must match')
      end

      @bounds = b0 + [@ls.length]
      @offset = off0 + [0]
    end

    def sample(*pt)
      layer = @ls[pt.pop]
      layer.sample(*pt)
    end
  end

  class Islands
    attr_reader :bounds
    attr_reader :offset

    def initialize(source, number, min_size = 1)
      @bounds = source.bounds
      @offset = source.offset

      population = Mud.enumerate(source).select(&:last).map do |lis|
        lis.pop
        lis
      end
      all_regions = regions(population)
      big_regions = all_regions.select { |r| r.length >= min_size }
      big_regions.sort! { |a, b| b.length <=> a.length }
      vals = big_regions[0...number].flatten(1)
      @vals = Set.new(vals)
    end

    def sample(*pt)
      @vals.include?(pt)
    end

    def regions(pop)
      offs = Mud::Util.offsets(@bounds.length).reject { |pt| pt.all?(&:zero?) }
      unions = pop.map { |x| [x, Mud::Util::UnionFind.new(x, nil)] }.to_h
      unions.each do |(pt, union)|
        root = union.root
        offs.each do |offset|
          neighbor = pt.zip(offset).map { |x, off_x| x + off_x }
          n_root = unions[neighbor]&.root
          if n_root.nil?
            # nothing, we're out of bounds
          elsif n_root == root
            # nothing, we're already in union
          elsif n_root.rank < root.rank
            root.parent = n_root
          else
            n_root.parent = root
          end
        end
      end

      regions = {}
      unions.each do |(pt, union)|
        rt = union.root
        regions[rt] ||= []
        regions[rt] << pt
      end

      regions.values
    end
  end

  class Filter
    attr_reader :bounds
    attr_reader :offset

    # Block should take two arguments - the pt, and a "region"
    # the region is a list of offsets + [samples]
    def initialize(source, &block)
      @bounds = source.bounds
      @offset = source.offset

      @neighborhood = Mud::Util.neighborhood(@bounds.length)
      @source = Memo.new(source)
      @fn = block
    end

    def sample(*pt)
      r = region(pt)
      @fn.call(pt, r)
    end

    private

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
