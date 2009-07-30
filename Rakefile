ENV['RDOCOPT'] = "-S -f html -T hanna"

require "rubygems"
require "hoe"
require File.dirname(__FILE__) << "/lib/authlogic_remote_http/version"

Hoe.new("Authlogic Remote HTTP", AuthlogicRemoteHttp::Version::STRING) do |p|
  p.name = "authlogic-remote-http"
  p.rubyforge_name = "authlogic-remote-http"
  p.author = "Ben Johnson of Binary Logic"
  p.email  = 'bjohnson@binarylogic.com'
  p.summary = "Extension of the Authlogic library to add remote HTTP support."
  p.description = "Extension of the Authlogic library to add remote HTTP support."
  p.url = "http://github.com/ess/authlogic_remote_http"
  p.history_file = "CHANGELOG.rdoc"
  p.readme_file = "README.rdoc"
  p.extra_rdoc_files = ["CHANGELOG.rdoc", "README.rdoc"]
  p.remote_rdoc_dir = ''
  p.test_globs = ["test/*/test_*.rb", "test/*_test.rb", "test/*/*_test.rb"]
  p.extra_deps = %w(authlogic)
end
