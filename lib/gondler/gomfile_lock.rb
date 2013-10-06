require 'gondler/env'

module Gondler
  class GomfileLock

    attr_reader :lists

    def initialize(gomfile_name='Gomfile')
      @lists = []
      @gomfile = gomfile_name
    end

    def <<(package)
      @lists << package
    end

    def label
      @lists.map do |package|
        if package.branch
          "#{package.name}: branch => #{package.target}".strip
        elsif package.tag
          "#{package.name}: tag => #{package.target}".strip
        elsif package.commit
          "#{package.name}: commit => #{package.target}".strip 
        else
          Dir.chdir(path(package)) do
            rev = `git rev-parse HEAD` if File.exists?('.git')
            rev = `hg log -l 1 --template "{node}"` if File.exists?('.hg')
            "#{package.name}: commit => #{rev}".strip unless rev.length == 0 
          end
        end
      end
    end

    def path(package)
      "#{Gondler::Env.new.path}/src/#{package.name}"
    end

    def freeze
      File.open(@gomfile + '.lock', 'w') { |io| io.puts label.join("\n") }
    end

  end
end
