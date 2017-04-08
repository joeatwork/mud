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
      expect(bag.bounds).to eq([1,1])
    end

    it 'contains what I think it does' do
      expect(bag.sample(0,0)).to eq(false)
      expect(bag.sample(1,0)).to eq(true)
      expect(bag.sample(0,1)).to eq(true)
      expect(bag.sample(1,1)).to eq(false)
    end
  end
end
