module Locatine
  # constants here...
  generator = Random.new 42
  versions = []
  1000.times do
    versions.push generator.rand.round(5)
  end
  ITERATION = 0
  VERSION = versions.sort[ITERATION].to_s
  NAME = "locatine"
  HOME = File.readable?("#{Dir.pwd}/lib/#{Locatine::NAME}")? "#{Dir.pwd}/lib/#{Locatine::NAME}" : "#{Gem.dir}/gems/#{Locatine::NAME}-#{Locatine::VERSION}/lib/#{Locatine::NAME}"
end
