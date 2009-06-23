require 'net/ssh'
 
module Net
module SSH

  # == Net::SSH::Telnet
  #
  # Provides a simple send/expect interface with an API almost
  # identical to Net::Telnet. Please see Net::Telnet for main documentation.
  # Only the differences are documented here.
  
  class Telnet

    CR   = "\015"
    LF   = "\012"
    EOL  = CR + LF
    VERSION = '0.0.2'

    # Wrapper to emulate the behaviour of Net::Telnet "Proxy" option, where
    # the user passes in an already-open socket

    class TinyFactory
      def initialize(sock)
        @sock = sock
      end
      def open(host, port)
        s = @sock
        @sock = nil
        s
      end
    end

    # Creates a new Net::SSH::Telnet object.
    #
    # The API is similar to Net::Telnet, although you will need to pass in
    # either an existing Net::SSH::Session object or a Username and Password,
    # as shown below.
    #
    # Note that unlike Net::Telnet there is no preprocess method automatically
    # setting up options related to proper character translations, so if your 
    # remote ptty is configured differently than the typical linux one you may 
    # need to pass in a different terminator or call 'stty' remotely to set it 
    # into an expected mode. This is better explained by the author of perl's 
    # Net::SSH::Expect here:
    #
    # http://search.cpan.org/~bnegrao/Net-SSH-Expect-1.04/lib/Net/SSH/Expect.pod
    # #IMPORTANT_NOTES_ABOUT_DEALING_WITH_SSH_AND_PSEUDO-TERMINALS
    #
    # though for most installs the default LF should be fine. See example 5
    # below.
    #
    # A new option is added to correct a misfeature of Net::Telnet. If you
    # pass "FailEOF" => true, then if the remote end disconnects while you
    # are still waiting for your match pattern then an EOFError is raised.
    # Otherwise, it reverts to the same behaviour as Net::Telnet, which is
    # just to return whatever data was sent so far, or nil if no data was
    # returned so far. (This is a poor design because you can't tell whether
    # the expected pattern was successfully matched or the remote end
    # disconnected unexpectedly, unless you perform a second match on the
    # return string). See
    # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/11373
    # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/11380
    #
    # Example 1 - pass existing Net::SSH::Session object
    #
    #   ssh = Net::SSH.start("127.0.0.1",
    #         :username=>"test123",
    #         :password=>"pass456"
    #   )
    #   s = Net::SSH::Telnet.new(
    #         "Dump_log" => "/dev/stdout",
    #         "Session" => ssh
    #   )
    #   puts "Logged in"
    #   p s.cmd("echo hello")
    #
    # This is the most flexible way as it allows you to set up the SSH
    # session using whatever authentication system you like. When done this
    # way, calling Net::SSH::Telnet.new multiple times will create
    # multiple channels, and #close will only close one channel.
    #
    # In all later examples, calling #close will close the entire
    # Net::SSH::Session object (and therefore drop the TCP connection)
    #
    # Example 2 - pass host, username and password
    #
    #   s = Net::SSH::Telnet.new(
    #           "Dump_log" => "/dev/stdout",
    #           "Host" => "127.0.0.1",
    #           "Username" => "test123",
    #           "Password" => "pass456"
    #   )
    #   puts "Logged in"
    #   puts s.cmd("echo hello")
    #
    # Example 3 - pass open IO object, username and password (this is really
    # just for compatibility with Net::Telnet Proxy feature)
    #
    #   require 'socket'
    #   sock = TCPSocket.open("127.0.0.1",22)
    #   s = Net::SSH::Telnet.new(
    #           "Dump_log" => "/dev/stdout",
    #           "Proxy" => sock,
    #           "Username" => "test123",
    #           "Password" => "pass456"
    #   )
    #   puts "Logged in"
    #   puts s.cmd("echo hello")
    #
    # Example 4 - pass a connection factory, host, username and password;
    # Net::SSH will call #open(host,port) on this object. Included just
    # because it was easy :-)
    #
    #   require 'socket'
    #   s = Net::SSH::Telnet.new(
    #           "Dump_log" => "/dev/stdout",
    #           "Factory" => TCPSocket,
    #           "Host" => "127.0.0.1",
    #           "Username" => "test123",
    #           "Password" => "pass456"
    #   )
    #   puts "Logged in"
    #   puts s.cmd("echo hello")
    #
    # Example 5 - connection to a SAN device running a customized NetBSD with
    # different ptty defaults, it doesn't convert LF -> CR+LF (see the man
    # page for 'stty') and uses a custom prompt
    #
    #   s = Net::SSH::Telnet.new(
    #           "Host" => "192.168.1.1",
    #           "Username" => "test123",
    #           "Password" => "pass456",
    #           "Prompt" => %r{^\S+>\s.*$},
    #           "Terminator" => "\r"
    #   )
    #   puts "Logged in"
    #   puts s.cmd("show alerts")
    
    # New objects take a +option+ hash to set default settings. The keys for this options hash
    # are all strings. A block can also be passed to constructor which will get executed after 
    # the first prompt is found.
    # 
    # ==== Hash Parameters
    # 
    # * <tt>"Host"</tt> - a string to define the hostname to connect to(Default: "localhost")
    # * <tt>"Port"</tt> - port number to connect to(Default: 22)
    # * <tt>"Prompt"</tt> - a regular expression to define the the prompt to expect(Default: /[$%#>] \z/n )
    # * <tt>"Timeout"</tt> - the time out value passed on to Net::Ssh(Default: 10)
    # * <tt>"Waittime"</tt> - Max time to wait for a prompt. 0 means forever.(Default: 0)
    # * <tt>"Terminator"</tt> - This value is appended to all strings that are sent to #print.(Default: LF) 
    # * <tt>"Binmode"</tt> - Enable binary mode.(Default: false)
    # * <tt>"Output_log"</tt> - A file name to open as an output log.
    # * <tt>"Dump_log"</tt> - A file name to open to dump the entire session to.
    # * <tt>"Session"</tt> - An existing Net::Ssh object for Net::Ssh::Telnet to use as its connection(See example 1)
    # * <tt>"Proxy"</tt> - An open IO object to use as a Proxy(See example 3)
    # * <tt>"Factory"</tt> - A connection factory to use to establish the connection. Net::Ssh::Telnet will call #open(host, post) on this object.(See example 4)
    #
    def initialize(options, &blk) # :yield: mesg
      @options = options
      @options["Host"]       = "localhost"   unless @options.has_key?("Host")
      @options["Port"]       = 22            unless @options.has_key?("Port")
      @options["Prompt"]     = /[$%#>] \z/n  unless @options.has_key?("Prompt")
      @options["Timeout"]    = 10            unless @options.has_key?("Timeout")
      @options["Waittime"]   = 0             unless @options.has_key?("Waittime")
      @options["Terminator"] = LF            unless @options.has_key?("Terminator")

      unless @options.has_key?("Binmode")
        @options["Binmode"]    = false
      else
        unless (true == @options["Binmode"] or false == @options["Binmode"])
          raise ArgumentError, "Binmode option must be true or false"
        end
      end

      if @options.has_key?("Output_log")
        @log = File.open(@options["Output_log"], 'a+')
        @log.sync = true
        @log.binmode
      end

      if @options.has_key?("Dump_log")
        @dumplog = File.open(@options["Dump_log"], 'a+')
        @dumplog.sync = true
        @dumplog.binmode
        def @dumplog.log_dump(dir, x)  # :nodoc:
          len = x.length
          addr = 0
          offset = 0
          while 0 < len
            if len < 16
              line = x[offset, len]
            else
              line = x[offset, 16]
            end
            hexvals = line.unpack('H*')[0]
            hexvals += ' ' * (32 - hexvals.length)
            hexvals = format("%s %s %s %s  " * 4, *hexvals.unpack('a2' * 16))
            line = line.gsub(/[\000-\037\177-\377]/n, '.')
            printf "%s 0x%5.5x: %s%s\n", dir, addr, hexvals, line
            addr += 16
            offset += 16
            len -= 16
          end
          print "\n"
        end
      end

      if @options.has_key?("Session")
        @ssh = @options["Session"]
        @close_all = false
      elsif @options.has_key?("Proxy")
        @ssh = Net::SSH.start(nil, nil,
                :host_name => @options["Host"],  # ignored
                :port => @options["Port"],       # ignored
                :user => @options["Username"],
                :password => @options["Password"],
                :timeout => @options["Timeout"],
                :proxy => TinyFactory.new(@options["Proxy"])
        )
        @close_all = true
      else
        message = "Trying " + @options["Host"] + "...\n"
        yield(message) if block_given?
        @log.write(message) if @options.has_key?("Output_log")
        @dumplog.log_dump('#', message) if @options.has_key?("Dump_log")

        begin
          @ssh = Net::SSH.start(nil, nil,
                :host_name => @options["Host"],
                :port => @options["Port"],
                :user => @options["Username"],
                :password => @options["Password"],
                :timeout => @options["Timeout"],
                :proxy => @options["Factory"]
          )
          @close_all = true
        rescue TimeoutError
          raise TimeoutError, "timed out while opening a connection to the host"
        rescue
          @log.write($ERROR_INFO.to_s + "\n") if @options.has_key?("Output_log")
          @dumplog.log_dump('#', $ERROR_INFO.to_s + "\n") if @options.has_key?("Dump_log")
          raise
        end

        message = "Connected to " + @options["Host"] + ".\n"
        yield(message) if block_given?
        @log.write(message) if @options.has_key?("Output_log")
        @dumplog.log_dump('#', message) if @options.has_key?("Dump_log")
      end

      @buf = ""
      @eof = false
      @channel = nil
      @ssh.open_channel do |channel|
        channel.request_pty { |ch,success|
          if success == false
            raise "Failed to open ssh pty"
          end
        }
        channel.send_channel_request("shell") { |ch, success|
          if success
            @channel = ch
            waitfor(@options['Prompt'], &blk)
            return
          else
            raise "Failed to open ssh shell"
          end
        }
        channel.on_data { |ch,data| @buf << data }
        channel.on_extended_data { |ch,type,data| @buf << data if type == 1 }
        channel.on_close { @eof = true }
      end
      @ssh.loop
    end # initialize

    # Close the ssh channel, and also the entire ssh session if we
    # opened it.
    def close
      @channel.close if @channel
      @channel = nil
      @ssh.close if @close_all and @ssh
    end
        
    # The ssh session and channel we are using.
    attr_reader :ssh, :channel

    # Turn newline conversion on (+mode+ == false) or off (+mode+ == true),
    # or return the current value (+mode+ is not specified).
    def binmode(mode = nil)
      case mode
      when nil
        @options["Binmode"]
      when true, false
        @options["Binmode"] = mode
      else
        raise ArgumentError, "argument must be true or false"
      end
    end

    # Turn newline conversion on (false) or off (true).
    def binmode=(mode)
      if (true == mode or false == mode)
        @options["Binmode"] = mode
      else
        raise ArgumentError, "argument must be true or false"
      end
    end

    # Read data from the host until a certain sequence is matched.
    #
    # The +options+ parameter takes an string keyed option Hash or a String.
    #
    # A block can be provided to be called after the first prompt or match is found.
    #
    # ==== Hash Parameters
    #
    # * <tt>"Match"</tt> - Regular expression to match
    # * <tt>"Prompt"</tt> - Regular expression to match (Same as "Match")
    # * <tt>"String"</tt> - String to match
    # * <tt>"Timeout"</tt> - 
    # * <tt>"Waittime"</tt> - Max time to wait for the match(Default: 0)
    # * <tt>"FailEOF"</tt> - Raise EOFError if EOF is reached on the connection.(Default: false)
    #
    def waitfor(options) # :yield: recvdata
      time_out = @options["Timeout"]
      waittime = @options["Waittime"]
      fail_eof = @options["FailEOF"]

      if options.kind_of?(Hash)
        prompt   = if options.has_key?("Match")
                     options["Match"]
                   elsif options.has_key?("Prompt")
                     options["Prompt"]
                   elsif options.has_key?("String")
                     Regexp.new( Regexp.quote(options["String"]) )
                   end
        time_out = options["Timeout"]  if options.has_key?("Timeout")
        waittime = options["Waittime"] if options.has_key?("Waittime")
        fail_eof = options["FailEOF"]  if options.has_key?("FailEOF")
      else
        prompt = options
      end

      if time_out == false
        time_out = nil
      end

      line = ''
      buf = ''
      rest = ''
      sock = @ssh.transport.socket

      until prompt === line and @buf == "" and (@eof or (not sock.closed? and not IO::select([sock], nil, nil, waittime)))
        while @buf == "" and !@eof
          # timeout is covered by net-ssh
          begin
            @channel.connection.process(0.1)
          rescue IOError
            @eof = true
          end
        end
        if @buf != ""
          c = @buf; @buf = ""
          @dumplog.log_dump('<', c) if @options.has_key?("Dump_log")
          buf = rest + c
          rest = ''
          unless @options["Binmode"]
            if pt = buf.rindex(/\r\z/no)
              buf = buf[0 ... pt]
              rest = buf[pt .. -1]
            end
            buf.gsub!(/#{EOL}/no, "\n")
          end
          @log.print(buf) if @options.has_key?("Output_log")
          line += buf
          yield buf if block_given?
        elsif @eof # End of file reached
          break if prompt === line
          raise EOFError if fail_eof
          if line == ''
            line = nil
            yield nil if block_given?
          end
          break
        end
      end
      line
    end

    # Write +string+ to the host.
    #
    # Does not perform any conversions on +string+.  Will log +string+ to the
    # dumplog, if the Dump_log option is set.
    def write(string)
      @dumplog.log_dump('>', string) if @options.has_key?("Dump_log")
      @channel.send_data string
    end

    # Sends +string+ to the host.
    #
    # This does _not_ automatically append a newline to the string.  Embedded
    # newlines may be converted depending upon the values of binmode or
    # terminator.
    def print(string)
      terminator = @options["Terminator"]

      if @options["Binmode"]
        self.write(string)
      else
        self.write(string.gsub(/\n/n, terminator))
      end
    end

    # Sends +string+ to the host.
    #
    # Same as #print(), but appends a newline to the string.
    def puts(string)
      self.print(string + "\n")
    end

    # Sends a command to the host.
    #
    # More exactly, sends a string to the host, and reads in all received
    # data until is sees the prompt or other matched sequence.
    #
    # The command or other string will have the newline sequence appended
    # to it.
    #
    # The +options+ parameter takes a String or Hash. The Hash can be used to override the 
    # default settings that were established when the object was created.
    #
    # A block can be provided to be called when the first prompt or "Match" is found.
    #
    # ==== Hash Parameters
    #
    # * <tt>"String"</tt> - This string is sent over the connection via the #puts method.
    # * <tt>"Match"</tt> - Passed to #waitfor as the "Prompt" parameter. See its defintion for details.
    # * <tt>"Timeout"</tt> - Passed to #waitfor see its definition for details
    # * <tt>"FailEOF"</tt> - Passed to #waitfor see its definition for details
    #
    def cmd(options) # :yield: recvdata
      match    = @options["Prompt"]
      time_out = @options["Timeout"]
      fail_eof = @options["FailEOF"]

      if options.kind_of?(Hash)
        string   = options["String"]
        match    = options["Match"]   if options.has_key?("Match")
        time_out = options["Timeout"] if options.has_key?("Timeout")
        fail_eof = options["FailEOF"] if options.has_key?("FailEOF")
      else
        string = options
      end

      self.puts(string)
      if block_given?
        waitfor({"Prompt" => match, "Timeout" => time_out, "FailEOF" => fail_eof}){|c| yield c }
      else
        waitfor({"Prompt" => match, "Timeout" => time_out, "FailEOF" => fail_eof})
      end
    end

  end  # class Telnet
end  # module SSH
end  # module Net
