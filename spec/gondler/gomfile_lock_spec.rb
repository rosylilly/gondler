require 'spec_helper'
require 'tempfile'

describe Gondler::GomfileLock do
  let(:gomfile) { Gondler::Gomfile.new(path) }
  let(:content) do
    <<-CONTENT
    gom 'github.com/golang/glog'
    gom 'github.com/golang/lint', commit: '1ad6a0eeb85088d8f32e1c5db9965f4a11c0af70'
    gom 'github.com/futoase/underground', branch: 'welcome-to-heaven'
    gom 'bitbucket.org/matrixik/listdict', tag: 'tip'
    gom 'bitbucket.org/llg/gocreate'
    CONTENT
  end
  let(:file) do
    Tempfile.open('Gomfile').tap do |f|
      f.print(content)
      f.flush
    end
  end
  let(:path) { file.path }
  let(:env) { Gondler::Env.new }

  let(:gomfile_lock) { described_class.new(file.path) }
  let(:lock_path) { file.path + '.lock' }
  let(:lock_content) do
    <<-CONTENT.gsub(/^\s+/, '')
    github.com/golang/glog: commit => c6f9652c7179652e2fd8ed7002330db089f4c9db
    github.com/golang/lint: commit => 1ad6a0eeb85088d8f32e1c5db9965f4a11c0af70
    github.com/futoase/underground: branch => welcome-to-heaven
    bitbucket.org/matrixik/listdict: tag => tip
    bitbucket.org/llg/gocreate: commit => 1251907fe3b4ad2cd968ca92db030eb37927f75e
    CONTENT
  end

  after do
    file.close! 
    %w(github.com/golang/glog github.com/futoase/underground bitbucket.org/matrixik/listdict).map do |dir|
      FileUtils.rmdir(env.path + '/src/' + dir)
    end
    FileUtils.rm(lock_path)
  end

  describe "#freeze" do

    before do
      gomfile.packages.each do |package|
        package.resolve
        gomfile_lock << package
      end
      gomfile_lock.freeze
    end

    it "should be create Gemfile.lock" do
      expect( gomfile_lock.lists ).to eq gomfile.packages
      expect( File.exists?(lock_path) ).to be_true
      expect( File.read(lock_path) ). to eq lock_content
    end

  end

end
