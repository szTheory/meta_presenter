

Gem::Specification.new do |s|
  s.name          = 'meta_presenter'
  s.version       = '0.2.2'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['szTheory']
  s.description   = %q{Write highly focused and testable view presenter classes for your Rails controllers and actions}
  s.summary       = %q{MetaPresenter is a Ruby gem for writing highly focused and testable view Rails presenter classes. For each controller/action pair you get a presenter class in app/presenters that you can use in your views with with presenter.method_name. This helps you decompose your helper logic into tight, easily testable classes. There's even a DSL for method delegation on objects to reduce boilerplate.}
  s.homepage      = 'https://github.com/szTheory/meta_presenter'
  s.license       = 'MIT'
  s.metadata = {
    "source_code_uri" => "https://github.com/szTheory/meta_presenter",
  }

  s.files         = `git ls-files`.split($/)
  s.test_files    = s.files.grep(%r{^(test|spec)/})
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.1.0'

  s.add_dependency 'actionpack', '>= 3.0.12'
  s.add_dependency 'actionmailer', '>= 3.0.12'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rb-readline'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'appraisal'
end
