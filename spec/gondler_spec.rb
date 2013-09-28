require 'spec_helper'

describe Gondler do
  describe '.env' do
    subject { Gondler.env }

    it { should be_kind_of(Gondler::Env) }
  end
end
