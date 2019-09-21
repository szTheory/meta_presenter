[![Gem Version](https://badge.fury.io/rb/meta_presenter.svg)](https://badge.fury.io/rb/meta_presenter) [![Build Status](https://travis-ci.org/szTheory/meta_presenter.svg?branch=master)](https://travis-ci.org/szTheory/meta_presenter) [![Coverage Status](https://coveralls.io/repos/github/szTheory/meta_presenter/badge.svg?branch=master)](https://coveralls.io/github/szTheory/meta_presenter?branch=master) [![Inline docs](https://inch-ci.org/github/szTheory/meta_presenter.svg?branch=master)](https://inch-ci.org/github/szTheory/meta_presenter) [![Maintainability](https://api.codeclimate.com/v1/badges/8698d68a87ec1a9bfacd/maintainability)](https://codeclimate.com/github/szTheory/meta_presenter/maintainability) [![MIT License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/szTheory/meta_presenter/blob/master/LICENSE.txt) [![Gem](https://img.shields.io/gem/dt/meta_presenter.svg)](https://rubygems.org/gems/meta_presenter) [![GitHub stars](https://img.shields.io/github/stars/szTheory/meta_presenter.svg?label=Stars&style=social)](https://github.com/szTheory/meta_presenter)

[![logo](https://user-images.githubusercontent.com/28652/50427588-2289cf80-087a-11e9-82e1-ae212adf0d07.png)](https://metapresenter.com)

MetaPresenter is a Ruby gem for writing highly focused and testable Rails view presenter classes. For each controller/action pair you get a presenter class in `app/presenters` that you can use in your views with with `presenter.method_name`. This helps you decompose your helper logic into tight, easily testable classes. There's even a DSL for method delegation on objects to reduce boilerplate.

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

Say you have a PagesController with `#home` and `#logs` actions. Underneath app/presenters you can add a presenter class for each action (Pages::HomePresenter and Pages::LogsPresenter). We'll also create an ApplicationPresenter superclass for methods that can be used in any action throughout the app.

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

app/presenters/pages_presenter.rb

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
  delegate_all_to = :current_user

  # presenter.greeting in views
  def greeting
    "Hello, #{current_user.name}"
  end
end
```

app/views/pages/home.html.erb

```Erb
<h1>Home</h1>
<p><%= presenter.greeting %></p>
<p>Last login <%= distance_of_time_in_words_to_now(presenter.last_login_at) %></p>
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

app/views/pages/logs.html.erb

```Erb
<h1>Logs</h1>
<p>Num logs: #{presenter.size}</p>
<p>Last log: #{presenter.log_text(presenter.last)}</p>
<ul>
  <% presenter.logs.each do |log| %>
    <li>
      <%= presenter.log_text(log) %>
    </li>
  <% end %>
</ul>
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

MetaPresenter supports Ruby >= 2.1 and ActionPack/ActionMailer >= 3.0.12. If you'd like to help adding support for older versions please submit a pull request with passing specs.

## Links

* [Project website](https://metapresenter.com)
* [RDocs for the master branch](https://www.rubydoc.info/github/szTheory/meta-presenter/master)

## Specs
To run the specs for the currently running Ruby version, run `bundle install` and then `bundle exec rspec`. To run specs for every supported version of ActionPack, run `bundle exec appraisal install` and then `bundle exec appraisal rspec`.

## Gem release
Make sure the specs pass, bump the version number in meta_presenter.gemspec, build the gem with `gem build meta_presenter.gemspec`. Commit your changes and push to Github, then tag the commit with the current release number using Github's Releases interface (use the format vx.x.x, where x is the semantic version number). You can pull the latest tags to your local repo with `git pull --tags`. Finally, push the gem with `gem push meta_presenter-version-number-here.gem`.

## TODO High-Priority
* Add a `rake meta_presenter:install` that generates the scaffolding for you
* Make sure directions are clear for manually creating presenters

## TODO
* create an example app and link to the repo for it in this README
* proofread the README instructions to make sure everything is correct
* add support for layout-level presenters
* add Rails 6 support once it comes out (hopefully just have to add a gemfiles/actionpack6.gemfile and it will run with the Appraisal suite)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`) or bugfix branch (`git checkout -b bugfix/my-helpful-bugfix`) 
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Make sure specs are passing (`bundle exec rspec`)
6. Create new Pull Request

## License

See the [LICENSE](https://github.com/szTheory/meta_presenter/blob/master/LICENSE.txt) file.
