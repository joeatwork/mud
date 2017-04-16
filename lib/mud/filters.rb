# frozen_string_literal: true

require 'mud/forms'

module Mud::Filters
  def self.center_etc(region)
    ((center,), others) = region.partition { |(pt, _)| pt.all?(&:zero?) }
    [center, others]
  end

  def self.smooth(source, degree = 1, rounds = 1)
    src = if rounds == 1
            source
          else
            smooth(source, degree, rounds - 1)
          end

    Mud::Forms::Filter.new(src) do |_, region|
      (center, *others) = center_etc(region)
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

  def self.converge(source)
    middle = source.bounds.map { |x| x / 2 }

    Mud::Forms::Filter.new(source) do |pt, region|
      (center, others) = center_etc(region)
      next false unless center.last

      # List of deltas in one point - deltas points away from the center
      deltas = middle.zip(pt).map { |c, x| (x - c) <=> 0 }

      next true if deltas.all?(&:zero?)

      true_peers = others.select(&:last).map(&:first)
      # We're looking for one true point further away from the center than we are
      live = true_peers.select { |live_off| live_off == deltas }

      live.length > 0
    end
  end
end
