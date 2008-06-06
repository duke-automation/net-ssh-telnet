#!/usr/bin/ruby

$: << File.dirname(__FILE__) + "/../lib"

require 'net/ssh/telnet'

# Example showing debugging possibilities

# Dump the ssh interaction to stdout..
ssh = Net::SSH.start(nil, nil,
                     :host_name => "127.0.0.1",
                     :user => "demo",
                     :password => "guy",
                     :verbose => :debug
                     )

# ..and output our 2 Net::Telnet style interaction logs.
s = Net::SSH::Telnet.new(
       "Session"  => ssh,
       "Dump_log" => "dump.log",
       "Output_log" => "output.log"
)

puts s.cmd("echo democommand1")
puts s.cmd("echo democommand2")
puts s.cmd("echo democommand3")

s.close
