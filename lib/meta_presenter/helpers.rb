module MetaPresenter::Helpers
  extend ActiveSupport::Concern
  included do
    # Sets up the `presenter.` method as helper within your views
    helper_method :presenter

    # Sets up the `layout_presenter.` method as helper within your views
    helper_method :layout_presenter
  end

  private
    # Initialize presenter with the current controller
    def presenter
      @presenter ||= begin
        yield_self do |controller|
          klass = ApplicationController::Presenters::Builder.new(controller, action_name).presenter_class
          klass.new(controller)
        end
      end
    end

    # Initialize presenter with the current controller
    def layout_presenter
      @layout_presenters ||= {}
      @layout_presenters[current_layout] ||= begin
        yield_self do |controller|
          klass = ApplicationController::Presenters::LayoutBuilder.new(current_layout, layouts).layout_presenter_class
          klass.new(controller)
        end
      end
    end
end