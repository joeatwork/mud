require 'spec_helper'

describe Mud::Mesher do
  let(:cube_points) do
    [
      [0, 0, 0],
      [1, 0, 0],
      [0, 1, 0],
      [1, 1, 0],

      [0, 0, 1],
      [1, 0, 1],
      [0, 1, 1],
      [1, 1, 1]
    ]
  end

  it 'should mesh empty ok' do
    v = Mud::Bag.new([], [2, 2, 2])
    expect(Mud::Mesher.mesh(v)).to eq([])
  end

  it 'should mesh full ok' do
    v = Mud::Bag.new(cube_points)
    expect(Mud::Mesher.mesh(v)).to eq([])
  end

  it 'should mesh single points ok' do
    v = Mud::Bag.new([[0, 0, 0]], [2, 2, 2])
    expect(Mud::Mesher.mesh(v)).to eq([
      [[0.5, 0.0, 0.0], [0.0, 0.5, 0.0], [0.0, 0.0, 0.5]]
    ])
  end

  it 'should mesh a big plane ok' do
    v = Mud::Bag.new([[0, 0, 0], [1, 0, 0], [0, 1, 0], [0, 0, 1]], [2, 2, 2])
    expect(Mud::Mesher.mesh(v)).to eq([
      [[0.5, 1.0, 0.0], [0.0, 1.0, 0.5], [0.0, 0.5, 1.0]],
      [[1.0, 0.5, 0.0], [0.5, 1.0, 0.0], [0.0, 0.5, 1.0]],
      [[1.0, 0.5, 0.0], [0.0, 0.5, 1.0], [0.5, 0.0, 1.0]],
      [[1.0, 0.5, 0.0], [0.5, 0.0, 1.0], [1.0, 0.0, 0.5]]
    ])
  end

  it 'should mesh translated points ok' do
    v = Mud::Bag.new([[1, 10, 100]], [2, 20, 200])
    expect(Mud::Mesher.mesh(v)).to eq([
      [[1.0, 9.5, 100.0], [0.5, 10.0, 100.0], [1.0, 10.0, 99.5]],
      [[1.0, 9.5, 100.0], [1.0, 10.0, 100.5], [0.5, 10.0, 100.0]],
      [[1.0, 10.0, 99.5], [0.5, 10.0, 100.0], [1.0, 10.5, 100.0]],
      [[0.5, 10.0, 100.0], [1.0, 10.0, 100.5], [1.0, 10.5, 100.0]]
    ])
  end
end
