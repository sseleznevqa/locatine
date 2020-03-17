# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'locatine'
  s.version     = '0.03353'
  s.summary     = 'Element locating proxy for selenium'
  s.description = 'The main goal is to write locators (almost) never'
  s.authors     = ['Sergei Seleznev']
  s.email       = 's_seleznev_qa@hotmail.com'
  s.files       = ['lib/locatine.rb', 'README.md'] +
                  Dir.glob('lib/locatine/*.rb') +
                  Dir.glob('lib/locatine/scripts/*.*') +
                  Dir.glob('lib/locatine/daemon_helpers/*.rb') +
                  Dir.glob('lib/locatine/results_helpers/*.rb')
  s.homepage    =
    'https://github.com/sseleznevqa/locatine'
  s.license = 'MIT'
  s.executables = 'locatine-daemon.rb'
  s.add_development_dependency 'bundler', '~> 0'
  s.add_development_dependency 'pry', '~> 0'
  s.add_development_dependency 'rspec', '~> 0'
  s.add_development_dependency 'simplecov', '~> 0'
  s.add_development_dependency 'watir', '~> 6.16'
  s.add_development_dependency 'webdrivers', '~> 4.0', '>= 4.0.1'
  s.add_dependency 'sinatra', '~> 2.0'
  s.add_dependency 'colorize', '~> 0.8'
end
