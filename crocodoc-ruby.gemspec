Gem::Specification.new do |s|
  s.name = %q{crocodoc-ruby}
  s.version = "0.0.2"

  s.add_dependency 'json'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'ruby-debug'

  s.authors = ["Instructure", "Lexim"]
  s.date = %q{2012-08-07}
  s.extra_rdoc_files = %W(LICENSE)
  s.files = %W(
          LICENSE
          README.md
          lib/crocodoc.rb
          lib/crocodoc/api.rb
          lib/crocodoc/fake_server.rb
          lib/generators/crocodoc/templates/initializer.rb
          lib/generators/crocodoc/templates/crocodoc.yml
          lib/generators/crocodoc/install_generator.rb
          lib/generators/crocodoc.rb
          crocodoc-ruby.gemspec
  )
  s.homepage = %q{http://github.com/instructure/crocodoc-ruby}
  s.require_paths = %W(lib)
  s.summary = %q{Ruby library for interacting with v2 of the Crocodoc API.}
end
