require 'open3'
require 'gondler/version'
require 'gondler/env'
require 'gondler/package'
require 'gondler/gomfile'

module Gondler
  class << self
    def without(_without = nil)
      if block_given?
        _without, @without = without, _without
        yield
        @without = _without
      end
      @without || []
    end

    def env
      @env ||= Gondler::Env.new
    end
  end
end
