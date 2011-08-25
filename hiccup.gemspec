# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hiccup/version"

Gem::Specification.new do |s|
  s.name        = "hiccup"
  s.version     = Hiccup::VERSION
  s.authors     = ["Bob Lail"]
  s.email       = ["bob.lailfamily@gmail.com"]
  s.homepage    = "http://boblail.github.com/hiccup/"
  s.summary     = %q{Recurrence features a-la-cart}
  s.description = %q{Recurrence features a-la-cart}

  s.rubyforge_project = "hiccup"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
