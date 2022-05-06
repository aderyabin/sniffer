# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sniffer/version"

Gem::Specification.new do |spec|
  spec.name          = "sniffer"
  spec.version       = Sniffer::VERSION
  spec.authors       = ["Andrey Deryabin"]
  spec.email         = ["aderyabin@evilmartians.com"]

  spec.summary       = %q{Analyze HTTP Requests}
  spec.description   = %q{Analyze HTTP Requests}
  spec.homepage      = "http://github.com/aderyabin/sniffer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "anyway_config", ">= 1.0"
  spec.add_dependency "dry-initializer", "~> 3"

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "sinatra", "~> 2.0"
  spec.add_development_dependency "puma", ">= 3.10.0"
  spec.add_development_dependency "httpclient", ">= 2.8.3"
  spec.add_development_dependency "http", ">= 3.0.0"
  spec.add_development_dependency "patron", ">= 0.10.0"
  spec.add_development_dependency "curb", ">= 0.9.4"
  spec.add_development_dependency "ethon", ">= 0.11.0"
  spec.add_development_dependency "typhoeus", ">= 0.9.0"
  spec.add_development_dependency "em-http-request", ">= 1.1.0"
  spec.add_development_dependency "excon", ">= 0.60.0"
end
