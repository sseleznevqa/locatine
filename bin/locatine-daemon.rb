#!Locatine-daemon...
require 'locatine'
args = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]
args = args.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
args.each_pair do |key, value|
  Locatine::Daemon.set key, value
end
Locatine::Daemon.run!
