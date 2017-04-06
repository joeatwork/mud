# frozen_string_literal: true

module Mud
  class Renderer
    def initialize(scale = 1)
      @scale = scale
    end

    def render(mud)
      puts header(mud)

      (mud.size - 1).times do |off_x|
        (mud.size - 1).times do |off_y|
          region = SQUARE.map { |dx, dy| [off_x + dx, off_y + dy] }

          samples = region.map { |spot| mud.sample(*spot) }
          poly = march_square(samples)
          next if poly.empty?

          pts = poly.map do |poly_x, poly_y|
            x = (off_x + poly_x) * @scale
            y = (off_y + poly_y) * @scale
            "#{x} #{y}"
          end

          pts_expr = pts.join(', ')
          puts %(  <polygon points="#{pts_expr}" fill="black" />)
        end
      end

      puts '  <g display="none">'
      mud.size.times do |spot_x|
        mud.size.times do |spot_y|
          next unless mud.sample(spot_x, spot_y)
          rad = 0.1 * @scale
          cx = spot_x * @scale
          cy = spot_y * @scale
          puts %(    <circle cx="#{cx}" cy="#{cy}" r="#{rad}" fill="red" mud:spot="#{spot_x}, #{spot_y}" />)
        end
      end
      puts '  </g>'

      puts footer
    end

    private

    # clockwise from 0, 0
    SQUARE = [[0, 0], [0, 1], [1, 1], [1, 0]].freeze

    def header(mud)
      edge = (mud.size - 1) * @scale  # I don't understand the minus 1
      <<~END_HEADER
      <?xml version="1.0" standalone="no"?>
        <svg width="#{edge}" height="#{edge}"
             version="1.1"
             mud:size="#{mud.size}"
             xmlns="http://www.w3.org/2000/svg"
             xmlns:mud="http://culturematic.net/xmlns/mud">
      END_HEADER
    end

    def footer
      '</svg>'
    end

    def between((x1, y1), (x2, y2))
      dx = (x2 - x1) / 2.0
      dy = (y2 - y1) / 2.0
      [x1 + dx, y1 + dy]
    end

    def march_square(samples)
      case samples
      when [true, true, true, true]
        SQUARE
      when [false, true, true, true]
        [
          between(SQUARE[0], SQUARE[1]),
          SQUARE[1],
          SQUARE[2],
          SQUARE[3],
          between(SQUARE[3], SQUARE[0])
        ]
      when [true, false, true, true]
        [
          SQUARE[0],
          between(SQUARE[0], SQUARE[1]),
          between(SQUARE[1], SQUARE[2]),
          SQUARE[2],
          SQUARE[3]
        ]
      when [false, false, true, true]
        [
          between(SQUARE[1], SQUARE[2]),
          SQUARE[2],
          SQUARE[3],
          between(SQUARE[3], SQUARE[0])
        ]
      when [true, true, false, true]
        [
          SQUARE[0],
          SQUARE[1],
          between(SQUARE[1], SQUARE[2]),
          between(SQUARE[2], SQUARE[3]),
          SQUARE[3]
        ]
      when [false, true, false, true]
        [
          between(SQUARE[0], SQUARE[1]),
          SQUARE[1],
          between(SQUARE[1], SQUARE[2]),
          between(SQUARE[2], SQUARE[3]),
          SQUARE[3],
          between(SQUARE[3], SQUARE[0])
        ]
      when [true, false, false, true]
        [
          SQUARE[0],
          between(SQUARE[0], SQUARE[1]),
          between(SQUARE[2], SQUARE[3]),
          SQUARE[3]
        ]
      when [false, false, false, true]
        [
          between(SQUARE[3], SQUARE[0]),
          between(SQUARE[2], SQUARE[3]),
          SQUARE[3]
        ]
      when [true, true, true, false]
        [
          SQUARE[0],
          SQUARE[1],
          SQUARE[2],
          between(SQUARE[2], SQUARE[3]),
          between(SQUARE[3], SQUARE[0])
        ]
      when [false, true, true, false]
        [
          between(SQUARE[0], SQUARE[1]),
          SQUARE[1],
          SQUARE[2],
          between(SQUARE[2], SQUARE[3])
        ]
      when [true, false, true, false]
        [
          SQUARE[0],
          between(SQUARE[0], SQUARE[1]),
          between(SQUARE[1], SQUARE[2]),
          SQUARE[2],
          between(SQUARE[2], SQUARE[3]),
          between(SQUARE[3], SQUARE[0])
        ]
      when [false, false, true, false]
        [
          between(SQUARE[1], SQUARE[2]),
          SQUARE[2],
          between(SQUARE[2], SQUARE[3])
        ]
      when [true, true, false, false]
        [
          SQUARE[0],
          SQUARE[1],
          between(SQUARE[1], SQUARE[2]),
          between(SQUARE[3], SQUARE[0])
        ]
      when [false, true, false, false]
        [
          between(SQUARE[0], SQUARE[1]),
          SQUARE[1],
          between(SQUARE[1], SQUARE[2])
        ]
      when [true, false, false, false]
        [
          SQUARE[0],
          between(SQUARE[0], SQUARE[1]),
          between(SQUARE[3], SQUARE[0])
        ]
      when [false, false, false, false]
        []
      end
    end
  end
end
