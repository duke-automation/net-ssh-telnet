#!/usr/bin/ruby

$: << File.dirname(__FILE__) + "/../lib"

require 'net/ssh/telnet'

# Example showing a simple interaction, with debugging data to stdout.

s = Net::SSH::Telnet.new(
        "Dump_log" => "/dev/stdout",
        "Host" => "127.0.0.1",
        "Username" => "demo",
        "Password" => "guy"
)
puts "Logged in"
puts s.cmd("hostname")

s.close
