# frozen_string_literal: true

module Mud
  # Source of samples at integer coordinates
  class Ball
    attr_accessor :size

    def initialize(size)
      @size = size
      sample_count = @size * @size
      @all_samples = Random.new.bytes(1 + (sample_count >> 3)).bytes
    end

    def coords
      Enumerator.new do |result|
        @size.times do |x|
          @size.times do |y|
            result << [x, y]
          end
        end
      end
    end

    def in_bounds(row, col)
      row >= 0 && col >= 0 && row < @size && col < @size
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
