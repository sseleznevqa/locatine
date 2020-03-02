# frozen_string_literal: true

module Locatine
  # constants here...
  VERSION = '0.02653'
  NAME = 'locatine'
  HOME = if File.readable?("#{Dir.pwd}/lib/#{Locatine::NAME}")
           "#{Dir.pwd}/lib/#{Locatine::NAME}"
         else
           "#{Gem.dir}/gems/#{Locatine::NAME}-#{Locatine::VERSION}/"\
                                              "lib/#{Locatine::NAME}"
         end
end
