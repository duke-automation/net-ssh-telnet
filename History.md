### 0.2.0 / 2017-01-16
* Add option to change prompt after initialization
* Cleanup requires for gemspec

### 0.1.1 / 2016-05-06
* Apply fix to race condition during initialization from lumean

### 0.1.0 / 2016-02-09
* Fixed 'Timeout' and 'Waittime' options
* Fork to net-ssh-telnet2

### 0.0.2 / 2009-03-15

* 4 bugfixes from Brian Candler
  * Bug in original Net::Telnet EOL translation
    (http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/16599)
    duplicate the fix.
  * Remove rubygems require.
  * Handle EOF more gracefully.
  * Allow FailEOF to propagate through cmd() to waitfor().

### 0.0.1 / 2008-06-06

* 1 major enhancement
  * Birthday!
  * Initial revision by Brian Candler based on Net::Telnet.
  * Test release.
