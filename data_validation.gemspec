# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'data_validation/version'

Gem::Specification.new do |spec|
  spec.name          = "data_validation"
  spec.version       = DataValidation::VERSION
  spec.authors       = ["Roger Tong"]
  spec.email         = ["Roger.Tong@activenetwork.com", "tomtongt@live.com"]

  spec.summary       = "Data validation for LaxPower"
  spec.description   = "The validation is to compare values between web page values and mobile api responses"
  spec.homepage      = "https://gitlab.dev.activenetwork.com/rtong/data-validation-for-laxpower"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "input later"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["compare"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1.4'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency 'nokogiri', '1.6.6.2'
  spec.add_runtime_dependency 'httparty', '0.8.1'

end
