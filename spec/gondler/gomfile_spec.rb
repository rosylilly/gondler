require 'spec_helper'

require 'tmpdir'
require 'fileutils'
require 'pathname'

describe Gondler::Gomfile do
  let(:tmpdir) { Dir.mktmpdir("gondler-gomfile-spec") }
  after { FileUtils.remove_entry_secure(tmpdir) }

  let(:package_dir) do
    Pathname.new(tmpdir).join('src', 'example.com', 'test').tap(&:mkpath)
  end

  let(:path) { package_dir.join('Gomfile') }
  let(:content) { '' }

  let(:gomfile) do
    open(path, 'w') { |io| io.write content }
    described_class.new(path)
  end

  before do
    allow(Gondler.env).to receive(:orig_path) { tmpdir }
  end

  describe '#initialize' do
    let(:path) { 'Gomfile' }

    subject(:init) { described_class.new(path) }

    context 'without Gomfile' do
      let(:path) { '' }

      it 'raises Gondler::Gomfile::NotFound' do
        expect { init }.to raise_error(Gondler::Gomfile::NotFound)
      end
    end
  end

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

  describe "#itself_package" do
    subject(:package) { gomfile.itself_package }

    it "returns package for Gomfile's repo" do
      expect(package.name).to eq 'example.com/test'
      expect(package.path).to eq '.'
    end

    context "with itself(...)" do
      before do
        gomfile.itself 'example.org/test2'
      end

      it "returns package for Gomfile's repo, but different dir" do
        expect(package.name).to eq 'example.org/test2'
        expect(package.path).to eq '.'
      end
    end
  end
end
