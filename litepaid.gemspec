# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'litepaid/version'

Gem::Specification.new do |spec|
  spec.name          = "litepaid"
  spec.version       = Litepaid::VERSION
  spec.authors       = ["Ca Phun Ung"]
  spec.email         = ["info@tofugear.com"]

  spec.summary       = %q{Litepaid API Client for Ruby}
  spec.description   = %q{Accept Bitcoin, Litecoin, Dogecoin, DigiBytes and more through the LitePaid service - a fast and easy way to accept digital currencies.}
  spec.homepage      = "https://github.com/tofugear/litepaid-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "rest-client", "~> 1.8"
  spec.add_dependency('json', '~> 1.8')
end