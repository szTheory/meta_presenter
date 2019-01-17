require 'meta_presenter/builder'
require 'active_support/concern'
require 'active_support/rescuable'

module MetaPresenter
  # Including this module in your controller will give
  # your views access to a `presenter` method that
  # delegates to controller methods
  #
  # class ApplicationController < ActionController::Base
  #   include MetaPresenter::Base
  # end
  #
  # class ApplicationMailer < ActionMailer::Base
  #   include MetaPresenter::Base
  # end
  #
  module Helpers
    extend ActiveSupport::Concern
    included do
      # Sets up the `presenter.` method as helper within your views
      # If you want to customize this for yourself just alias_method it
      helper_method :presenter
    end

    private
      # Initialize presenter with the current controller
      def presenter
        @presenter ||= begin
          controller = self
          klass = MetaPresenter::Builder.new(controller, action_name).presenter_class
          klass.new(controller)
        end
      end
  end
end