require 'thor'
require 'gondler'

module Gondler
  class CLI < Thor
    class_option :gomfile, type: :string, default: 'Gomfile'
    class_option :path, type: :string, default: '.gondler'

    def initialize(*args)
      super

      @gomfile = Gondler::Gomfile.new(options[:gomfile])
    end

    desc 'install', 'Install the dependecies specified in your Gomfile'
    method_option :without, type: :array, default: []
    def install
    end

    desc 'list', 'Show all of the dependencies in the current bundle'
    method_option :without, type: :array, default: []
    def list
      Gondler.withouts = options[:without]

      puts 'Packages included by the gondler:'
      @gomfile.packages.each do |package|
        puts " * #{package}"
      end
    end
  end
end
