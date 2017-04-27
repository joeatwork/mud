require 'spec_helper'

RSpec.describe Mud::Forms do

  describe 'basics' do
    let(:bag) { Mud::Forms::Bag.new([[0, 0], [2, 2]]) }
    let(:bag2) { Mud::Forms::Bag.new([1,1], [0, 0], [3, 3]) }
    let(:noise) { Mud::Forms::Noise.new(3, 2, 0.5) }
    let(:fn) do
      Mud::Forms::Fn.new([0, 0], [3, 3]) { true }
    end
    let(:memo) { Mud::Forms::Memo.new(bag) }
    let(:arrange) { Mud::Forms::Arrange.new(bag, [0, 0], [3, 3]) }
    let(:conjunction) { Mud::Forms::And.new(bag, bag2) }
    let(:layers) do
      b0 = Mud::Forms::Bag.new([[0], [2]])
      b1 = Mud::Forms::Bag.new([[0], [2]])
      b2 = Mud::Forms::Bag.new([[0], [2]])
      Mud::Forms::Layers.new([b0, b1, b2])
    end
    let(:flavors) do
      [bag, noise, fn, arrange, conjunction, layers] # memo?
    end

    it 'should provide bounds in all cases' do
      flavors.each do |form|
        expect(form.bounds).to eq([3, 3]), "Bounds problem with #{form.bounds} #{form.class.name}"
      end
    end

    it 'should provide offsets in all cases' do
      flavors.each do |form|
        expect(form.offset).to eq([0, 0]), "Offset problem with #{form.offset} #{form.class.name}"
      end
    end
  end

  describe Mud::Forms::Fn do
    let(:fn) do
      Mud::Forms::Fn.new([0, 0], [2, 2]) do |row, col|
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

  describe Mud::Forms::Islands do
    let(:source) do
      Mud::Forms::Bag.new([
       [0, 0], [0, 1], [0, 2],
       [2, 0], [2, 1], [2, 2], [2, 3], [2, 4],
       [4, 0], [4, 1], [4, 2], [4, 3],
      ])
    end

    let(:islands) do
      Mud::Forms::Islands.new(source, 2)
    end

    it 'should find only the big two' do
      [[0, 0], [0, 1], [0, 2]].each do |pt|
        expect(islands.sample(*pt)).to eq(false)
      end

      [[2, 0], [2, 1], [2, 2], [2, 3], [2, 4]].each do |pt|
        expect(islands.sample(*pt)).to eq(true)
      end

      [[4, 0], [4, 1], [4, 2], [4, 3]].each do |pt|
        expect(islands.sample(*pt)).to eq(true)
      end
    end
  end
end
