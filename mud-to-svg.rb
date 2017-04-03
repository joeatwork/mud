# frozen_string_literal: true

module Demo

  class Mud
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

    def in_bounds (row, col)
      ret = row >= 0 && col >= 0 && row < @size && col < @size
      ret
    end

    def sample (row, col)
      @all_samples[col * @size + row]
    end
  end

  class Renderer
    def header(mud)
      edge = mud.size * @scale
      <<~END_HEADER
      <?xml version="1.0" standalone="no"?>
      <svg width="#{edge}" height="#{edge}" version="1.1" xmlns="http://www.w3.org/2000/svg">
      END_HEADER
    end

    def footer
      '</svg>'
    end

    # clockwise from 0, 0
    SQUARE = [[0, 0], [0, 1], [1, 1], [1, 0]].freeze

    def initialize(scale=1)
      @scale = scale
    end

    def between((x1, y1), (x2, y2))
      dx = (x2 - x1) / 2.0
      dy = (y2 - y1) / 2.0
      [x1 + dx, y1 + dy]
    end

    def render(mud)
      puts header(mud)

      mud.coords.each do |off_x, off_y|
        region = SQUARE.map {|dx, dy| [off_x + dx, off_y + dy]}
        if region.all? {|spot| mud.in_bounds(*spot) }
          poly =
            case region.map {|spot| mud.sample(*spot) }
            when [true, true, true, true]
              region
            when [false, true, true, true]
              [
                between(region[0], region[1]),
                region[1],
                region[2],
                region[3],
                between(region[3], region[0]),
              ]
            when [true, false, true, true]
              [
                region[0],
                between(region[0], region[1]),
                between(region[1], region[2]),
                region[2],
                region[3]
              ]
            when [false, false, true, true]
              [
                between(region[1], region[2]),
                region[2],
                region[3],
                between(region[3], region[0])
              ]
            when [true, true, false, true]
              [
                region[0],
                region[1],
                between(region[1], region[2]),
                between(region[2], region[3]),
                region[3]
              ]
            when [false, true, false, true]
              [
                between(region[0], region[1]),
                region[1],
                between(region[1], region[2]),
                between(region[2], region[3]),
                region[3],
                between(region[3], region[0])
              ]
            when [true, false, false, true]
              [
                region[0],
                between(region[0], region[1]),
                between(region[2], region[3]),
                region[3]
              ]
            when [false, false, false, true]
              [
                between(region[3], region[0]),
                between(region[2], region[3]),
                region[3]
              ]
            when [true, true, true, false]
              [
                region[0],
                region[1],
                region[2],
                between(region[2], region[3]),
                between(region[3], region[0])
              ]
            when [false, true, true, false]
              [
                between(region[0], region[1]),
                region[1],
                region[2],
                between(region[2], region[3])
              ]
            when [true, false, true, false]
              [
                region[0],
                between(region[0], region[1]),
                between(region[1], region[2]),
                region[2],
                between(region[2], region[3]),
                between(region[3], region[0])
              ]
            when [false, false, true, false]
              [
                between(region[1], region[2]),
                region[2],
                between(region[2], region[3])
              ]
            when [true, true, false, false]
              [
                region[0],
                region[1],
                between(region[1], region[2]),
                between(region[3], region[0])
              ]
            when [false, true, false, false]
              [
                between(region[0], region[1]),
                region[1],
                between(region[1], region[2])
              ]
            when [true, false, false, false]
              [
                region[0],
                between(region[0], region[1]),
                between(region[3], region[0])
              ]
            when [false, false, false, false]
              []
            end

          unless poly.empty?
            pts_expr = poly.map {|x, y| "#{x * @scale} #{y * @scale}"}.join(', ')
            puts %Q(  <polygon points="#{pts_expr}" fill="black" />)
          end
        end
      end

      puts '  <!-- UNCOMMENT THE BELOW TO SEE THE SPOTS -->'
      puts '  <!--'
      mud.coords.select {|pt| mud.sample(*pt)}.each do |(spot_x, spot_y)|
        rad = 0.1 * @scale
        cx = spot_x * @scale
        cy = spot_y * @scale
        puts %Q(  <circle cx="#{cx}" cy="#{cy}" r="#{rad}" fill="red" />)
      end
      puts '  -->'

      puts footer
    end
  end
end

detail = ARGV[0]&.to_i || 100

scale = 500 / detail
m = Demo::Mud.new(detail)
renderer = Demo::Renderer.new(scale)
renderer.render(m)

