<?php

$I = getServerInfo('192.168.1.x:2896x');  
echo "\n";
echo "Server type: ".$I['gamename']; echo "\n";
echo "Game type:   ".strtoupper($I['g_gametype']); echo "\n";
echo "Hostname:    ".$I['sv_hostname']; echo "\n";
echo "Players:     ".count($I['players'])."/".$I['sv_maxclients']; echo "\n";
echo "Map:         ".$I['mapname']; echo "\n";
echo "Have PunkBuster: "; echo ($I['sv_punkbuster'])?"Yes":"No"; echo "\n\n";

echo "Player list: \n\n";
foreach($I['players'] as $id=>$Name){
	echo "Player no. ".($id+1)."\t".">  ".$Name."\n";
}

echo "\n\n";

# define newline
define(ENDL, "\r\n");

# functions
function findPort($ip){
	# find port in ip
	$p = end(explode(':', $ip));
	return (!empty($p)) ? ($p) : ('28960');
}
function parseStats($ip, $string){
	# vars
	$prop = array();
	$t = explode('\\', $string);

	# parse
	for($i=1;$i<count($t);$i+=2){
		if($t[$i] == 'mod'){
			$prop['players'] = getPlayers($t[$i+1]);
		}
		else $prop[$t[$i]] = $t[$i+1];
	}

	# return properties
	return $prop;
}

# gets players from the server-returned string
function getPlayers($string){
	preg_match_all('#([0-9]{1,5}) ([0-9]{1,5}) \"(.*)\"#', $string, $hits);
	return $hits[3];
}

# check ips
set_time_limit(0);
function getServerInfo($ip){
	$s = @fsockopen('udp://'.str_replace(findPort($ip).':', '', $ip), findPort($ip), $errno, $errstr, 30);
	if(!$s){
		# do sth if failed
		return false;
	} else {
		# succeed
		socket_set_timeout($s, 1, 0);
		stream_set_blocking($s, true);
		stream_set_timeout($s, 2);

		# send handshake and request
		fputs($s, "\xFF\xFF\xFF\xFFgetstatus\x00");
		fwrite($s, "\xFF\xFF\xFF\xFFgetstatus\x00");

		# receive data
		$recv = fread($s, 5000);

		if(!empty($recv)){
			do {
				$spr = socket_get_status($s);
				$recv = $recv . fread($s, 5000);
				$sps = socket_get_status($s);
			} while ($spr['unread_bytes'] != $sps['unread_bytes']);

			# return properties
			$stats = parseStats($ip, $recv);
			return $stats;
		} else {
			return false;
		}
	}
	fclose($s);
}
?>
