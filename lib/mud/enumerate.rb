# frozen_string_literal: true

require 'parallel'

# Top level tools for enumerating over the ranges of forms
module Mud
  class << self
    # Enumerate over the bounds of a form or volume
    def enumerate(form)
      offset = form.offset
      bounds = form.bounds
      vals = enumerate_bounds(offset, bounds)

      progress_opts = if bounds.reduce { |s, i| s * i } >= 10000
                        {
                          title: "#{form.class.name} #{offset} #{bounds}",
                          output: STDERR
                        }
                      end

      Parallel.map(vals, progress: progress_opts) do |v|
        tail = form.sample(*v)
        v << tail
        v
      end
    end

    def enumerate_bounds(offset, bounds)
      enum_bounds(bounds).map do |pt|
        pt.reverse.zip(offset).map { |x, x_off| x + x_off }
      end
    end

    private

    # Enumerates the bounds BACKWARDS
    def enum_bounds(bounds)
      if bounds.length == 1
        Array.new(bounds[0]) { |ix| [ix] }
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
