#!/usr/bin/ruby
# create.rb
# Za instaliranje novog CoD2 servera iz template-a
#   i osnovno konfiguriranje
# ! Mora ici u hosting/ folder sa template/ folderom

require 'optparse'
require 'erb'

options = {}
name = nil
template_dir = nil

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: create.rb [options]"

  options[:verbose] = false
  options[:run_as] = nil
  options[:name] = nil
  options[:owner] = nil
  options[:force] = false

  opts.on( '-v', '--verbose', 'Output more information' ) do options[:verbose] = true end
  opts.on( '-n', '--ime IME', 'Ime foldera za inst. (shortname)' ) do |s| options[:name] = s end
  opts.on( '-o', '--owner USERNAME', 'Owner username' ) do |s| options[:owner] = s end
  opts.on( '-t', '--template DIR', '' ) do |dir| options[:template_dir] = dir end
  opts.on( '-f', '--force', 'Force creation if server already exists' ) do options[:force] = true end
  # opts.on( '-u', '--runas USER', '' ) do |user| options[:run_as] = user end
  # TODO: vars.txt opcije citati kroz options[]; umjesto addvar, ovdje
  opts.on( '-h', '--help', 'Display this' ) do puts opts; exit end
end
optparse.parse!

@opts = options

name = options[:name]
template_dir = options[:template_dir]

cfg_template = <<EOF
sets _ADMIN "<%= admin_name %>"
sets _EMAIL "<%= admin_email %>"
sets _IRC ""
sets _WEBSITE ""
sets _LOCATION ""
set sv_hostname "<%= server_name %>"
set net_ip "0.0.0.0"
set net_port "<%= server_port %>"
rcon_password "<%= server_rcon %>"
set dedicated "2"
set sv_pure "1"
set sv_maxplayers "<%= server_maxpl %>"
sv_maprotation "gametype dm map mp_carentan gametype dm map mp_toujane gametype tdm map mp_brecourt gametype tdm map mp_matmata"
map_rotate
set sv_minping "0"
set sv_maxping "0"
set sv_maxrate "0"
set sv_voice "0"
set g_password ""
set sv_drawfriend "0"
set scr_friendlyfire "2"
set scr_forcerespawn "1"
set scr_killcam "0"
set g_allowvote "1"
set scr_teambalance "1"
set scr_spectateenemy "0"
set scr_spectatefree "0"
set scr_allow_bar "1"
set scr_allow_bren "1"
set scr_allow_enfield "1"
set scr_allow_enfieldsniper "1"
set scr_allow_g43 "1"
set scr_allow_greasegun "1"
set scr_allow_kar98k "1"
set scr_allow_kar98ksniper "1"
set scr_allow_m1carbine "1"
set scr_allow_m1garand "1"
set scr_allow_mp40 "1"
set scr_allow_mp44 "1"
set scr_allow_nagant "1"
set scr_allow_nagantsniper "1"
set scr_allow_pps42 "1"
set scr_allow_ppsh "1"
set scr_allow_shotgun "1"
set scr_allow_springfield "1"
set scr_allow_sten "1"
set scr_allow_svt40 "1"
set scr_allow_thompson "1"
set scr_allow_fraggrenades "1"
set scr_allow_smokegrenades "1"
set scr_ctf_scorelimit "5"
set scr_ctf_timelimit "30"
set scr_dm_scorelimit "50"
set scr_dm_timelimit "30"
set scr_sd_bombtimer "60"
set scr_sd_graceperiod "15"
set scr_sd_roundlength "4"
set scr_sd_roundlimit "0"
set scr_sd_scorelimit "50"
set scr_sd_timelimit "30"
set scr_tdm_scorelimit "100"
set scr_tdm_timelimit "30"
set scr_hq_scorelimit "450"
set scr_hq_timelimit "30"
set sv_mapRotationCurrent ""
EOF

def verbose?
  @opts[:verbose]
end

def info(msg) puts "INFO: #{msg}" end
def warn(msg) puts "WARN: #{msg}" end
def err(msg)  puts "ERR: #{msg}"; exit end

# (puts "Ime nije navedeno!"; exit) if ARGV[0].nil? or ARGV[0].empty?
(puts "Ime nije navedeno!"; exit) if name.nil? or name.empty?
# name = ARGV[0]
dir = `pwd | sed 's/.*\\///g'`.chop

err "Ime sadrzi nedopustene znakove!" if name =~ /[^a-z0-9]/ or name =~ /[\.\/\\]/

err "Trenutni dir nije hosting dir!" if !File.exist? "./.cod2hosting"
# warn "vars.txt datoteka vec postoji i bit ce obrisana!" if File.exists? "./#{name}/vars.txt"
if File.directory? "#{options[:owner]}-#{name}" and !options[:force]
  err "server/folder imena #{options[:owner]}-'#{name}' vec postoji!"
end
err "Ime je prekratko!" if name.length < 3
err "Ime je predugo!" if name.length > 10
err "Nema template-a!" unless File.directory? 'template' or File.exists? 'template.tgz'
(template_dir = true if File.directory? 'template') if template_dir.nil?

if template_dir
  info "creating new server (#{options[:owner]}-#{name}) from template ..."
  cmd = "cp -r template/ #{options[:owner]}-#{name}"
  if system cmd
    if File.directory? "#{options[:owner]}-#{name}"
      info "Gotovo!"
    else err "nema foldera #{options[:owner]}-#{name}!" end
  else
    err "greska kod izvrsavanja '#{cmd}'"
  end
else
  err "template_dir empty!"
  #err "IMPLEM tgz extract"
end

# %w(RUNUSER ADMIN_NAME ADMIN_EMAIL SERVER_NAME SERVER_PORT SERVER_RCON).each {|var| var[var.downcase] = ENV[var] }

# TODO: napraviti modul/klasu za konfiguriranje koju koristi i create i config
# TODO: config.rb [ime], input ide kroz STDIO
# TODO: add config.rb [ime] change [var] [content] - varijabla mora vec postojati
# TODO: dodati arg i func za regeneriranje dedicated.cfg-a

if verbose?
  puts
  puts "----------------"
  puts " Konfiguriranje "
  puts "----------------"
end

@vars = []
def addvar(name, msg, default=nil) @vars << [name, msg, default, nil] end
def genvars()
  @varsfile.puts "# GENERIRANO sa create.rb"
  for var in @vars do @varsfile.puts "#{var[0].upcase}='#{var[3] || var[2]}'" end
  @varsfile.puts
end
def getvar(ime)
  @vars.each { |var| return var[3] if var[0] == ime }
  return false
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
        err "??"
      end
    end
  end
end

# %w(RUNUSER ADMIN_NAME ADMIN_EMAIL SERVER_NAME SERVER_PORT SERVER_RCON)
addvar "runuser", "Run as user", "bkrsta"
addvar "admin_name", "Server admin name"
addvar "admin_email", "Admin eMail"
addvar "server_name", "Server name"
addvar "server_port", "Server port"
randbroj = 10000+rand(99999-10000)
addvar "server_rcon", "RCON password", "#{options[:owner]}-#{name}#{randbroj}"
addvar "server_maxpl", "Max players", "20"

# TODO: server ports pool; klase Pool, Rules
# TODO: ne dozvoljavaj kreiranje s zauzetim portom
# TODO: port fwd-ing rules > file
# TODO: u config datoteku trebaju ici i neki visi podatci, npr. Dozvoli prijavu Webom, Telnetom, ...

unosvars()
@varsfile = File.open "#{options[:owner]}-#{name}/vars.txt", 'w'
genvars()
@varsfile.close
info "vars.txt je generiran" if verbose?

template = ERB.new cfg_template
cfg = template.result(
  lambda do
    admin_name  = getvar("admin_name")
    admin_email = getvar("admin_email")
    server_name = getvar("server_name")
    server_port = getvar("server_port")
    server_rcon = getvar("server_rcon")
    server_maxpl  = getvar("server_maxpl")
  lambda { }
  end.call
)

info "Generiram dedicated.cfg"
File.open("#{options[:owner]}-#{name}/main/dedicated.cfg", 'w+') do |f|
  f.puts cfg
end

# potvrda autenticnosti servera
File.open("#{options[:owner]}-#{name}/.cod2server", 'a').close

puts ":: Server je konfiguriran! ::"
puts " - moze se pokrenuti sa `control start`"
puts "..."
