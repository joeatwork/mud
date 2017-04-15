# frozen_string_literal: true

require 'parallel'

module Mud
  class << self
    # Enumerate over the bounds of a form or volume
    def enumerate(mud)
      bounds = mud.bounds.map { |x| x }
      vals = enum_bounds(bounds)

      progress_opts = {
        title: "#{mud.class.name} #{bounds}",
        output: STDERR,
      }
      Parallel.map(vals, progress: progress_opts) do |v|
        v.reverse!
        tail = mud.sample(*v)
        v << tail
        v
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
