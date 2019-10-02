# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hiccup/version"

Gem::Specification.new do |s|
  s.name        = "hiccup"
  s.version     = Hiccup::VERSION
  s.authors     = ["Bob Lail"]
  s.email       = ["bob.lailfamily@gmail.com"]
  s.homepage    = "http://boblail.github.com/hiccup/"
  s.summary     = %q{A library for working with things that recur}
  s.description = %q{Hiccup mixes a-la-cart recurrence features into your data structure. It doesn't dictate the data structure, just the interface.}

  s.rubyforge_project = "hiccup"

  s.add_dependency "activesupport", ">= 3.2.8"
  s.add_dependency "activemodel", ">= 3.2.8"
  s.add_dependency "builder"

  s.add_development_dependency "ri_cal"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "minitest-reporters-turn_reporter"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "shoulda-context"
  s.add_development_dependency "pry"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
