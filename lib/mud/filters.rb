# frozen_string_literal: true

require 'mud/forms'

module Mud::Filters

  def self.smooth(source, degree = 1, rounds = 1)
    src = if rounds == 1
            source
          else
            smooth(source, degree, rounds - 1)
          end

    Mud::Forms::Filter.new(src) do |region|
      ((center,), others) = region.partition { |(pt, _)| pt.all?(&:zero?) }
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
end
