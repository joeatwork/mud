require 'spec_helper'

describe Mud::Volumes do
  let(:layers) do
    Mud::Volumes::Layers.new([
      Mud::Bag.new([[0, 0]], [4,2]),
      Mud::Bag.new([[0, 1]], [2,5]),
      Mud::Bag.new([[0, 2]], [2,2]),
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
