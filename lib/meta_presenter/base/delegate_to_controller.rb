require 'active_support/concern'

module MetaPresenter
  class Base
    module DelegateToController
      INCLUDE_PRIVATE_METHODS = true
      
      extend ActiveSupport::Concern
      included do
        attr_reader :controller
        include InstanceMethods
      end

      module InstanceMethods
        def initialize(controller)
          @controller = controller
        end

        def respond_to_missing?(*args)
          method_name = args.first
          delegates_controller_method? || super
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
