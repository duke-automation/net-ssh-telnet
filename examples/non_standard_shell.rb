#!/usr/bin/ruby

$: << File.dirname(__FILE__) + "/../lib"

require 'net/ssh/telnet'

# Example showing interaction with a device that provides a custom shell via
# ssh.

s = Net::SSH::Telnet.new(
        "Host" => "192.168.1.1",
        "Username" => "demo",
        "Password" => "guy",
        "Prompt" => %r{^\S+>\s.*$},
        "Terminator" => "\r"
)

puts s.cmd("show alerts")

s.close
