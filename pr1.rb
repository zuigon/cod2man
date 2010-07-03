exename="cod2_exe"
dir="arstarst"

#@fpath=dir+'/'+exename
@fpath=exename
dir = dir.chop if dir.end_with? '/'

def extip
  `curl http://checkip.dyndns.com/ 2>&1 | grep Current | sed 's/^$//g' | sed 's/^.*Address: //g' | sed 's/<.*>//g' | egrep "[[:digit:]]"`.chop
end

def pid
  `ps aux | grep #{@fpath} | grep -v grep | awk '{print $2}'`.chop
end

def status
  return !!pid
end


def start
#  `cd #{dir} && ./#{exename}`
end


#def reboot
#end


puts dir

puts status
puts pid
