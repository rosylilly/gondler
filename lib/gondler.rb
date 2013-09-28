require 'open3'
require 'gondler/version'
require 'gondler/env'
require 'gondler/package'
require 'gondler/gomfile'

module Gondler
  class << self
    def withouts
      @withouts || []
    end

    def withouts=(withouts)
      @withouts = withouts.map(&:strip)
    end

    def env
      @env ||= Gondler::Env.new
    end
  end
end
