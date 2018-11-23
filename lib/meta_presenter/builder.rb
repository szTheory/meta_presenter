require 'meta_presenter'

module MetaPresenter
  class Builder
    attr_reader :controller, :action_name
    def initialize(controller, action_name)
      @controller = controller
      @action_name = action_name
    end

    def presenter_class
      # Try to find the class (it's not guaranteed)
      klass_name = ancestors.find do |klass_name|
        presenter_class_for(klass_name)
      end

      # Return the actual class
      presenter_class_for(klass_name)
    end

    private
      def all_ancestors
        controller.class.ancestors
      end

      def mailer_ancestors
        ancestors_until(ApplicationMailer) do |klass|
          "Mailers::#{klass.name.gsub('Mailer', '')}"
        end
      end

      def controller_ancestors
        ancestors_until(ApplicationController) do |klass|
          klass.try(:name).try(:gsub, 'Controller', '')
        end
      end
    
      def presenter_class_for(klass_name)
        presenter_class_name = "::#{klass_name}Presenter"
        begin
          presenter_class_name.constantize

        # No corresponding presenter class was found
        rescue NameError => e
          filename = "#{presenter_class_name.underscore}.rb"
          presenter_file_path = File.join(Rails.root, "app", "presenters", filename)
          if File.exists?(presenter_file_path)
            # If the file exists, but the class isn't defined then something
            # has gone wrong that the dev really should know about!
            raise e
          else
            false
          end
        end
      end

      def ancestors
        all_ancestors.yield_self do |list|
          # Different ancestors depending on whether
          # we're dealing with a mailer or a controller
          if list.include?(ActionMailer::Base)
            mailer_ancestors
          else
            controller_ancestors
          end
        end.yield_self do |list|
          # add a presenter class for our current action
          # to the front of the list
          presenter_class_name_for_current_action = "#{list.first}::#{action_name.camelcase}"
          list.unshift(presenter_class_name_for_current_action)
        end
      end

      # The list of ancestors is very long.
      # Trim it down to just the length of the class we are looking for.
      # 
      # Takes an optional block method to transform the result
      # with a map operation
      def ancestors_until(until_class)
        # trim down the list
        ancestors_list = all_ancestors[0..all_ancestors.index(until_class)]

        # map to the fully qualified class name
        if block_given?
          ancestors_list.map { |klass| yield(klass) }
        else
          ancestors_list
        end
      end
  end
end