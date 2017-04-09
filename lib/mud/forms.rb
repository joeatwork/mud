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
end
