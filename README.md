[![Gem Version](https://badge.fury.io/rb/meta_presenter.svg)](https://badge.fury.io/rb/meta_presenter) [![Build Status](https://travis-ci.org/szTheory/meta_presenter.svg?branch=master)](https://travis-ci.org/szTheory/meta_presenter) [![Coverage Status](https://coveralls.io/repos/github/szTheory/meta_presenter/badge.svg?branch=master)](https://coveralls.io/github/szTheory/meta_presenter?branch=master) [![Inline docs](http://inch-ci.org/github/szTheory/meta_presenter.svg?branch=master)](http://inch-ci.org/github/szTheory/meta_presenter) [![MIT License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/szTheory/meta_presenter/blob/master/LICENSE.txt) [![Gem](https://img.shields.io/gem/dt/meta_presenter.svg)](https://rubygems.org/gems/meta_presenter) [![GitHub stars](https://img.shields.io/github/stars/szTheory/meta_presenter.svg?label=Stars&style=social)](https://github.com/szTheory/meta_presenter)

# MetaPresenter

MetaPresenter is a Ruby gem that gives you access to the powerful presenter pattern in your Rails controllers. For each controller/action pair you get a presenter class in `app/presenters` that you can use in your views with with `presenter.method_name`. This helps you decompose your helper logic into tight, easily testable classes. There's even a DSL for method delegation on objects to reduce boilerplate.

[Github Project Page](https://github.com/szTheory/meta_presenter)

## Installation

Add this line to your application's Gemfile:

    gem 'meta_presenter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install meta_presenter

TODO: add an optional task that generates the scaffolding for you. Or, you can manually create the files you want.

Include MetaPresenter::Helpers in your controller or mailer:

    class ApplicationController < ActionController::Base
      include MetaPresenter::Base
    end

    class ApplicationMailer < ActionMailer::Base
      include MetaPresenter::Base
    end

## Example

Say you have a PagesController with an action for home and logs. Underneath `app/presenters` you can add a class for each action. In this example we'll also create an application and base presenter we'll inherit from to re-use code in the per-action presenters.

    app/
      controllers/
        application_controller.rb
        pages_controller.rb
      presenters/
        application_presenter.rb
        pages/
          base_presenter.rb
          home_presenter.rb
          logs_presenter.rb

app/controllers/page_controller.rb

    class ApplicationController < ActionController::Base
      # Controller methods automatically become available in views and other presenters.
      # So this gives you presenter.current_user in views, and you can call `current_user`
      # within your presenters as well
      def current_user
        User.first
      end
    end

app/controllers/dashboard_controller.rb

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

app/presenters/application_presenter.rb

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

app/presenters/pages/base_presenter.rb:

    class Pages::BasePresenter < ApplicationPresenter
      # Makes presenter.nav_items available for
      # all actions on PagesController
      def nav_items
        [
            {name: "Home", path: home_path},
            {name: "Logs", path: logs_path}
        ]
      end
    end

app/presenters/pages/home_presenter.rb

    class Pages::HomePresenter << Pages::BasePresenter
      # presenter.email, presenter.id
      # or any other method not already defined
      # will delegate to the current_user
      delegate_all_to :current_user

      # presenter.greeting in views
      def greeting
        "Hello, #{current_user.name}"
      end
    end

app/presenters/pages/logs_presenter.rb

    class Pages::LogsPresenter << Pages::BasePresenter
      # presenter.size and presenter.last will delegate to 
      # the controller's private #logs method
      delegate :size, :last, to: :logs

      # presenter.log_text(log) in view
      # for example in a haml view:
      # 
      # - presenter.logs.each do |log|
      #   = presenter.log_text(log)
      #
      def log_text(log)
        log.description
      end
    end

TODO: add more documentation around layout presenters

## Aliasing the presenter methods

If you want to customize the `presenter` and `layout_presenter` methods you can specify a shorthand by adding an alias_method to your controller or mailer:

    class ApplicationController < ActionController::Base
      including MetaPresenter

      # So convenient!
      alias_method :presenter, :p
      alias_method :presenter, :lp
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`) or bugfix branch (`git checkout -b bugfix/my-helpful-bugfix`) 
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Make sure specs are passing (`bundle exec rspec`)
6. Create new Pull Request

## License

See the [LICENSE](https://github.com/szTheory/meta_presenter/blob/master/LICENSE.txt) file.