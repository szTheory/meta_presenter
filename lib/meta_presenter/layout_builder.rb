module MetaPresenter
  class LayoutBuilder
    class NoLayoutImplemented < NotImplementedError
      def initialize(current_layout, layouts)
        super("No layout presenter definition found for #{current_layout} among #{layouts}")
      end
    end

    attr_reader :layouts, :current_layout
    def initialize(layouts, current_layout)
      @layouts = layouts
      @current_layout = current_layout
    end

    def layout_presenter_class
      return nil if layout_index.nil?

      layout_classes(layout_index).find do |klass_name|
        layout_presenter_class_for(klass_name)
      end.tap do |klass|
        if klass.blank?
          raise NoLayoutImplemented.new(current_layout, layouts)
        end
      end
    end

    private
      def layout_presenter_class_for(klass_name)
        layout_presenter_class_name = "Layouts::#{klass_name.camelcase}Presenter"
        begin
          layout_presenter_class_name.constantize

        # No corresponding presenter class was found
        rescue NameError => e
          layout_presenter_file_path = Rails.root.join("app", "presenters", "layouts", "#{layout_presenter_class_name.underscore}.rb")
          if File.exists?(layout_presenter_file_path)
            # If the file exists, but the class isn't defined then something
            # has gone wrong that the dev really should know about!
            raise e
          else
            false
          end
        end
      end

      def layout_index
        layouts.index(current_layout)
      end

      def layout_classes
        layouts[0..layout_index].reverse
      end
  end
end