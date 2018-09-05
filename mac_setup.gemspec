# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mac_setup/version"

Gem::Specification.new do |spec|
  spec.name          = "mac_setup"
  spec.version       = MacSetup::VERSION
  spec.authors       = ["Matt Wean"]
  spec.email         = ["matthew.wean@gmail.com"]

  spec.summary       = "Tool to set up a Mac"
  spec.license       = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop", "~> 0.34.2"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "pry"
end
