require 'action_controller'

class ApplicationController < ActionController::Base
  include MetaPresenter::Helpers

  def a_method_defined_on_application_controller
    "application controller method return value"
  end
end