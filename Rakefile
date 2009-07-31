ENV['RDOCOPT'] = "-S -f html"

require "rubygems"
require "hoe"
require File.dirname(__FILE__) << "/lib/authlogic_remote_http/version"

Hoe.new("Authlogic Remote HTTP", AuthlogicRemoteHttp::Version::STRING) do |p|
  p.name = "authlogic-remote-http"
  p.rubyforge_name = "authlogic-remote-http"
  p.author = "Dennis Walters"
  p.email  = 'pooster@gmail.com'
  p.summary = "Authlogic add-on providing remote HTTP support."
  p.description = "Authlogic add-on providing remote HTTP support."
  p.url = "http://github.com/ess/authlogic_remote_http"
  p.history_file = "CHANGELOG.rdoc"
  p.readme_file = "README.rdoc"
  p.extra_rdoc_files = ["CHANGELOG.rdoc", "README.rdoc"]
  p.remote_rdoc_dir = ''
  p.test_globs = ["test/*/test_*.rb", "test/*_test.rb", "test/*/*_test.rb"]
  p.extra_deps = %w(authlogic)
end

task :cultivate do
  system "touch Manifest.txt; rake check_manifest | grep -v \"(in \" | patch"
  system "rake debug_gem | grep -v \"(in \" > `basename \\`pwd\\``.gemspec"
end
