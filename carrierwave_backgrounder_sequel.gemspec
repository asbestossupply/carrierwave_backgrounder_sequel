Gem::Specification.new do |s|
  s.name            = 'carrierwave_backgrounder_sequel'
  s.description     = %q{Sequel support for CarrierWave Backgrounder}
  s.summary         = %q{Add support for Sequel to the carrierwave_backgrounder gem}
  s.licenses        = ['MIT']
  s.authors         = ["Noah Blumenthal"]
  s.email           = 'noah@hackerhasid.com'

  s.files           = `git ls-files`.split("\n")
  s.executables     = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files      = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths   = ["lib"]
  s.version         = '0.0.1'

  s.add_dependency "carrierwave_backgrounder", ["~> 0.3.0"]
  s.add_dependency 'orm_adapter-sequel'

  s.add_development_dependency "rspec", ["~> 2.14.1"]
end