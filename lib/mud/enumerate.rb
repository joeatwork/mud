# frozen_string_literal: true

module Mud
  class << self
    # Enumerate over the bounds of a form or volume
    def enumerate(mud)
      bounds = mud.bounds.map { |x| x }
      enum_bounds(bounds).map do |vals|
        vals.reverse!
        tail = mud.sample(*vals)
        vals << tail
        vals
      end
    end

    private

    # Enumerates the bounds BACKWARDS
    def enum_bounds(bounds)
      if bounds.length == 1
        bounds[0].times.map { |ix| [ix] }
      elsif bounds.length > 1
        rest = enum_bounds(bounds[1..-1])
        Enumerator.new do |y|
          rest.each do |vals|
            bounds[0].times do |ix|
              nxt = Array.new(vals)
              nxt << ix
              y << nxt
            end
          end
        end
      end
    end
  end
end
