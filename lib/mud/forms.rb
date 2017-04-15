# frozen_string_literal: true

require 'set'

require 'mud/enumerate'

# Two-dimensional bodies of samples
module Mud::Forms

  class Noise
    attr_accessor :bounds

    def initialize(size, dimensions, probability, seed = nil)
      seed ||= Random.new_seed
      p = [probability, 1.0 - probability].min

      @bounds = [size] * dimensions
      @invert = p < probability
      @pts = Set.new

      randoms = Random.new(seed)
      Mud.enumerate_bounds(bounds).each do |pt|
        @pts.add(pt) if randoms.rand < p
      end
    end

    def sample(*pt)
      @pts.include?(pt) ^ @invert
    end
  end
end
