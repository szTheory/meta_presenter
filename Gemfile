source 'https://rubygems.org'

gemspec

# Hinting at development dependencies
# Prevents bundler from taking a long-time to resolve
group :development, :test do
  gem 'builder'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rb-readline'
  gem 'rspec'
end

group :development do
  gem 'rubocop', '~> 1.57', require: false
end
