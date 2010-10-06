$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "oban/version"
 
task :build do
  system "gem build oban.gemspec"
end
 
task :release => :build do
  system "gem push oban-#{Oban::VERSION}.gem"
end
