# frozen_string_literal: true

# Two-dimensional bodies of samples
module Mud::Forms

  # Each sample at 50% probability
  class Noise
    def initialize(size, seed = nil)
      seed ||= Random.new_seed

      @size = size
      sample_count = @size * @size
      @all_samples = Random.new(seed).bytes(1 + (sample_count >> 3)).bytes
    end

    def bounds
      [@size, @size]
    end

    def sample(row, col)
      ix = row * @size + col
      byte = ix >> 3
      bit_ix = ix & 7
      bit = 1 << bit_ix
      (@all_samples[byte] & bit).zero?
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

      roots = offsets(dimension - 1)
      roots.flat_map do |root|
        [root + [-1], root + [0], root + [1]]
      end
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
