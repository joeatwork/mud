require 'spec_helper'

RSpec.describe Mud::Filters do
  describe 'center_etc' do
    it 'should pull out zeroes' do
      vals = [[[1,2], false], [[0,0], true], [[2,3], false]]
      (center, *rest) = Mud::Filters.center_etc(vals)
      expect(center).to eq([[0, 0], true])
      expect(rest).to eq([[[1,2], false], [[2,3], false]])
    end
  end

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

  describe 'converge' do
    let(:centered) do
      Mud::Forms::Fn.new([6, 6]) do |row, col|
        row > 0 && row < 5 && col > 0 && col < 5
      end
    end

    let(:filtered) do
      Mud.enumerate(Mud::Filters.converge(centered))
    end

    it 'contracts toward the center' do
      puts "filtered:: #{filtered}"

      expect(filtered).to eq([
        [0, 0, false], [1, 0, false], [2, 0, false], [3, 0, false], [4, 0, false], [5, 0, false],
        [0, 1, false], [1, 1, false], [2, 1, false], [3, 1, false], [4, 1, false], [5, 1, false],
        [0, 2, false], [1, 2, false], [2, 2,  true], [3, 2,  true], [4, 2, false], [5, 2, false],
        [0, 3, false], [1, 3, false], [2, 3,  true], [3, 3,  true], [4, 3, false], [5, 3, false],
        [0, 4, false], [1, 4, false], [2, 4, false], [3, 4, false], [4, 4, false], [5, 4, false],
        [0, 5, false], [1, 5, false], [2, 5, false], [3, 5, false], [4, 5, false], [5, 5, false]
      ])
    end
  end
end
