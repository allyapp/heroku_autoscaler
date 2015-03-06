# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'heroku_autoscaler/version'

Gem::Specification.new do |spec|
  spec.name          = "heroku_autoscaler"
  spec.version       = HerokuAutoscaler::VERSION
  spec.authors       = ["Yone Lacort"]
  spec.email         = ["yonedev@gmail.com"]
  spec.summary       = %q{Heroku dynos autoscaling}
  spec.description   = %q{Heroku dynos autoscaling}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mail"
  spec.add_dependency "heroku-api"
  spec.add_dependency "faraday"
  spec.add_dependency "virtus"
  spec.add_dependency "dalli"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "ruby_gntp"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard-rubocop"
end
