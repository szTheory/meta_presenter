[![Gem Version](https://badge.fury.io/rb/meta_presenter.svg)](https://badge.fury.io/rb/meta_presenter) [![Build Status](https://travis-ci.org/szTheory/meta_presenter.svg?branch=master)](https://travis-ci.org/szTheory/meta_presenter) [![Coverage Status](https://coveralls.io/repos/github/szTheory/meta_presenter/badge.svg?branch=master)](https://coveralls.io/github/szTheory/meta_presenter?branch=master) [![Inline docs](https://inch-ci.org/github/szTheory/meta_presenter.svg?branch=master)](https://inch-ci.org/github/szTheory/meta_presenter) [![Maintainability](https://api.codeclimate.com/v1/badges/8698d68a87ec1a9bfacd/maintainability)](https://codeclimate.com/github/szTheory/meta_presenter/maintainability) [![MIT License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/szTheory/meta_presenter/blob/master/LICENSE.txt) [![Gem](https://img.shields.io/gem/dt/meta_presenter.svg)](https://rubygems.org/gems/meta_presenter) [![GitHub stars](https://img.shields.io/github/stars/szTheory/meta_presenter.svg?label=Stars&style=social)](https://github.com/szTheory/meta_presenter)

[![logo](https://user-images.githubusercontent.com/28652/50427588-2289cf80-087a-11e9-82e1-ae212adf0d07.png)](https://metapresenter.com)

MetaPresenter is a Ruby gem that gives you access to the powerful presenter pattern in your Rails controllers. For each controller/action pair you get a presenter class in `app/presenters` that you can use in your views with with `presenter.method_name`. This helps you decompose your helper logic into tight, easily testable classes. There's even a DSL for method delegation on objects to reduce boilerplate.

![overlay-shape-clean-sm](https://user-images.githubusercontent.com/28652/50854229-828c7580-1352-11e9-824b-a78c9a2404fb.png)

## Installation

1. Add this line to your application's Gemfile:

```ruby
gem 'meta_presenter'
```

2. Bundle from the command line:

```sh
$ bundle
```

3. Include MetaPresenter::Helpers in your controller or mailer:

```ruby
class ApplicationController < ActionController::Base
  include MetaPresenter::Helpers
end
```

```ruby
class ApplicationMailer < ActionMailer::Base
  include MetaPresenter::Helpers
end
```

## Example

Say you have a PagesController with an action for home and logs. Underneath `app/presenters` you can add a class for each action. In this example we'll also create an application and base presenter we'll inherit from to re-use code in the per-action presenters.

```
app/
  controllers/
    application_controller.rb
    pages_controller.rb
  presenters/
    application_presenter.rb
    pages_presenter.rb
    pages/
      home_presenter.rb
      logs_presenter.rb
  views
    pages
      home.html.erb
      logs.html.erb
spec/ (or test/)
  presenters/
    application_presenter_spec.rb
    pages_presenter_spec.rb
    pages/
      home_presenter_spec.rb
      logs_presenter_spec.rb
```

app/controllers/page_controller.rb

```ruby
class ApplicationController < ActionController::Base
  include MetaPresenter::Helpers

  # Controller methods automatically become available in views and other presenters.
  # So this gives you presenter.current_user in views, and you can call `current_user`
  # within your presenters as well
  def current_user
    User.first
  end
end
```

app/controllers/dashboard_controller.rb

```ruby
class ApplicationController < ActionController::Base
  def home
  end

  def logs
  end

  private
    # presenter.logs in views
    def logs
      Log.all
    end
end
```

app/presenters/application_presenter.rb

```ruby
class ApplicationPresenter < MetaPresenter::BasePresenter
  # Makes presenter.page_title available in all of your app's views
  def page_title
    "My App"
  end

  # presenter.last_login_at in views
  def last_login_at
    # controller methods from within the same scope
    # as the presenter are directly available
    current_user.last_login_at
  end
end
```

app/presenters/pages_presenter.rb:

```ruby
class PagesPresenter < ApplicationPresenter
  # Makes presenter.nav_items available for
  # all actions on PagesController
  def nav_items
    [
        {name: "Home", path: home_path},
        {name: "Logs", path: logs_path}
    ]
  end
end
```

app/presenters/pages/home_presenter.rb

```ruby
class Pages::HomePresenter < PagesPresenter
  # presenter.email, presenter.id or any other
  # method not already defined will delegate to
  # the current_user
  delegate_all_to :current_user

  # presenter.greeting in views
  def greeting
    "Hello, #{current_user.name}"
  end
end
```

app/views/pages/home.html.haml

```Haml
%h1 Home
%p #{greeting}
%p Last login #{distance_of_time_in_words_to_now(last_login_at)}
```

app/presenters/pages/logs_presenter.rb

```ruby
class Pages::LogsPresenter < PagesPresenter
  # presenter.size and presenter.last will delegate to 
  # the controller's private `#logs`
  delegate :size, :last, to: :logs

  # presenter.log_text(log) in view
  def log_text(log)
    log.description
  end
end
```

app/views/pages/logs.html.haml

```Haml
%h1 Logs
%p Num logs: #{presenter.size}
%p Last log: #{presenter.log_text(presenter.last)}
%ul
  - presenter.logs.each do |log|
    %li= presenter.log_text(log)
```

## Aliasing the presenter methods

If you want to customize the `presenter` method you can specify a shorthand by adding an alias_method to your controller or mailer:

```ruby
class ApplicationController < ActionController::Base
  including MetaPresenter

  # So convenient!
  alias_method :presenter, :pr
end
```

## Requirements

MetaPresenter supports Ruby >= 2.1 and ActionPack >= 4.0. If you'd like to help adding support for older versions please submit a pull request with passing specs.

## Links

* [Project website](https://metapresenter.com)
* [RDocs for the master branch](https://www.rubydoc.info/github/szTheory/meta-presenter/master)

## TODO
* tests for ActionMailer support
* optional `rake meta_presenter:install` that generates the scaffolding for you. Or, you can manually create the files you want.
* add support for layout-level presenters

## TODO (lower priority)
* add backwards compatibility for actionsupport3, will require enabling it in the Appraisal file and then fixing any bugs in the build
* add Middleman support (?)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`) or bugfix branch (`git checkout -b bugfix/my-helpful-bugfix`) 
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Make sure specs are passing (`bundle exec rspec`)
6. Create new Pull Request

## License

See the [LICENSE](https://github.com/szTheory/meta_presenter/blob/master/LICENSE.txt) file.