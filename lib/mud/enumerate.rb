# frozen_string_literal: true

require 'parallel'

module Mud
  class << self
    # Enumerate over the bounds of a form or volume
    def enumerate(form)
      bounds = form.bounds.map { |x| x }
      vals = enumerate_bounds(bounds)

      progress_opts = if bounds.reduce { |s, i| s * i } >= 10000
                        {
                          title: "#{form.class.name} #{bounds}",
                          output: STDERR,
                        }
                      end

      Parallel.map(vals, progress: progress_opts) do |v|
        tail = form.sample(*v)
        v << tail
        v
      end
    end

    def enumerate_bounds(bounds)
      enum_bounds(bounds).map { |pt| pt.reverse }
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
