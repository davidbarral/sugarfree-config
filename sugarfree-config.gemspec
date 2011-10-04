# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sugarfree-config/version"

Gem::Specification.new do |s|
  s.name        = "sugarfree-config"
  s.version     = SugarfreeConfig::VERSION
  s.authors     = ["David Barral"]
  s.email       = ["contact@davidbarral.com"]
  s.homepage    = "http://github.com/davidbarral/sugarfree-config"
  s.summary     = "Configuration handling the easy way"
  s.description = "Access to per Rails environment configuration stored in a YAML file"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency('mocha')
  s.add_development_dependency('turn')
end
