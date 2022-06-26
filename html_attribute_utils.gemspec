$LOAD_PATH.push File.expand_path('lib', __dir__)

Gem::Specification.new do |s|
  s.name        = "html-attributes-utils"
  s.version     = "0.9.2"
  s.authors     = ["Peter Yates"]
  s.email       = ["peter.yates@graphia.co.uk"]
  s.homepage    = "https://github.com/DFE-Digital/html-attributes-utils"
  s.summary     = "HTML attribute hash utilities"
  s.description = "A small collection of utilities to ease working with hashes of HTML attributes"
  s.license     = "MIT"
  s.files       = Dir["{app,lib}/**/*", "LICENSE", "README.md"]
  s.metadata    = {
    "bug_tracker_uri" => "https://github.com/DFE-Digital/html-attributes-utils/issues",
    "changelog_uri" => "https://github.com/DFE-Digital/html-attributes-utils/releases",
    "homepage_uri" => "https://govuk-form-builder.netlify.app",
    "source_code_uri" => "https://github.com/DFE-Digital/html-attributes-utils",
    "github_repo" => "https://github.com/DFE-Digital/html-attributes-utils",
    "documentation_uri" => "https://www.rubydoc.info/gems/html-attributes-utils/",
    "rubygems_mfa_required" => "true",
  }

  rails_version = ENV.fetch("RAILS_VERSION") { "6.1.4.4" }

  if ENV.key?("RAILS_VERSION")
    s.add_dependency("activesupport", "~> #{rails_version}")
  else
    s.add_dependency("activesupport", ">= #{rails_version}")
  end

  s.add_development_dependency("debug")
  s.add_development_dependency("rspec", "~> 3.11.0")
  s.add_development_dependency("rubocop-govuk", "~> 4.3.0")
  s.add_development_dependency("simplecov", "~> 0.20")
end
