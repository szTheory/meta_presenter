[![Gem Version](https://badge.fury.io/rb/meta_presenter.svg)](https://badge.fury.io/rb/meta_presenter) [![Build Status](https://travis-ci.org/szTheory/meta_presenter.svg?branch=master)](https://travis-ci.org/szTheory/meta_presenter) [![Coverage Status](https://coveralls.io/repos/github/szTheory/meta_presenter/badge.svg?branch=master)](https://coveralls.io/github/szTheory/meta_presenter?branch=master) [![Inline docs](https://inch-ci.org/github/szTheory/meta_presenter.svg?branch=master)](https://inch-ci.org/github/szTheory/meta_presenter) [![Maintainability](https://api.codeclimate.com/v1/badges/8698d68a87ec1a9bfacd/maintainability)](https://codeclimate.com/github/szTheory/meta_presenter/maintainability) [![MIT License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/szTheory/meta_presenter/blob/master/LICENSE.txt) [![Gem](https://img.shields.io/gem/dt/meta_presenter.svg)](https://rubygems.org/gems/meta_presenter) [![GitHub stars](https://img.shields.io/github/stars/szTheory/meta_presenter.svg?label=Stars&style=social)](https://github.com/szTheory/meta_presenter)

[![logo](https://user-images.githubusercontent.com/28652/50427588-2289cf80-087a-11e9-82e1-ae212adf0d07.png)](https://metapresenter.com)

MetaPresenter is a Ruby gem for writing highly focused and testable Rails view presenter classes. For each controller/action pair you get a presenter class in `app/presenters` that you can use in your views with with `presenter.method_name`. This helps you decompose your helper logic into tight, easily testable classes. There's even a DSL for method delegation on objects to reduce boilerplate.

![overlay-shape-clean-sm](https://user-images.githubusercontent.com/28652/50854229-828c7580-1352-11e9-824b-a78c9a2404fb.png)

## Installation

### 1. Add this line to your application's Gemfile

```ruby
gem 'meta_presenter'
```

### 2. Bundle from the command line

```sh
bundle install
```

### 3. Include MetaPresenter::Helpers in ApplicationController

```ruby
class ApplicationController < ActionController::Base
  include MetaPresenter::Helpers
end
```

```ruby
# mailers are supported too
class ApplicationMailer < ActionMailer::Base
  include MetaPresenter::Helpers
end
```

## Setup

### 1. Create an ApplicationPresenter

ApplicationPresenter methods can be used anywhere in the app. This example makes `presenter.page_title` and `presenter.last_login` accessible from all views.

```ruby
# app/presenters/application_presenter.rb
class ApplicationPresenter < MetaPresenter::BasePresenter
  def page_title
    "My App"
  end

  def last_login
    # controller methods are available to
    # presenters in the same namespace
    time = current_user.last_login_at
    distance_of_time_in_words_to_now(time)
  end
end
```

#### 2. Create presenters for your controllers

This example makes `presenter.tooltip(text)` available for all actions on `PagesController`:

```ruby
# app/presenters/pages_presenter.rb
class PagesPresenter < ApplicationPresenter
  def tooltip(text)
    content_tag(:p, text, class: "font-body1")
  end
end
```

```Erb
<!-- app/views/pages/about.html.erb -->
<h1>About</h1>
<p data-tipsy-content="<%= presenter.tooltip("Don't Be Evil") %>">Gloogle</p>
```

#### 3. Create presenters for specific actions

This example makes `presenter.greeting` accessible from views. It also delegates undefined methods to `current_user`, so `presenter.email` would call `current_user.email`:

```ruby
# app/presenters/pages/home_presenter.rb
class Pages::HomePresenter < PagesPresenter
  # can also delegate specific methods. ex:
  # delegate :email, :last, to: :current_user
  delegate_all_to = :current_user

  def greeting
    "Hello, #{name}"
  end
end
```

```Erb
<!-- app/views/pages/home.html.erb -->
<h1>Home</h1>
<p><%= presenter.greeting %></p>
<p>Last login <%= presenter.last_login %></p>
```

## Example directory structure

Note that presenters mirror the namespace of controllers.

```diagram
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

MetaPresenter supports Ruby >= 2.7.5 and ActionPack/ActionMailer >= 6, or >= 7.0.1 for Rails 7 (7.0.0 has a bug)

## Links

- [Project website](https://metapresenter.com)
- [RDocs for the master branch](https://www.rubydoc.info/github/szTheory/meta-presenter/master)

## Specs

To run the specs for the currently running Ruby version, run `bundle install` and then `bundle exec rspec`. To run specs for every supported version of ActionPack, run `bundle exec appraisal install` and then `bundle exec appraisal rspec`.

## Gem release

Make sure the specs pass, bump the version number in meta_presenter.gemspec, build the gem with `gem build meta_presenter.gemspec`. Commit your changes and push to Github, then tag the commit with the current release number using Github's Releases interface (use the format vx.x.x, where x is the semantic version number). You can pull the latest tags to your local repo with `git pull --tags`. Finally, push the gem with `gem push meta_presenter-version-number-here.gem`.

## TODO High-Priority

- Add a `rake meta_presenter:install` that generates the scaffolding for you
- Make sure directions are clear for manually creating presenters

## TODO

- create an example app and link to the repo for it in this README
- add support for layout-level presenters

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`) or bugfix branch (`git checkout -b bugfix/my-helpful-bugfix`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Make sure specs are passing (`bundle exec rspec`)
6. Create new Pull Request

## Running the specs

To run specs against different versions of Rails:

```bash
bundle exec appraisal install #install dependencies for each ruby version
bundle exec appraisal rails6 rspec #run rails 6 specs on current Ruby
bundle exec appraisal rails7 rspec #run rails 7 specs on current Ruby
```

## License

See the [LICENSE](https://github.com/szTheory/meta_presenter/blob/master/LICENSE.txt) file.
