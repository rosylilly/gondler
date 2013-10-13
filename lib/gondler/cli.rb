require 'thor'
require 'readline'
require 'pathname'
require 'gondler'

module Gondler
  class CLI < Thor
    class_option :gomfile, type: :string, default: 'Gomfile'
    class_option :path, type: :string, default: '.gondler'

    def initialize(*args)
      super

      @gomfile = Gondler::Gomfile.new(options[:gomfile])

      path = Pathname.new(options[:path])
      path = Pathname.pwd + path unless path.absolute?
      Gondler.env.path = path
      ENV['PATH'] = "#{path + 'bin'}:#{ENV['PATH']}"
    rescue Gomfile::NotFound => e
      if ["help", "--help", "-h"].include?(ARGV[0])
        help
        exit(0)
      else
        say(e.to_s, :red)
        exit(1)
      end
    end

    desc 'install', 'Install the dependecies specified in your Gomfile'
    method_option :without, type: :array, default: []
    def install
      @gomfile.packages.each do |package|
        puts "Install #{package}"
        package.resolve
      end
    rescue Gondler::Package::InstallError => e
      puts e.message
      exit(1)
    end

    desc 'build', 'Build with dependencies specified in your Gomfile'
    def build(*args)
      invoke :exec, %w(go build) + args
    end

    desc 'test', 'Test with dependencies specified in your Gomfile'
    def test(*args)
      invoke :exec, %w(go test) + args
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
    method_option :without, type: :array, default: []
    def list
      Gondler.withouts = options[:without]

      puts 'Packages included by the gondler:'
      @gomfile.packages.each do |package|
        puts " * #{package}"
      end
    end

    desc 'repl', 'REPL in the context of Gondler'
    def repl
      while buf = Readline.readline('> ', true)
        Kernel.system(buf)
      end
    end

    desc 'version', 'Print Gondler version'
    def version
      puts Gondler::VERSION
    end

    def method_missing(*args)
      if executable?(args.first)
        invoke(:exec, args)
      elsif executable?("gondler-#{args.first}")
        invoke(:exec, args)
      else
        STDERR.puts(%Q{Could not find command "#{args.first}"})
        exit(1)
      end
    end

    private

    def executable?(name)
      system("hash #{name} 1> /dev/null 2>&1")
    end
  end
end
