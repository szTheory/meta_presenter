require 'active_support/concern'
require 'active_support/core_ext/class/attribute'

module MetaPresenter
  class Base
    # Give the presenter the ability to delegate methods to an object
    module DelegateAllTo

      extend ActiveSupport::Concern
      included do
        # Name of an object that when specified will delegate to
        # all incoming methods send to the presenter that
        # we not already handled by the presenter otherwise
        # (such as explicitly defining the method)
        class_attribute :delegate_all_to

        include InstanceMethods
      end

      module InstanceMethods # :nodoc:

        # Check to see whether a method has been either
        # defined by or is delegated by this presenter
        #
        # @param *args method name and the other arguments
        def respond_to_missing?(*args)
          method_name = args.first
          delegate_all_responds_to?(method_name) || super
        end

        private
          def delegate_all_responds_to?(method_name)
            delegate_all_to? && delegate_all_to.respond_to?(method_name)
          end

          # Use metaprogramming to delegate all methods
          def method_missing(method_name, *args, &block)
            # If `delegate_all_to` has been set up for the method name
            # then delegate to it, otherwise pass it up the food chain
            if !delegating_all_to? && delegate_all_responds_to?(method_name)
              delegate_all_to.send(method_name, *args, &block)
            else
              super
            end
          end

          def delegate_all_to
            # Temporarily set a flag that we are delegating 
            # to an underlying method. this allows us
            # to chain additional methods calls onto the end
            @delegating = true
            send(self.class.delegate_all_to)
          ensure
            # Cleanup the flag afterwards to close the door behind us
            @delegating = false
          end

          def delegating_all_to?
            @delegating == true
          end

          def delegate_all_to?
            self.class.delegate_all_to.present?
          end
      end
    end
  end
end