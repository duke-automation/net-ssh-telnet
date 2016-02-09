# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'net/ssh/telnet'

Gem::Specification.new do |spec|
  spec.name          = "net-ssh-telnet2"
  spec.version       = Net::SSH::Telnet::VERSION
  spec.authors       = ["Sean Dilda"]
  spec.email         = ["sean@duke.edu"]
  spec.description   = %q{A ruby module to provide a simple send/expect interface over SSH with an API almost identical to Net::Telnet. Ideally it should be a drop in replacement. Please see Net::Telnet for main documentation (included with ruby stdlib).}
  spec.summary       = %q{Provides Net::Telnet API for SSH connections}
  spec.homepage      = "https://github.com/duke-automation/net-ssh-telnet2"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ["lib"]
  spec.extra_rdoc_files = ['README.txt', 'History.txt']

  spec.add_runtime_dependency 'net-ssh', '>= 2.0.1'
  spec.add_development_dependency 'rake'
end
