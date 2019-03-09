module Locatine
  # constants here...
  VERSION = '0.01135'.freeze
  NAME = 'locatine'.freeze
  HOME = if File.readable?("#{Dir.pwd}/lib/#{Locatine::NAME}")
           "#{Dir.pwd}/lib/#{Locatine::NAME}"
         else
           "#{Gem.dir}/gems/#{Locatine::NAME}-#{Locatine::VERSION}/"\
                                              "lib/#{Locatine::NAME}"
         end
end
