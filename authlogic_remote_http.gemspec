# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{authlogic-remote-http}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dennis Walters"]
  s.date = %q{2009-07-31}
  s.description = %q{Authlogic add-on providing remote HTTP support.}
  s.email = %q{pooster@gmail.com}
  s.extra_rdoc_files = ["Manifest.txt", "CHANGELOG.rdoc", "README.rdoc"]
  s.files = ["CHANGELOG.rdoc", "MIT-LICENSE", "Manifest.txt", "README.rdoc", "Rakefile", "init.rb", "lib/authlogic_remote_http.rb", "lib/authlogic_remote_http/acts_as_authentic.rb", "lib/authlogic_remote_http/session.rb", "lib/authlogic_remote_http/version.rb"]
  s.homepage = %q{http://github.com/ess/authlogic_remote_http}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{authlogic-remote-http}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Authlogic add-on providing remote HTTP support.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<authlogic>, [">= 0"])
      s.add_development_dependency(%q<hoe>, [">= 2.3.2"])
    else
      s.add_dependency(%q<authlogic>, [">= 0"])
      s.add_dependency(%q<hoe>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<authlogic>, [">= 0"])
    s.add_dependency(%q<hoe>, [">= 2.3.2"])
  end
end
