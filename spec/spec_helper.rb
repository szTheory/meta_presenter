require 'coveralls'
Coveralls.wear!

require "meta_presenter"
Dir["#{__dir__}/support/app/**/*.rb"].each {|file| require file }
require "pry"

unless defined?(Rails)
  class Rails
  end
end

RSpec.configure do |config|
  config.before do
    allow(Rails).to receive(:root).and_return(File.join(__dir__, 'support'))
  end
end