# frozen_string_literal: true

module Mud

  def self.enumerate(form)
    Enumerator.new do |yielder|
      max_x, max_y = form.bounds
      max_x.times do |col|
        max_y.times do |row|
          yielder << [row, col, form.sample(row, col)]
        end
      end
    end
  end

  # Allow callers to just use some arbitrary block for samples
  class Fn
    attr_accessor :bounds

    def initialize(bounds, &block)
      @fn = block
      @bounds = bounds
    end

    def sample(row, col)
      @fn.call(row, col)
    end
  end

  # Saves results of potentially expensive forms
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

  # smoother
  class Smooth
    def initialize(source, degree = 1, rounds = 1)
      @source = if rounds > 1
                  Memo.new(Smooth.new(source, degree, rounds - 1))
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
