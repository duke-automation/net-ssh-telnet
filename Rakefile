# -*- ruby -*-

require 'rubygems'
require 'hoe'
$:.unshift(File.dirname(__FILE__) + "/lib")
require 'net/ssh/telnet'

Hoe.new('net-ssh-telnet', Net::SSH::Telnet::VERSION) do |p|
  p.developer('Matthew Kent', 'matt@bravenet.com')
  p.extra_deps << ['net-ssh', '>= 2.0.1']
  p.remote_rdoc_dir = ''
end

# vim: syntax=Ruby
