require 'spec_helper'
require 'tempfile'

describe Gondler::Gomfile do
  let(:gomfile) { described_class.new(path) }
  let(:file) do
    Tempfile.open('Gomfile').tap do|f|
      f.print(content)
      f.flush
    end
  end
  let(:path) { file.path }
  let(:content) { '' }
  after { file.close! }

  describe '#gom' do
    let(:content) do
      <<-CONTENT
      gom 'github.com/golang/glog'
      CONTENT
    end

    it 'packages should include glog' do
      expect(gomfile.packages).to have(1).package
    end
  end

  describe '#group' do
    let(:content) do
      <<-CONTENT
      group :development, :test do
        gom 'github.com/golang/glog'
      end
      CONTENT
    end

    it 'package group should == development and test' do
      expect(gomfile.packages.first.group).to eq(%w(development test))
    end
  end

  describe '#os' do
    let(:content) do
      <<-CONTENT
      os :darwin, :linux do
        gom 'github.com/golang/glog'
      end
      CONTENT
    end

    it 'package os should == darwin and linux' do
      expect(gomfile.packages.first.os).to eq(%w(darwin linux))
    end
  end

  context 'without Gomfile' do
    let(:path) { '' }

    it 'raises Gondler::Gomfile::NotFound' do
      expect { described_class.new(path) }.to raise_error(Gondler::Gomfile::NotFound)
    end
  end
end
