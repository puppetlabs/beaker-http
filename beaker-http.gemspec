# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'beaker-http/version'

Gem::Specification.new do |spec|
  spec.name          = "beaker-http"
  spec.version       = Beaker::Http::Version::STRING
  spec.authors       = ["Puppet"]
  spec.email         = ["qe@puppet.com"]
  spec.summary       = %q{Puppet testing tool}
  spec.description   = %q{Puppet testing tool coupled with Beaker}
  spec.homepage      = "https://github.com/puppetlabs/beaker-http"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  #Development dependencies
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'pry', '~> 0.9.12'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'

  #Documentation dependencies
  spec.add_development_dependency 'yard', '~> 0'
  spec.add_development_dependency 'markdown', '~> 0'
  spec.add_development_dependency 'activesupport', '4.2.6'

  #Run time dependencies
  spec.add_runtime_dependency 'json', '~> 1.8'
  spec.add_runtime_dependency 'beaker', '~> 2.1', '>= 2.1.0'
  spec.add_runtime_dependency 'faraday', '~> 0.9', '>= 0.9.1'
  spec.add_runtime_dependency 'faraday_middleware', '~> 0.9'
end
