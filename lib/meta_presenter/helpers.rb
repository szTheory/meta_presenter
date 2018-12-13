require 'meta_presenter/builder'
require 'active_support/concern'

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

    class PresenterClassNotFoundError < NameError
      def initialize(controller, action_name)
        super("No presenter class and method found for #{controller.class.name}##{action_name} (Are you rendering another action's template? If so then move your presenter method to a base presenter class for the controller that both action presenters inherit from)")
      end
    end

    private
      # Initialize presenter with the current controller
      def presenter
        @presenter ||= begin
          controller = self
          klass = MetaPresenter::Builder.new(controller, action_name).presenter_class
          raise PresenterClassNotFoundError.new(controller, action_name) if klass == :undefined_presenter_class
          klass.new(controller)
        end
      end
  end
end