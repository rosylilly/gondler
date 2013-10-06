require 'spec_helper'

describe Gondler::Env do
  let(:env) { described_class.new }

  describe '#os' do
    subject { env.os }

    it { should == `go env GOOS`.strip }
  end

  describe '#path=' do
    before { @gopath = env.path }
    after { env.path = @gopath }

    it 'should override path environment' do
      env.path = 'spec'
      env.reload!
      expect(env.path).to eq('spec')
    end
  end
end
