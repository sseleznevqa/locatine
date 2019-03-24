Gem::Specification.new do |s|
  s.name        = "locatine"
  s.version     = "0.01659"
  s.summary     = "Element locating tool based on watir"
  s.description = "The main goal to write locators never"
  s.authors     = ["Sergei Seleznev"]
  s.email       = 's_seleznev_qa@hotmail.com'
  s.files       = ["lib/locatine.rb"] + Dir.glob("lib/locatine/*.rb") + Dir.glob("lib/locatine/app/*.*") + Dir.glob("lib/locatine/large_scripts/*.*")
  s.homepage    =
    'https://github.com/sseleznevqa/locatine'
  s.license       = 'MIT'
  s.add_development_dependency "bundler", '~> 0'
  s.add_development_dependency "rspec", '~> 0'
  s.add_development_dependency "simplecov", '~> 0'
  s.add_development_dependency "pry", '~> 0'
  s.add_dependency "watir", '~> 6.16'
  s.add_dependency "json", '~> 2.0'
  s.add_dependency "chromedriver-helper", '~> 2.0'
end
