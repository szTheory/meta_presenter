require 'action_controller'

class ApplicationController < ActionController::Base
  include MetaPresenter::Helpers
end