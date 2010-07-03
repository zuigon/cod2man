# create.rb
# Za instaliranje novog CoD2 servera iz template-a
#   i osnovno konfiguriranje
# ! Mora ici u hosting/ folder sa template/ folderom

(puts "Ime nije navedeno!"; exit) if ARGV[0].nil? or ARGV[0].empty?
name = ARGV[0]
dir = `pwd | sed 's/.*\\///g'`.chop

(puts "ERR: Ime sadrzi nedopustene znakove!"; exit) if name =~ /[^a-z0-9]/ or name =~ /[\.\/\\]/

puts "WARN: vars.txt datoteka vec postoji i bit ce obrisana!" if File.exists? "./#{name}/vars.txt"
(puts "ERR: server/folder tog imena vec postoji!"; exit) if File.directory? name

(puts "ERR: Ime je prekratko!"; exit) if name.length < 3
(puts "ERR: Ime je predugo!"; exit) if name.length > 10
(puts "ERR: Nema template-a!"; exit) unless File.directory? 'template' or File.exists? 'template.tgz'
template_dir = true if File.directory? 'template'

if template_dir
  puts "INFO: creating new server (#{name}) from template ..."
  cmd = "cp -r template/ #{name}"
  if system cmd
    if File.directory? name
      puts "INFO: gotovo!"
    else
      puts "ERR: nema foldera #{name}!"
      exit
    end
  else
    puts "ERR: greska kod izvrsavanja '#{cmd}'"
  end
else
  puts "ERR: IMPLEM tgz extract"
  exit
end

# %w(RUNUSER ADMIN_NAME ADMIN_EMAIL SERVER_NAME SERVER_PORT SERVER_RCON).each {|var| var[var.downcase] = ENV[var] }

# TODO: napraviti modul/klasu za konfiguriranje koju koristi i create i config
# TODO: config.rb [ime], input ide kroz STDIO
# TODO: add config.rb [ime] change [var] [content] - varijabla mora vec postojati

puts
puts "----------------"
puts " Konfiguriranje "
puts "----------------"

@vars = []
def addvar(name, msg, default=nil) @vars << [name, msg, default, nil] end
def genvars()
  @varsfile.puts "# GENERIRANO sa create.rb"
  for var in @vars do @varsfile.puts "#{var[0].upcase}='#{var[3] || var[2]}'" end
  @varsfile.puts
end
# TODO: dodati regex mogucnost, za eMail, korisnika, ime
# TODO: dodati minimalni length
def unosvars()
  for var in @vars do
    must = var[2].nil? or var[2].empty?; uneseno = false
    gresaka = 10
    while !uneseno
      print "#{var[1]} #{(!must)? "["+var[2]+"]" : "[!]"}: "
      STDOUT.flush
      unos = STDIN.gets.chomp
      if !unos.empty?; var[3] = unos elsif !must; var[3] = var[2] end
      if unos.nil? or unos.empty?; if !must; var[3] = unos; uneseno = true end
      else var[3] = unos; uneseno = true end
      if gresaka
        gresaka-=1
      else
        puts "ERR: ??"
        exit
      end
    end
  end
end

# %w(RUNUSER ADMIN_NAME ADMIN_EMAIL SERVER_NAME SERVER_PORT SERVER_RCON)
addvar "runuser", "Run as user", "bkrsta"
addvar "admin_name", "Server admin name"
addvar "admin_email", "Admin eMail"
addvar "server_name", "Server name"
# TODO: server ports pool; klase Pool, Rules
# TODO: ne dozvoljavaj kreiranje s zauzetim portom
# TODO: port fwd-ing rules > file
addvar "server_port", "Server port"
randbroj = 1000+rand(9999-1000)
addvar "server_rcon", "RCON password", "#{name}#{randbroj}"

# TODO: u config datoteku trebaju ici i neki visi podatci, npr. Dozvoli prijavu Webom, Telnetom, ...

unosvars()

@varsfile = File.open "#{name}/vars.txt", 'w'
genvars()

puts ":: Server je konfiguriran! ::"
puts " - moze se pokrenuti komandom `control start`"
puts "..."
