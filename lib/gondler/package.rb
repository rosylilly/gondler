module Gondler
  class Package
    def initialize(name, options = {})
      @name = name
      @branch = options[:branch]
      @tag = options[:tag]
      @commit = options[:commit]
      @os = options[:os]
      @group = options[:group]
      @fix = options[:fix] || false
      @flag = options[:flag]
    end

    def os
      case @os
      when String
        @os.split(/\s+/)
      when Array
        @os.map(&:to_s).map(&:strip)
      else
        nil
      end
    end

    def group
      case @group
      when String
        @group.split(/\s+/)
      when Array
        @group.map(&:to_s).map(&:strip)
      else
        []
      end
    end

    def target
      @tag || @branch || @commit
    end

    def installable?
      (
        (os.nil? || os.include?(Gondler.env.os)) &&
        (group.empty? || (Gondler.withouts & group).empty?)
      )
    end

    def install
      return unless installable?
    end

    def to_s
      "#{@name}" + (target ? " (#{target})" : '')
    end
  end
end
