require 'gondler/package'

module Gondler
  class Gomfile
    def initialize(path)
      raise NotFound, path unless File.exist?(path)
      @packages = []
      @itself = nil

      load(path)
    end
    attr_reader :packages

    def itself(name)
      @itself = name
    end

    def itself_package
      if !@itself && Gondler.env.orig_path
        realpath = proc do |path|
          if File.respond_to?(:realpath) # 1.9+
            File.realpath(path)
          else
            path
          end
        end

        orig_src = realpath[File.join(Gondler.env.orig_path, 'src')]
        dir = realpath[File.dirname(@path)]
        if dir.start_with?(orig_src)
          @itself = dir[orig_src.size.succ .. -1]
        end
      end

      if @itself
        Gondler::Package.new(@itself, :path => '.')
      end
    end

    def load(path)
      @path = File.expand_path(path)
      instance_eval(File.read(path))
    end

    def gom(name, options = {})
      options[:group] = @now_group if @now_group
      options[:os] = @now_os if @now_os

      package = Gondler::Package.new(name, options)
      @packages.push(package) if package.installable?
    end
    alias_method :package, :gom

    def group(*groups)
      @now_group = groups
      yield if block_given?
    ensure
      @now_group = nil
    end

    def os(*oss)
      @now_os = oss
      yield if block_given?
    ensure
      @now_os = nil
    end

    def autodetect
      deps = `go list -f '{{join .Deps "\\n"}}' ./...`.strip.split(/\n+/)

      deps.each do |dep|
        gom(dep) unless dep.include?('.')
      end
    end

    class NotFound < StandardError
      def initialize(gomfile)
        @gomfile = gomfile
      end

      def message
        "Gondler require gomfile. Your gomfile is not found: #{@gomfile}"
      end
    end
  end
end
