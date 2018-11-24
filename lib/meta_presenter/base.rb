require_relative 'base/delegate_all_to.rb'
require_relative 'base/delegate_to_controller.rb'

module MetaPresenter

  # Base presenter class. Inherit from this it in order 
  # to get a presenter you can use in your views
  # 
  # # app/presenters/application_presenter.rb 
  # class ApplicationPresenter < MetaPresenter::Base
  #   def message
  #     "Hello"
  #   end
  # end
  class Base
    include DelegateToController
    # Comes last so `delegate_all_to` takes priority 
    # over default controller actions
    include DelegateAllTo

    # Displayed in errors involving the presenter
    def inspect
      # Concise to not dump too much information on the dev
      "#<#{self.class.name}>"
    end
  end
end