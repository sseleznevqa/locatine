#!Locatine-daemon...
# frozen_string_literal: true

require 'locatine'
args = Hash[ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/)]
args = args.each_with_object({}) { |(k, v), memo| memo[k.to_sym] = v; }
args.each_pair do |key, value|
  Locatine::Daemon.set key, value
end
Locatine::Daemon.run!
