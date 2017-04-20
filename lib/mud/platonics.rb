# frozen_string_literal: true

require 'matrix'

module Mud::Platonics

  module Continuous
    def continuous
      true
    end
  end

  # Square in n dimensions
  class NCube
    include Continuous
    attr_reader :bounds

    def initialize(edge, dimension)
      @edge = edge.ceil
      @bounds = [@edge] * dimension
    end

    def sample(*pt)
      pt.all? { |x| x >= 0 && x < @edge }
    end

    def continuous
      true
    end
  end

  # all samples inside of the circle are visible
  class NSphere
    include Continuous
    attr_reader :bounds

    def initialize(radius, dimensions)
      @radius = radius
      @center = [@radius] * dimensions
      @bounds = @center.map { |c| (c + @radius).ceil + 1}
    end

    def sample(*pt)
      pt_distance = pt.zip(@center).reduce(0) do |s, (x, c)|
        dx = x - c
        s += dx * dx
        s
      end
      pt_distance < @radius * @radius
    end

    def continuous
      true
    end
  end

  # We can only apply transforms to continuous
  class Transform
    attr_reader :bounds

    def initialize(source, matrix)
      raise "Can only transform continuous sources" unless source.continuous
      @source = source
      @matrix = matrix.inverse

      old_bounds = source.bounds
      unit_corners = unit_cube_corners(old_bounds.length)
      old_box = unit_corners.map do |corner|
        corner.zip(old_bounds).map { |x0, x1| x0 * x1 }
      end

      new_box = old_box.map { |v| xform_a(v) }

      @bounds = new_box.reduce([1] * old_bounds.length) do |v0, v1|
        v0.zip(v1).map { |pair| pair.max.ceil }
      end
    end

    def sample(*pt)
      transformed = xform_a(pt)
      @source.sample(*transformed)
    end

    private

    def unit_cube_corners(dimension)
      if dimension == 1
        [[0], [1]]
      else
        roots = unit_cube_corners(dimension - 1)
        roots.flat_map { |r| [[0, *r], [1, *r]] }
      end
    end

    def xform_a(a)
      v = Vector[*a]
      (@matrix * v).to_a
    end
  end

  def self.rotate2d(source, theta)
    raise "Only supported in two dimensions" unless source.bounds.length == 2
    cos_theta = Math.cos(theta)
    sin_theta = Math.sin(theta)
    m = Matrix[
      [ cos_theta, sin_theta],
      [-sin_theta, cos_theta]
    ]
    Transform.new(source, m)
  end
end
