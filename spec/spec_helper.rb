# spec coverage
require 'coveralls'
Coveralls.wear!

# debug tool
require "pry"

# main lib module
require "meta_presenter"

# support files
Dir["#{__dir__}/support/*.rb"].each {|file| require file }

# Simulate the Rails env.
# Instead of loading the Rails environment, we stub the bare amount
# and load from spec/support/app as if it were a Rails app
begin
  # mount app dir tree
  Dir["#{__dir__}/support/app/**/*.rb"].each {|file| require file }

  # mock Rails
  class Rails
  end

  # stub Rails.root
  RSpec.configure do |config|
    config.before do
      allow(Rails).to receive(:root).and_return(File.join(__dir__, 'support'))
    end
  end
end