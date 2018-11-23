require 'meta_presenter/builder'
require 'active_support/concern'

module MetaPresenter
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
          yield_self do |controller|
            klass = MetaPresenter::Builder.new(controller, action_name).presenter_class
            klass.new(controller)
          end
        end
      end
  end
end