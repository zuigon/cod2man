require 'gserver'
require 'rubygems'

EOF = -1

# def get()
#   c = $stdin.getc
#   return EOF if(!c)
#   c = c.chr
#   return c if (c >= " " || c == "\n" || c.unpack("c") == EOF)
#   return "\n" if (c == "\r")
#   return " "
# end
# 
# def getline()
#   get = ""
#   while input += get()
#   end
#   return get
# end

def line()
  o=""
  while o += $stdin.getc
  end
  o
end

def parse_input(i)
  if i=='exit' or i=='quit' or i=='q'
    $stdout.puts "bye! (parse_input)"
    return false
  else
    return i
  end
end

def runfun(input)
  case input[//]
  when 'status'
    $stdout.puts "PRINT STATUS"
  when 'start'
  when 'stop'
  when 'restart'
  when ''
  else
    puts " ?? "
  end
end

class MyServer < GServer
  # TODO: koristiti Highline, link: http://bit.ly/9cMIIi
  # TODO: use http://bit.ly/aTRaA3
  def init()
    @usage||=[]
    # TODO: u header last login
    @usage << "======== cod2man shell ========"
    @usage << " Za pomoc oko komandi upisi: 'h' ili 'help'"
    @usage << ""
  end
  def serve(i)
    $stdin = i
    $stdout = i
    i.print "Hello world !"
    i.puts ':: Login ::'
    i.print 'username: '
    username = gets.chomp
    i.puts "! Username: #{username}"
    i.puts @usage.join "\n"
    e=false
    while !e
      i.print "cod2man shell $ "
      input = parse_input i.gets.chop
      if input==false
        e=true
      end
      i.puts "Input: #{input}"
      runfun input
    end
    i.puts "bye!"
  end
end


s = MyServer.new 1234
s.init
s.start
s.join
