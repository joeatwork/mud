# frozen_string_literal: true

module Mud::Volumes
  class Layers
    def initialize(ls)
      @ls = ls.to_a
    end

    def bounds
      ret = @ls.map(&:bounds).reduce do |b, layer|
        b.zip(layer).map { |b_l| b_l.max }
      end

      ret << @ls.length
      ret
    end

    def sample(*pt)
      layer = @ls[pt.pop]
      layer.sample(*pt)
    end
  end
end
