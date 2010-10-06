# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'oban/version'
 
Gem::Specification.new do |s|
  s.name        = "oban"
  s.version     = Oban::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ian Eyberg"]
  s.email       = ["ian@seeinginteractive.com"]
  s.homepage    = "http://github.com/feydr/oban"
  s.summary     = "deploy multiple apps with submodules to heroku (and others) with ease"
  s.description = "deploy multiple apps with submodules to heroku (and others) with ease"
 
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "oban"
 
  s.add_development_dependency "rspec"
 
  s.files        = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md ROADMAP.md CHANGELOG.md)
  s.executables  = ['oban']
  s.require_path = 'lib'
end
