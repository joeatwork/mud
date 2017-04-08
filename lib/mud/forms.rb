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
    def initialize(source, degree = 1, rounds = 1)
      @source = if rounds > 1
                  Mud::Memo.new(Smooth.new(source, degree, rounds - 1))
                else
                  source
                end
      @degree = degree
    end

    def bounds
      @source.bounds
    end

    def sample(row, col)
      offsets = [[-1, -1], [0, -1], [1, -1],
                 [-1,  0],          [1,  0],
                 [-1,  1], [0,  1], [1,  1]]

      region = offsets.map { |o_r, o_c| [row + o_r, col + o_c]}

      # neighbors are in bounds
      xmax, ymax = bounds
      neighbors = region.select do |(r, c)|
        c >= 0 && r >= 0 && c < xmax && r < ymax
      end

      raw = @source.sample(row, col)
      count = neighbors.count { |x, y| @source.sample(x, y) == raw }

      if count >= @degree
        raw
      else
        !raw
      end
    end
  end
end
