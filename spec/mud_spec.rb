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
end
