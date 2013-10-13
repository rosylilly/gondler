require 'gondler/package'

module Gondler
  class Gomfile
    def initialize(path)
      raise NotFound, path unless File.exist?(path)
      @packages = []

      load(path)
    end
    attr_reader :packages

    def load(path)
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
