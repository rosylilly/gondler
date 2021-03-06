require 'thor'
require 'pathname'
require 'gondler'

module Gondler
  class CLI < Thor
    class_option :gomfile, :type => :string, :default => 'Gomfile'
    class_option :path, :type => :string, :default => '.gondler'

    def initialize(*args)
      super

      set_environments
    end

    desc 'install', 'Install the dependecies specified in your Gomfile'
    method_option :without, :type => :array, :default => nil
    def install
      Gondler.without(options[:without] || []) do
        gomfile.packages.each do |package|
          puts "Install #{package}"
          package.resolve
        end
      end

      gomfile.itself_package.get if gomfile.itself_package
    rescue Gondler::Package::InstallError => e
      puts e.message
      exit(1)
    end

    desc 'build', 'Build with dependencies specified in your Gomfile'
    def build(*args)
      invoke :go, %w(build) + args
    end

    desc 'test', 'Test with dependencies specified in your Gomfile'
    def test(*args)
      invoke :go, %w(test) + args
    end

    desc 'go', 'Execute go command in the context of Gondler'
    def go(*args)
      invoke :exec, %w(go) + args
    end

    desc 'exec', 'Execute a command in the context of Gondler'
    def exec(*args)
      args.map! do |arg|
        if arg.to_s.include?(' ')
          %Q{"#{arg.gsub(/"/, '\"')}"}
        else
          arg
        end
      end
      Kernel.exec(*args.join(' '))
    end

    desc 'list', 'Show all of the dependencies in the current bundle'
    method_option :without, :type => :array, :default => nil
    def list
      Gondler.without(options[:without] || []) do
        puts 'Packages included by the gondler:'
        gomfile.packages.each do |package|
          puts " * #{package}"
        end
      end
    end

    desc 'repl', 'REPL in the context of Gondler'
    def repl
      require 'gondler/repl'
      Gondler::REPL.run
    end

    desc 'version', 'Print Gondler version'
    def version
      puts Gondler::VERSION
    end

    desc 'env', 'Print Gondler environments'
    def env(*args)
      invoke :go, %w(env) + args
    end

    private

    def method_missing(*args)
      if executable?(args.first)
        invoke(:exec, args)
      elsif executable?("gondler-#{args.first}")
        args[0] = "gondler-#{args.first}"
        invoke(:exec, args)
      else
        STDERR.puts(%Q{Could not find command "#{args.first}"})
        exit(1)
      end
    end

    def set_environments
      path = Pathname.new(options[:path])
      path = Pathname.pwd + path unless path.absolute?
      Gondler.env.path = path
      ENV['PATH'] = "#{path + 'bin'}:#{ENV['PATH']}"
    end

    def executable?(name)
      system("hash #{name} 1> /dev/null 2>&1")
    end

    def gomfile
      @gomfile ||= Gondler::Gomfile.new(options[:gomfile])
    rescue Gomfile::NotFound => e
      say(e.message, :red)
      exit(1)
    end
  end
end
