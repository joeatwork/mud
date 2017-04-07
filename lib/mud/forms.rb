# frozen_string_literal: true

module Mud
  # Forms return inside/outside samples with sample
  class Noise
    def initialize(size)
      @size = size
      sample_count = @size * @size
      @all_samples = Random.new.bytes(1 + (sample_count >> 3)).bytes
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

  # all samples inside of the circle are visible
  class Circle
    def initialize(radius, center_x, center_y)
      @radius = radius
      @center_x = center_x
      @center_y = center_y
    end

    def bounds
      [@radius + @center_x, @radius + @center_y]
    end

    def sample(row, col)
      dx = col - @center_x
      dy = row - @center_y
      dx * dx + dy * dy < @radius * @radius
    end
  end

  # operation on two forms
  class And
    def initialize(a, b)
      @a = a
      @b = b
    end

    def bounds
      ax, ay = @a.bounds
      bx, by = @b.bounds
      [[ax, bx].max, [ay, by].max]
    end

    def sample(row, col)
      @a.sample(row, col) && @b.sample(row, col)
    end
  end
end
