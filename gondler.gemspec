# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gondler/version'

Gem::Specification.new do |spec|
  spec.name          = 'gondler'
  spec.version       = Gondler::VERSION
  spec.authors       = ['Sho Kusano']
  spec.email         = ['rosylilly@aduca.org']
  spec.description   = %q{bundler for golang}
  spec.summary       = %q{bundler for golang}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'thor', '~> 0.18.1'
end
