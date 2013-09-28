module Gondler
  class Package
    def initialize(name, options = {})
      @name = name
      @branch = options[:branch]
      @tag = options[:tag]
      @commit = options[:commit]
      @os = options[:os]
      @group = options[:group]
      @flag = options[:flag]
    end

    def os
      case @os
      when String
        @os.split(/\s+/)
      when Array
        @os.map(&:to_s).map(&:strip)
      else
        @os
      end
    end

    def installable?
      os.nil? || os.include?(Gondler.env.os)
    end

    def install
      return unless installable?
    end
  end
end
