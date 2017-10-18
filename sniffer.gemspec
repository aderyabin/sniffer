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
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "anyway_config", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.50"
end
