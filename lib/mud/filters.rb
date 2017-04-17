# frozen_string_literal: true

require 'mud/forms'

module Mud::Filters
  class << self
    def center_etc(region)
      ((center,), others) = region.partition { |(pt, _)| pt.all?(&:zero?) }
      [center, others]
    end

    def smooth(source, degree = 1, rounds = 1)
      src = if rounds == 1
              source
            else
              smooth(source, degree, rounds - 1)
            end

      Mud::Forms::Filter.new(src) do |_, region|
        (center, others) = center_etc(region)
        centerval = center.last
        count = others.count { |_pt, val| val == centerval }

        if count >= degree
          centerval
        elsif region.length <= degree
          # Avoid artifacts at corners or edges of bounds
          centerval
        else
          !centerval
        end
      end
    end

    def converge(source)
      middle = source.bounds.map { |x| x / 2.0 }

      Mud::Forms::Filter.new(source) do |pt, region|
        # We skootch points and neighbors forward 0.5 ????
        (center, others) = center_etc(region)
        next false unless center.last

        adj_pt = pt.map { |x| x + 0 }
        true_peers = others.select(&:last).map(&:first).map do |peer_pt|
          peer_pt.map { |x| x + 0 }
        end

        # List of deltas in one point - deltas points away from the center.
        to_center = middle.zip(adj_pt).map { |c, x| c - x }

        # We're looking for one true point further away from the center than we are
        dirs = true_peers.map do |peer|
          peer.zip(to_center).reduce(0) do |sum, (x, plane_x)|
            # The additional 0.5 shift is because points occupy
            # the spaces *between* their corners
            sum + x * plane_x
          end
        end

        dirs.any?(&:negative?)
      end
    end

    private

    def normalize(v)
      norm_squared = to_center.reduce { |(prod, nxt)| prod + (nxt * nxt) }
      norm = Math.sqrt(norm_squared)
      v.map { |x| x / norm }
    end
  end
end
