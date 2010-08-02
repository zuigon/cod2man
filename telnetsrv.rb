#!/usr/bin/env ruby
require 'gserver'
require 'rubygems'

@users = [
  ['bkrsta', 'test'],
  ['test', 'test'],
]

def logfile() "./telnetsrv.log" end

def parse_input(i)
  if i=='exit' or i=='quit' or i=='q'
    # $stdio.puts "bye! (parse_input)"
    return false
  else
    return i
  end
end

def runfun(inp)
  case (inp || '')
  when 'help', 'h', '?'
    $stdio.puts @usage
  when 'status'
    $stdio.puts "PRINT STATUS"
  when 'start'
    $stdio.puts "Start Server !"
  when 'stop'
    $stdio.puts "Stop Server !"
  when 'restart'
    $stdio.puts "Restart Server !"
  when ''
  else
    $stdio.puts "Nepoznata komanda: #{inp}"
  end
end

def passw(io)
  io.flush
  x=''; while x+=io.getc
    io.print "\b"
  end
  x
end

def log_file(msg)
  (log "Greska kod log_file() !"; return false) if msg.nil? or msg.empty?
  log "[LOGFILE] #{msg}"
  File.open(logfile, (File.exists? logfile) ? 'a' : 'w') { |f| f.puts "[#{Time.now}] #{msg}\n" }
end

class Users
  def initialize(db)
    @users = db
  end
  def check(user, pass)
    @users.each do |u|
      if u[0]==user; if u[1]==pass; return true end end
    end
    false
  end
  def log(usr) @in = usr end
  def who() @in || (puts "prazan @in!"; exit) end
end

class MyServer < GServer
  # TODO: koristiti Highline, link: http://bit.ly/9cMIIi
  # TODO: use http://bit.ly/aTRaA3
  def init(db)
    @usage ||= []
    # TODO: ispisi last login u headeru
    @usage << "### cod2man shell ###"
    @usage << " - Za pomoc oko komandi upisi: 'h' ili 'help' ili '?'"
    # @usage << "Last login: Mon Aug  2 18:01:45"
    @usr = Users.new(db)
  end
  def serve(io)
    loop do
      begin
        log_file "connected: #{io.peeraddr[3]}"
        $stdio = io
        io.puts "Welcome to cod2man telnet server ... !"
        failcnt=0
        loop do # Login screen
          io.puts '-- Please Login'
          io.print 'username: '; username = io.gets.chomp
          io.print 'password: '; password = io.gets.chomp
          if @usr.check(username, password)
            @usr.log username
            io.puts
            io.puts "Successfully logged in as #{@usr.who}!"
            log_file "#{@usr.who} logged in"
            io.puts
            break
          else
            io.puts "Wrong username or password!"
            io.puts
            failcnt+=1
            if failcnt>2
              log_file "User Failed to login #{failcnt} times, killing!"
              io.puts " !! Login failed #{failcnt} times and will be reported to admin !!"
              io.close
            end
          end
        end
        io.puts @usage.join "\n"
        loop do # command prompt
          io.print "cod2man shell $ "
          line_input = parse_input io.gets.chop
          if line_input==false
            log_file "Exit"
            io.puts "bye!"
            io.close
          end
          log_file "Received #{line_input}" if line_input[/./]
          runfun line_input
        end
      rescue Exception => e
        io.puts "Oops - #{e}"
      end
    end
    io.puts ">> GOODBYE <<"
    log_file "Exit"
    io.close
  rescue Exception => e
    puts "#{e}"
  end
end

ts = MyServer.new 1234
ts.init @users
# ts.init_usr()
ts.start
ts.audit = true
ts.join
