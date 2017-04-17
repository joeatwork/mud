# frozen_string_literal: true

require 'erb'

module Mud::Renderer
  class ThreeJS

    TMPLNAME = File.join(File.dirname(__FILE__), "threejs.html.erb")
    TMPL = ERB.new(File.read(TMPLNAME))

    def dimensions
      3
    end

    def render(mud)
      offsets = mud.bounds.map { |x| -x / 2.0 }
      radius_squared = offsets.reduce(0) { |s, off| s + (off * off) }
      radius = Math.sqrt(radius_squared)

      mesh = Mud::Mesher::mesh(mud)
      offset_mesh = mesh.map do |triangle|
        triangle.map do |vertex|
          vertex.zip(offsets).map { |x, off| x + off }
        end
      end

      TMPL.run(binding)
    end
  end

  class STL
    def initialize(scale = 1)
      @scale = scale
    end

    def dimensions
      3
    end

    def render(mud)
      puts 'solid MUD'
      Mud::Mesher.mesh(mud).each do |(v1, v2, v3)|
        puts 'facet normal 0 0 0'
        puts '  outer loop'
        puts "    vertex #{vertex(v1)}"
        puts "    vertex #{vertex(v2)}"
        puts "    vertex #{vertex(v3)}"
        puts '  endloop'
        puts 'endfacet'
      end
      puts 'endsolid MUD'
    end

    def vertex(v)
      v.map { |x| x * @scale }.join(' ')
    end
  end

  class SVG
    def initialize(scale = 1)
      @scale = scale
    end

    def dimensions
      2
    end

    def render(mud)
      puts header(mud)

      x_bound, y_bound = mud.bounds
      (x_bound - 1).times do |off_x|
        (y_bound - 1).times do |off_y|
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
      x_bound.times do |spot_x|
        y_bound.times do |spot_y|
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
      x_bound, y_bound = mud.bounds

      # I don't understand the minus 1 below
      width = x_bound * @scale
      height = y_bound * @scale
      <<~END_HEADER
      <?xml version="1.0" standalone="no"?>
                                     <svg width="#{width}" height="#{height}"
      version="1.1"
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
