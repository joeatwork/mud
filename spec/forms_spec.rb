# frozen_string_literal: true

require 'spec_helper'

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

describe Mud::Smooth do
  let(:center) do
    Mud::Fn.new([3, 3]) do |row, col|
      row == 1 && col == 1
    end
  end

  let(:smooth_center) do
    Mud.enumerate(Mud::Smooth.new(center)).to_a
  end

  let(:left) do
    Mud::Fn.new([2, 2]) do |_row, col|
      col.zero?
    end
  end

  let(:smooth_left) do
    Mud.enumerate(Mud::Smooth.new(left)).to_a
  end

  let(:smooth_left_2) do
    Mud.enumerate(Mud::Smooth.new(left, 2)).to_a
  end

  let(:smooth_left_2_2) do
    Mud.enumerate(Mud::Smooth.new(left, 2, 2)).to_a
  end

  it 'smooths away islands' do
    expect(smooth_center.map { |pt| pt[2] }).to all(eq false)
  end

  it 'leaves elements with neighbors' do
    expect(smooth_left).to eq([[0, 0, true], [1, 0, true], [0, 1, false], [1, 1, false]])
  end

  it 'swaps at 2 degrees' do
    expect(smooth_left_2).to eq([[0, 0, false], [1, 0, false], [0, 1, true], [1, 1, true]])
  end

  it 'unswaps at 2 degrees 2 rounds' do
    expect(smooth_left_2_2).to eq([[0, 0, true], [1, 0, true], [0, 1, false], [1, 1, false]])
  end
end
