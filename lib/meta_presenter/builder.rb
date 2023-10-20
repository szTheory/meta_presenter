require 'active_support/core_ext/object/try'

module MetaPresenter
  # Builds a presenter class for a controller and method
  class Builder
    # @return [ActionController::Base, ActionMailer::Base] Controller that this presenter will delegate methods to
    attr_reader :controller

    # @return [String] Name of the controller's action to hook the presenter up to
    attr_reader :action_name

    # Creates a new Builder
    #
    # @param [ActionController::Base, ActionMailer::Base] controller Controller that this presenter will delegate methods to
    # @param [String] action_name Name of the controller's action to hook the presenter up to
    def initialize(controller, action_name)
      @controller = controller
      @action_name = action_name
    end

    # Error when there's no presenter class defined but a file for it exists
    class FileExistsButPresenterNotDefinedError < NameError
      # Create a new error
      #
      # @param [String] presenter_class_name Class name of presenter
      # @param [String] presenter_file_path File path where the presenter Ruby class was found at
      def initialize(presenter_class_name, presenter_file_path)
        super("Presenter class #{presenter_class_name} is not defined but file exists at #{presenter_file_path}")
      end
    end

    class InvalidControllerError < NameError
      # Create a new error
      def initialize(controller)
        super("You tried to present a #{controller.class.name} class, but only a Rails controller or mailer can be presented")
      end
    end

    # @return [Class] Class constant for the built MetaPresenter::Base presenter
    def presenter_class
      # Try to find the presenter class (Not guaranteed,
      # for example if the presenter class wasn't defined
      # or if the file wasn't found)
      klass = nil
      ancestors.each do |klass_name|
        klass = presenter_class_for(klass_name)
        break unless klass.nil?
      end

      klass
    end

    def presenter_base_dir
      File.join(Rails.root, 'app', 'presenters')
    end

    private

    def all_ancestors
      controller.class.ancestors.select do |ancestor|
        if controller.class <= ActionController::Base
          ancestor <= ActionController::Base
        elsif controller.class <= ActionMailer::Base
          ancestor <= ActionMailer::Base
        else
          raise InvalidControllerError, controller
        end
      end
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
        presenter_file_path = File.join(presenter_base_dir, filename)
        if File.exist?(presenter_file_path)
          raise FileExistsButPresenterNotDefinedError.new(presenter_class_name, presenter_file_path)
        end

        nil
      end
    end

    def ancestors
      # Different ancestors depending on whether
      # we're dealing with a mailer or a controller
      list = if all_ancestors.map(&:to_s).include?('ActionMailer::Base')
               mailer_ancestors
             else
               controller_ancestors
             end

      # add a presenter class for our current action
      # to the front of the list
      presenter_class_name_for_current_action = "#{list.first}::#{action_name.camelcase}"
      list.unshift(presenter_class_name_for_current_action)
    end

    # The list of ancestors is very long.
    # Trim it down to just the length of the class we are looking for.
    #
    # Takes an optional block method to transform the result
    # with a map operation
    def ancestors_until(until_class, &block)
      # trim down the list
      ancestors_list = all_ancestors[0..all_ancestors.index(until_class)]

      # map to the fully qualified class name
      ancestors_list.map(&block)
    end
  end
end
