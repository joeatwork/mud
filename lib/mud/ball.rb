# frozen_string_literal: true

module Mud
  # Source of samples at integer coordinates
  class Ball
    attr_accessor :size, :all_samples

    def initialize(size)
      size_with_fringe = size.to_i + 2
      r = Random.new

      @size = size_with_fringe
      @all_samples = Array.new(size_with_fringe * size_with_fringe) do |ix|
        row = ix / size_with_fringe
        col = ix % size_with_fringe

        use_col = col > 0 && col < size + 1
        use_row = row > 0 && row < size + 1
        use_row && use_col && r.rand(2) == 1
      end
    end

    def coords
      Enumerator.new do |y|
        (@size * @size).times do |i|
          y << [i % @size, i / @size]
        end
      end
    end

    def in_bounds(row, col)
      ret = row >= 0 && col >= 0 && row < @size && col < @size
      ret
    end

    def sample(row, col)
      @all_samples[col * @size + row]
    end
  end
end
