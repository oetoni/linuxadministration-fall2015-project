#!/bin/bash
# Linux Administration - FSHN.edu.al - Fall 2015, Semestral Project
# Team Members: Areti B., Nikolin N., Elton N.
# Revision 5, Version 1.1

#FUNCTION_DECLARATION
function takeBrake(){
	read -p "$*"
}
function returnGeoIP(){
	geoIPCommandGlobal="$(eval geoiplookup $1)"
	geoIPCommandGlobal=$(echo $geoIPCommandGlobal|tr -d '\n')
	geoIPCommandGlobal=${geoIPCommandGlobal/GeoIP Country Edition: /|}
	geoIPCommandGlobal=${geoIPCommandGlobal/GeoIP ASNum Edition: /|}
}
function showActiveUsers(){
	w
}
function showOpenFirewallPorts(){
	netstat -lnptu
}
function showRAMProcesses(){
	ps aux | sort -rn -k 5,6
	printf "\033[01;35m $(tput setab 3) NOTE: Processes are filtered based on: $(tput sgr 0) \033[0m\n"
	printf "\033[01;35m $(tput setab 3) 1) RAM usage $(tput sgr 0) \033[0m\n"
	printf "\033[01;35m $(tput setab 3) 2) CPU usage $(tput sgr 0) \033[0m\n"
}
function loopThroughInvalidLoogins(){
	grep -Eo "Invalid user.*([0-9]{1,3}\.){3}[0-9]{1,3}" /var/log/auth.log | while read -r recordLog ; do  
			read -a ipArray <<< "$recordLog"
			
			local geoIPCommand="$(eval geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat ${ipArray[4]})"
			
			oldIFS=$IFS;
			IFS=$','
			read -a geoIpArray <<< "${geoIPCommand///}"
			IFS=$oldIFS
			
			printf "USERNAME ATTEMPT: \033[00;31m ${ipArray[2]} \033[0m from \033[00;32m ${geoIpArray[1]: (-2)} \033[0m:\033[00;32m ${geoIpArray[4]} \033[0m with IP: \033[00;32m ${ipArray[4]} \033[0m on coordinates LAT: \033[01;33m ${geoIpArray[6]} \033[0m and LON: \033[01;33m ${geoIpArray[7]} \033[0m\n"
		done
}

function getApacheSuccessfulConnections(){
	local geoIPCommand=$(grep -Eoc "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.* 200" /var/log/apache2/access.log)
	
	printf "\033[01;91m $(tput setab 7) There are a total of $geoIPCommand known 200's requests. $(tput sgr 0) \033[0m\n"
	
	printf "\n"
	printf "\033[01;91m $(tput setab 7) DETAILED LIST: $(tput sgr 0) \033[0m\n"
	grep -Eo "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.* 200"  /var/log/apache2/access.log | while read -r recordLog ; do
			
			recordLog=${recordLog/ - - /|}
			recordLog=${recordLog/ +0000] /|}

			oldIFS=$IFS
			IFS=$'|'
			
			read -a ipArray <<< "$recordLog"
			
			IP=${ipArray[0]}
			returnGeoIP ${ipArray[0]}
			
			read -a geoTrackingResults <<< "$geoIPCommandGlobal"
			
			printf "\033[00;32m ${ipArray[1]/[/ }\033[0m, \033[01;33m${geoTrackingResults[1]}\033[0m, \033[00;32m$IP\033[0m, ${ipArray[2]}, \033[01;34m$(tput setab 7)${geoTrackingResults[2]}$(tput sgr 0)\033[0m \n"
			
			IFS=$oldIFS
		done
}

function getApacheUnsuccessfulConnections(){
	local geoIPCommand=$(grep -Eoc "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.* 404" /var/log/apache2/access.log)
	
	printf "\033[01;91m $(tput setab 7) There are a total of $geoIPCommand known 404's requests. $(tput sgr 0) \033[0m\n"
	
	printf "\n"
	printf "\033[01;91m $(tput setab 7) DETAILED LIST: $(tput sgr 0) \033[0m\n"
	
	grep -Eo "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.* 404"  /var/log/apache2/access.log | while read -r recordLog ; do
			
			recordLog=${recordLog/ - - /|}
			recordLog=${recordLog/ +0000] /|}

			oldIFS=$IFS
			IFS=$'|'
			
			read -a ipArray <<< "$recordLog"
			
			IP=${ipArray[0]}
			returnGeoIP ${ipArray[0]}
			
			read -a geoTrackingResults <<< "$geoIPCommandGlobal"
			
			printf "\033[00;32m ${ipArray[1]/[/ }\033[0m, \033[01;33m${geoTrackingResults[1]}\033[0m, \033[00;32m$IP\033[0m, ${ipArray[2]}, \033[01;34m$(tput setab 7)${geoTrackingResults[2]}$(tput sgr 0)\033[0m \n"
			
			IFS=$oldIFS
		done
}
#END_FUNCTION_DECLARITION

#EXECUTION_TIME
clear

printf "\n"
varTitle="Starting searchDiscover execution now for user: $USER"
printf $varTitle
printf "\n"

printf "\033[01;91m $(tput setab 7) LIST OF CONNECTED USERS $(tput sgr 0) \033[0m\n"
printf "\n"
showActiveUsers
printf "\n"

takeBrake '[Enter] to dig further...'

printf "\033[01;91m $(tput setab 7) OPEN FIREWALL PORTS $(tput sgr 0) \033[0m\n"
printf "\n"
showOpenFirewallPorts
printf "\n"

takeBrake '[Enter] to dig further...'

printf "\033[01;91m $(tput setab 7) SHORTING PROCESSES IN RAM $(tput sgr 0) \033[0m\n"
printf "\n"
showRAMProcesses
printf "\n"

takeBrake '[Enter] to dig further...'

printf "\033[01;91m $(tput setab 7) LOOP THROUGH UNSUCCESSFUL LOGIN ATTPETS $(tput sgr 0) \033[0m\n"
printf "\n"
loopThroughInvalidLoogins
printf "\n"

takeBrake '[Enter] to dig further...'

printf "\033[01;91m $(tput setab 7) SUCCSESSFUL APACHE CONNECTIONS (200) $(tput sgr 0) \033[0m\n"
printf "\n"
getApacheSuccessfulConnections
printf "\n"

takeBrake '[Enter] to dig further...'

printf "\033[01;91m $(tput setab 7) UNSUCCSESSFUL APACHE CONNECTIONS (404) $(tput sgr 0) \033[0m\n"
printf "\n"
getApacheUnsuccessfulConnections
printf "\n"

takeBrake '[Enter] to dig further...'
