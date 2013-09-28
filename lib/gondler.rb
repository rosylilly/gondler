require 'gondler/version'
require 'gondler/env'
require 'gondler/package'

module Gondler
  def self.env
    @env ||= Gondler::Env.new
  end
end
