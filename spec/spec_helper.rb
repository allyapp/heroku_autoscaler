require "bundler/setup"
Bundler.setup

ENV["TZ"] = "CET"

require "heroku_autoscaler"
require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/cassettes"
  c.hook_into :webmock
  c.default_cassette_options = { record: :new_episodes }
end
