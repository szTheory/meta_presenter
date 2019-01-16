require 'action_mailer'

class ApplicationMailer < ActionMailer::Base
  include MetaPresenter::Helpers
end