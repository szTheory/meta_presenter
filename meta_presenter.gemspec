# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'meta_presenter'
  spec.version       = '0.1.0'
  spec.authors       = ['szTheory']
  spec.description   = %q{Presenter pattern in your Rails controllers and actions}
  spec.summary       = %q{MetaPresenter is a Ruby gem that gives you access to the powerful presenter pattern in your Rails controllers. For each controller/action pair you get a presenter class in `app/presenters` that you can use in your views with with `presenter.method_name`. This helps you decompose your helper logic into small, tight, classes that are easily testable. There's even a DSL for method delegation on objects to reduce boilerplate.}
  spec.homepage      = 'https://github.com/szTheory/meta_presenter'
  spec.license       = 'MIT'
  spec.metadata = {
    "source_code_uri" => "https://github.com/szTheory/meta_presenter",
  }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'actionpack', '>= 3.0'
  spec.add_runtime_dependency 'actionmailer', '>= 3.0'

  # spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rb-readline'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'coveralls'
end
