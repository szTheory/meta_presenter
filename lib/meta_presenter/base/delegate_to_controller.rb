require 'active_support/concern'

module MetaPresenter
  class Base
    # Give the presenter the ability to delegate methods to
    # a controller (ActionController::Base or ActionMailer::Base)
    module DelegateToController

      # Presenters delegate to private controller methods by default
      INCLUDE_PRIVATE_METHODS = true
      
      extend ActiveSupport::Concern
      included do
        # @return [ActionController::Base, ActionMailer::Base] Controller that this presenter will delegate methods to
        attr_reader :controller

        include InstanceMethods
      end

      module InstanceMethods # :nodoc:

        # Creates a new presenter
        #
        # @param [ActionController::Base, ActionMailer::Base] controller Controller that this presenter will delegate methods to
        # @return [MetaPresenter::Base] a base presenter
        def initialize(controller)
          @controller = controller
        end

        # Check to see whether a method has been either
        # defined by or is delegated by this presenter
        #
        # @param *args method name and the other arguments
        def respond_to_missing?(*args)
          method_name = args.first
          delegates_controller_method?(method_name) || super
        end

        private
          def delegates_controller_method?(method_name)
            controller.respond_to?(method_name, INCLUDE_PRIVATE_METHODS)
          end

          def method_missing(method_name, *args, &block)
            if delegates_controller_method?(method_name)
              controller.send(method_name, *args, &block)
            else
              super
            end
          end
      end
    end
  end
end
