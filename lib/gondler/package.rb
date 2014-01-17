require 'English'

module Gondler
  class Package
    class InstallError < StandardError
    end

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
      @commit || @branch || @tag
    end

    def installable?
      (
        (os.nil? || os.include?(Gondler.env.os)) &&
        (group.empty? || (Gondler.without & group).empty?)
      )
    end

    def resolve
      get
      checkout if target
      install
    end

    def get
      args = %w(go get -d -u)
      args << '-fix' if @fix
      args << @name

      result = `#{args.join(' ')} 2>&1`

      unless $CHILD_STATUS.success?
        raise InstallError.new("#{@name} download error\n" + result)
      end
    end

    def checkout
      src_path = Pathname.new(Gondler.env.path) + 'src'
      @name.split('/').reduce(src_path) do |path, dir|
        path += dir
        if File.directory?(path + '.git')
          break checkout_with_git(path)
        elsif File.directory?(path + '.hg')
          break checkout_with_hg(path)
        end
        path
      end
    end

    def checkout_with_git(path)
      Dir.chdir(path) do
        `git checkout -q #{target}`
      end
    end

    def checkout_with_hg(path)
      Dir.chdir(path) do
        `hg update #{target}`
      end
    end

    def install
      args = %w(go install)
      args << @flag if @flag
      args << @name

      result = `#{args.join(' ')} 2>&1`

      unless $CHILD_STATUS.success?
        raise InstallError.new("#{@name} install error\n" + result)
      end
    end

    def to_s
      "#{@name}" + (target ? " (#{target})" : '')
    end
  end
end
