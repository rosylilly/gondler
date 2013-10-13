require 'spec_helper'

describe Gondler::Package do
  let(:name) { 'github.com/golang/glog' }
  let(:options) { {} }
  let(:package) { described_class.new(name, options) }

  describe '#os' do
    let(:expected) { %w(linux darwin) }
    subject { package.os }

    context 'with ["linux", "darwin"]' do
      let(:options) { { :os => %w(linux darwin) } }

      it { should == expected }
    end

    context 'with "linux darwin"' do
      let(:options) { { :os => 'linux darwin' } }

      it { should == expected }
    end
  end

  describe '#installable?' do
    before { Gondler.env.os = 'darwin' }
    after { Gondler.env.reload! }

    subject { package.installable? }

    context 'when os option is nil' do
      it { should be_true }
    end

    context 'when os option is darwin' do
      let(:options) { { :os => 'darwin' } }

      it { should be_true }
    end

    context 'when os option is linux' do
      let(:options) { { :os => 'linux' } }

      it { should be_false }
    end

    context 'when os option is linux and darwin' do
      let(:options) { { :os => 'linux darwin' } }

      it { should be_true }
    end

    context 'when development without' do
      before { Gondler.withouts = %w(development) }
      after { Gondler.withouts = [] }

      let(:options) { { :group => 'development' } }

      it { should be_false }
    end
  end
end
