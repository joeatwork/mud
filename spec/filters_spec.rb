require 'spec_helper'

RSpec.describe Mud::Filters do

  describe 'smooth' do
    let(:center) do
      Mud::Forms::Fn.new([3, 3]) do |row, col|
        row == 1 && col == 1
      end
    end

    let(:smooth_center) do
      Mud.enumerate(Mud::Filters.smooth(center)).to_a
    end

    let(:two) { Mud::Forms::Bag.new([[1,1], [2,1]], [4, 4]) }

    let(:smooth_two) { Mud::Filters.smooth(two) }

    let(:smooth_two_2) { Mud::Filters.smooth(two, 2) }

    let(:smooth_two_2_2) { Mud::Filters.smooth(two, 2, 2) }

    it 'smooths away islands' do
      expect(smooth_center.map { |pt| pt[2] }).to all(eq false)
    end

    it 'leaves elements with neighbors' do
      expect(smooth_two.sample(1, 1)).to eq(true)
      expect(smooth_two.sample(2, 1)).to eq(true)
    end

    it 'flips at 2 degrees' do
      expect(smooth_two_2.sample(1, 1)).to eq(false)
      expect(smooth_two_2.sample(2, 1)).to eq(false)
    end
  end

end
