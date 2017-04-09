require 'spec_helper'

RSpec.describe Mud do

  it 'has a version number' do
    expect(Mud::VERSION).not_to be nil
  end

  describe Mud::Fn do
    let(:fn) do
      Mud::Fn.new([2, 2]) do |row, col|
        row == col
      end
    end

    it 'passes bounds' do
      expect(fn.bounds).to eq([2, 2])
    end

    it 'calls block' do
      expt = [[0, 0, true], [1, 0, false], [0, 1, false], [1, 1, true]]
      expect(Mud.enumerate(fn).to_a).to eq(expt)
    end
  end

  describe Mud::Bag do
    let(:bag) { Mud::Bag.new([[1,0], [0,1]]) }

    it 'guesses bounds correctly' do
      expect(bag.bounds).to eq([2,2])
    end

    it 'contains what I think it does' do
      expect(bag.sample(0,0)).to eq(false)
      expect(bag.sample(1,0)).to eq(true)
      expect(bag.sample(0,1)).to eq(true)
      expect(bag.sample(1,1)).to eq(false)
    end
  end

  describe Mud::Smooth do
    let(:center) do
      Mud::Fn.new([3, 3]) do |row, col|
        row == 1 && col == 1
      end
    end

    let(:smooth_center) do
      Mud.enumerate(Mud::Smooth.new(center)).to_a
    end

    let(:two) { Mud::Bag.new([[1,1], [2,1]], [4, 4]) }

    let(:smooth_two) { Mud::Smooth.new(two) }

    let(:smooth_two_2) { Mud::Smooth.new(two, 2) }

    let(:smooth_two_2_2) { Mud::Smooth.new(two, 2, 2) }

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
