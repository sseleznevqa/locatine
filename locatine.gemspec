Gem::Specification.new do |s|
  s.name        = "locatine"
  s.version     = "0.02535"
  s.summary     = "Element locating tool based on watir"
  s.description = "The main goal to write locators never"
  s.authors     = ["Sergei Seleznev"]
  s.email       = 's_seleznev_qa@hotmail.com'
  s.files       = ["lib/locatine.rb", "README.md"] +
                  Dir.glob("lib/locatine/*.rb") +
                  Dir.glob("lib/locatine/app/*.*") +
                  Dir.glob("lib/locatine/large_scripts/*.*") +
                  Dir.glob("lib/locatine/for_search/*.rb")
  s.homepage    =
    'https://github.com/sseleznevqa/locatine'
  s.license       = 'MIT'
  s.executables = "locatine-daemon.rb"
  s.add_development_dependency "bundler", '~> 0'
  s.add_development_dependency "rspec", '~> 0'
  s.add_development_dependency "simplecov", '~> 0'
  s.add_development_dependency "pry", '~> 0'
  s.add_dependency "watir", '~> 6.16'
  s.add_dependency "json", '~> 2.0'
  s.add_dependency 'webdrivers', '~> 4.0', '>= 4.0.1'
  s.add_dependency 'sinatra', '>= 2.0.5'
end
