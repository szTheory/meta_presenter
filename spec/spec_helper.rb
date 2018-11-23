require 'coveralls'
Coveralls.wear!

require "meta_presenter"
require "database_cleaner"
require "support/database_cleaner"
require "support/application_controller"
require "pry"

# ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

# ActiveRecord::Schema.define do
#   self.verbose = true

#   create_table :users, force: true do |t|
#     t.string :name
#   end

#   create_table :posts, force: true do |t|
#     t.string :content
#     t.integer :user_id
#     t.timestamps
#   end
# end
