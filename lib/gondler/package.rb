require 'English'
require 'pathname'

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
      @path = options[:path]
      @alternate_name = options[:alternate_name] || options[:alias_as] || options[:as]
    end

    attr_reader :name, :branch, :tag, :commit, :os, :group, :fix, :flag, :path, :alternate_name

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
      if @path
        get_by_path
      else
        get_by_package
      end

      if alternate_name
        link_alternate_name
      end
    end

    def checkout
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

    private

    def env_path
      Pathname.new(Gondler.env.path)
    end

    def src_path
      env_path + 'src'
    end

    def get_by_path
      target = src_path.join(@name)
      FileUtils.mkdir_p(target.dirname)
      FileUtils.remove_entry_secure(target) if target.exist?
      if @path.to_s.start_with?('/') # absolute path
        source = @path
      else # relative path from Gomfile
        source = env_path.dirname.join(@path).relative_path_from(target.dirname)
      end
      File.symlink(source, target)
    end

    def get_by_package
      args = %w(go get -d -u)
      args << '-fix' if @fix
      args << @name

      result = `#{args.join(' ')} 2>&1`

      unless $CHILD_STATUS.success?
        raise InstallError.new("#{@name} download error\n" + result)
      end
    end

    def link_alternate_name
      actual_path = src_path.join(@name)
      alternate_path = src_path.join(alternate_name)

      alternate_path.mkpath
      FileUtils.remove_entry_secure(alternate_path) unless alternate_path.symlink?

      alternate_path.make_symlink(actual_path)
    end
  end
end
