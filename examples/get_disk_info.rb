#!/usr/bin/ruby

$: << File.dirname(__FILE__) + "/../lib"

require 'net/ssh/telnet'

# Example using Waittime.

puts "Using Waittime"
s = Net::SSH::Telnet.new(
        "Host" => "127.0.0.1",
        "Username" => "demo",
        "Password" => "guy",
        # Seconds to wait for more data after seeing the prompt
        "Waittime" => 3 
)
puts "Logged in"
puts s.cmd("head -1 /proc/mounts\r\ndf\r\recho done")
s.close

puts "\nAgain, but with no wait time"
s = Net::SSH::Telnet.new(
        "Host" => "127.0.0.1",
        "Username" => "demo",
        "Password" => "guy"
)
puts "Logged in"
puts s.cmd("head -1 /proc/mounts\r\ndf\r\recho done")
s.close
