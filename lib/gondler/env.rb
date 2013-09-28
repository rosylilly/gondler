module Gondler
  class Env
    class << self
      def accessor(name, source)
        define_method(name) do
          @environments[source]
        end

        define_method("#{name}=") do |val|
          val = val.to_s
          ENV[source.to_s] = val
          @environments[source] = val
        end
      end
    end

    def initialize
      reload!
    end

    def reload!
      @environments = {}
      `go env`.each_line do |define|
        matched = define.match(/\A([A-Z]+)="(.*)"\Z/)
        @environments[matched[1].to_sym] = matched[2] if matched
      end
    end

    accessor :arch, :GOARCH
    accessor :bin, :GOBIN
    accessor :char, :GOCHAR
    accessor :exe, :GOEXE
    accessor :host_arch, :GOHOSTARCH
    accessor :host_os, :GOHOSTOS
    accessor :os, :GOOS
    accessor :path, :GOPATH
    accessor :race, :GORACE
    accessor :root, :GOROOT
    accessor :tool_dir, :GOTOOLDIR
    accessor :cc, :CC
    accessor :gcc_flags, :GOGCCGLAGS
  end
end
