require 'spec_helper'

RSpec.describe Mud::Forms do
  describe Mud::Forms::Fn do
    let(:fn) do
      Mud::Forms::Fn.new([2, 2]) do |row, col|
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

  describe Mud::Forms::Bag do
    let(:bag) { Mud::Forms::Bag.new([[1,0], [0,1]]) }

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

  describe Mud::Forms::Layers do
    let(:layers) do
      Mud::Forms::Layers.new([
        Mud::Forms::Bag.new([[0, 0]], [4,2]),
        Mud::Forms::Bag.new([[0, 1]], [2,5]),
        Mud::Forms::Bag.new([[0, 2]], [2,2]),
      ])
    end

    it 'should calculate bounds correctly' do
      expect(layers.bounds).to eq([4, 5, 3])
    end

    it 'should order layers correctly' do
      expect(layers.sample(0, 0, 0)).to eq(true)
      expect(layers.sample(0, 1, 1)).to eq(true)
      expect(layers.sample(0, 2, 2)).to eq(true)

      expect(layers.sample(1, 0, 0)).to eq(false)
      expect(layers.sample(1, 1, 1)).to eq(false)
      expect(layers.sample(1, 2, 2)).to eq(false)
    end
  end

end
