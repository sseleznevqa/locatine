module Locatine
  # constants here...
  VERSION = "0.01084"
  NAME = "locatine"
  HOME = File.readable?("#{Dir.pwd}/lib/#{Locatine::NAME}")? "#{Dir.pwd}/lib/#{Locatine::NAME}" : "#{Gem.dir}/gems/#{Locatine::NAME}-#{Locatine::VERSION}/lib/#{Locatine::NAME}"
end
