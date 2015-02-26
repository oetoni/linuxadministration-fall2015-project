#!/bin/bash
# Linux Administration - FSHN.edu.al - Fall 2015, Semestral Project
# Team Members: Roberta B., Nikolin N., Elton N.
# Version 0.4

#GLOBAL VARIABLES
#0 just display on command lines
#1 save to logs.txt file locally
#2 send results to email address
writeToFileOrSendMail=0
emailAddressToSend=""
#END GLOBAL VARIABLES

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
function sendMail(){
	local mailExecutionCommand="$(eval $1 | mail -s searchDiscover ${emailAddressToSend})"
}
function sendMailWithAttachment(){
	local mailExecutionCommand="$(eval echo \"attached\" | mutt -s searchDiscover -a reportForMail.txt  -- ${emailAddressToSend})"
	rm reportForMail.txt
}
#--------------CASE FUNCTIONS BELOW
function showActiveUsers(){
	if [ "$writeToFileOrSendMail" -eq 1 ]; then
		w >> logs.txt
	elif [ "$writeToFileOrSendMail" -eq 2 ]; then
		sendMail "w"
	else
		w
	fi
	writeToFileOrSendMail=0
}
function showOpenFirewallPorts(){
	if [ "$writeToFileOrSendMail" -eq 1 ]; then
		netstat -lnptu >> logs.txt
	elif [ "$writeToFileOrSendMail" -eq 2 ]; then
		sendMail "netstat -lnptu"
	else
		netstat -lnptu
	fi
	writeToFileOrSendMail=0
}
function showRAMProcesses(){
	if [ "$writeToFileOrSendMail" -eq 1 ]; then
		ps aux | sort -rn -k 5,6 >> logs.txt
	elif [ "$writeToFileOrSendMail" -eq 2 ]; then
		sendMail "ps aux | sort -rn -k 5,6"
	else
		ps aux | sort -rn -k 5,6
	fi
	writeToFileOrSendMail=0
	printf "\033[01;35m $(tput setab 3) NOTE: Processes are filtered based on: $(tput sgr 0) \033[0m\n"
	printf "\033[01;35m $(tput setab 3) 1) RAM usage $(tput sgr 0) \033[0m\n"
	printf "\033[01;35m $(tput setab 3) 2) CPU usage $(tput sgr 0) \033[0m\n"
}
function loopThroughInvalidLoogins(){
	local output=""
	grep -Eo "Invalid user.*([0-9]{1,3}\.){3}[0-9]{1,3}" /var/log/auth.log | while read -r recordLog ; do  
		read -a ipArray <<< "$recordLog"
		
		local geoIPCommand="$(eval geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat ${ipArray[4]})"
		
		oldIFS=$IFS;
		IFS=$','
		read -a geoIpArray <<< "${geoIPCommand///}"
		IFS=$oldIFS
		
		if [ "$writeToFileOrSendMail" -eq 1 ]; then
			printf "USERNAME ATTEMPT: ${ipArray[2]} from ${geoIpArray[1]: (-2)} : ${geoIpArray[4]} with IP: ${ipArray[4]} on coordinates LAT: ${geoIpArray[6]} and LON: ${geoIpArray[7]}" >> logs.txt
		elif [ "$writeToFileOrSendMail" -eq 2 ]; then
			printf "USERNAME ATTEMPT: ${ipArray[2]} from ${geoIpArray[1]: (-2)} : ${geoIpArray[4]} with IP: ${ipArray[4]} on coordinates LAT: ${geoIpArray[6]} and LON: ${geoIpArray[7]} \n" >> reportForMail.txt
		else
			printf "USERNAME ATTEMPT: \033[00;31m ${ipArray[2]} \033[0m from \033[00;32m ${geoIpArray[1]: (-2)} \033[0m:\033[00;32m ${geoIpArray[4]} \033[0m with IP: \033[00;32m ${ipArray[4]} \033[0m on coordinates LAT: \033[01;33m ${geoIpArray[6]} \033[0m and LON: \033[01;33m ${geoIpArray[7]} \033[0m\n"
		fi
	done
	
	if [ "$writeToFileOrSendMail" -eq 2 ]; then
		sendMailWithAttachment
	fi
	
	writeToFileOrSendMail=0
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
		
		if [ "$writeToFileOrSendMail" -eq 1 ]; then
			printf "${ipArray[1]/[/ }, ${geoTrackingResults[1]}, $IP, ${ipArray[2]}, ${geoTrackingResults[2]} \n" >> logs.txt
		elif [ "$writeToFileOrSendMail" -eq 2 ]; then
			printf "${ipArray[1]/[/ }, ${geoTrackingResults[1]}, $IP, ${ipArray[2]}, ${geoTrackingResults[2]} \n" >> reportForMail.txt
		else
			printf "\033[00;32m ${ipArray[1]/[/ }\033[0m, \033[01;33m${geoTrackingResults[1]}\033[0m, \033[00;32m$IP\033[0m, ${ipArray[2]}, \033[01;34m$(tput setab 7)${geoTrackingResults[2]}$(tput sgr 0)\033[0m \n"
		fi
		
		IFS=$oldIFS
	done
	
	if [ "$writeToFileOrSendMail" -eq 2 ]; then
		sendMailWithAttachment
	fi
	
	writeToFileOrSendMail=0
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
		
		if [ "$writeToFileOrSendMail" -eq 1 ]; then
			printf "${ipArray[1]/[/ }, ${geoTrackingResults[1]}, $IP, ${ipArray[2]}, ${geoTrackingResults[2]} \n" >> logs.txt
		elif [ "$writeToFileOrSendMail" -eq 2 ]; then
			printf "${ipArray[1]/[/ }, ${geoTrackingResults[1]}, $IP, ${ipArray[2]}, ${geoTrackingResults[2]} \n" >> reportForMail.txt
		else
			printf "\033[00;32m ${ipArray[1]/[/ }\033[0m, \033[01;33m${geoTrackingResults[1]}\033[0m, \033[00;32m$IP\033[0m, ${ipArray[2]}, \033[01;34m$(tput setab 7)${geoTrackingResults[2]}$(tput sgr 0)\033[0m \n"
		fi
		
		IFS=$oldIFS
	done
	
	if [ "$writeToFileOrSendMail" -eq 2 ]; then
		sendMailWithAttachment
	fi
	
	writeToFileOrSendMail=0
}
function searchOnFilesForPaterns(){
	local fileExtentionsToCheck=""
	local keywordForPaternToCheck=""
	
	while true; do
		printf ":::provide FILE extension(s) to search (ex. png,jpg etc. ot q to quit): \n"
		read userInput;
		if [ "$userInput" == "q" ]; then
			break
		else
			fileExtentionsToCheck+="${userInput},"
		fi
	done
	
	fileExtentionsToCheck=${fileExtentionsToCheck::-1}
	printf "\n you have provided: \033[01;33m $fileExtentionsToCheck \033[0m \n\n"
	
	printf ":::provide TEXT pattern to search: \n"
	read keywordForPaternToCheck
	
	printf "\n you have provided: \033[01;33m $keywordForPaternToCheck \033[0m \n"
	printf ":::your final query looks like: \033[00;32m  grep -rw -i --include=*.{$fileExtentionsToCheck} \"$keywordForPaternToCheck\" / \033[0m \n\n"
	
	local grepExecutionCommand="$(eval grep -rw -i --include=*.{${fileExtentionsToCheck}} \"${keywordForPaternToCheck}\" /)"
	
	if [ "$writeToFileOrSendMail" -eq 1 ]; then
		printf "${grepExecutionCommand} \n" >> logs.txt
	elif [ "$writeToFileOrSendMail" -eq 2 ]; then
		printf "${grepExecutionCommand} \n" >> reportForMail.txt
	else
		printf "${grepExecutionCommand} \n"
	fi
	
	if [ "$writeToFileOrSendMail" -eq 2 ]; then
		sendMailWithAttachment
	fi
	
	writeToFileOrSendMail=0
}
function findAllFilesWithLessThan5LinesCode(){
	#TEST PATH OF FOLDER
	#pathFolder=/home/ubuntu/wordpress/*
	
	printf ":::provide PATH to loop and count file's lines (W/WOUT ENDING /* FOR LOOPING): \n"
	read pathFolder
	
	pathFolder+="/*"
	
	for f in $pathFolder
	do
		#currently only counts all lines on all files, will be updated soon
		local wExecutionCommand="$(eval wc -l ${f})"
		printf "${wExecutionCommand} \n"
		
		if [ "$writeToFileOrSendMail" -eq 1 ]; then
			printf "${wExecutionCommand} \n" >> logs.txt
		elif [ "$writeToFileOrSendMail" -eq 2 ]; then
			printf "${wExecutionCommand} \n" >> reportForMail.txt
		else
			printf "${wExecutionCommand} \n"
		fi
	done
	
	if [ "$writeToFileOrSendMail" -eq 2 ]; then
		sendMailWithAttachment
	fi
	
	writeToFileOrSendMail=0
}
function searchX__patterInsideGivenDirectory(){
	#TESTED PATH /home/ubuntu/wordpress/*
	printf ":::provide file path to search: \n"
	read pathToSearch
	
	local grepExecutionCommand="$(eval grep -rw "\\x[0-9][0-9]" $pathToSearch)"
	printf "${grepExecutionCommand} \n"
	
	if [ "$writeToFileOrSendMail" -eq 1 ]; then
		printf "${grepExecutionCommand} \n" >> logs.txt
	elif [ "$writeToFileOrSendMail" -eq 2 ]; then
		printf "${wExecutionCommand} \n" >> reportForMail.txt
	else
		printf "${grepExecutionCommand} \n"
	fi
	
	if [ "$writeToFileOrSendMail" -eq 2 ]; then
		sendMailWithAttachment
	fi
	
	writeToFileOrSendMail=0
}
#END_FUNCTION_DECLARATION

#EXECUTION_TIME
clear

printf "\n"
varTitle="Starting searchDiscover execution now for user: $USER"
printf $varTitle
printf "\n"

while true; do
	printf "1) LIST OF CONNECTED USERS \n"
	printf "2) OPEN FIREWALL PORTS \n"
	printf "3) SHORTING PROCESSES IN RAM \n"
	printf "4) LOOP THROUGH UNSUCCESSFUL LOGIN ATTPETS \n"
	printf "5) SUCCSESSFUL APACHE CONNECTIONS (200) \n"
	printf "6) UNSUCCSESSFUL APACHE CONNECTIONS (404) \n"
	printf "7) SEARCH TEXT PATTERN(s) OVER ALL FILES \n"
	printf "8) FIND ALL FILES WITH LESS THAN 5 LINES \n"
	printf "9) SEARCH x__ PATTERN OVER ALL FILES INSIDE A DIRECTORY \n"
	printf "SPECIAL OPERATIONS \n"
	printf "s) write function output on logs \n"
	printf "m) send results with email \n"
	printf "0) quit \n"
	read selection;
	
	if [ "$selection" == "1" ]; then
		printf "\033[01;91m $(tput setab 7) LIST OF CONNECTED USERS $(tput sgr 0) \033[0m\n\n"
		showActiveUsers
		printf "\n"
		takeBrake '1.done [Enter] to dig further...'
	elif [ "$selection" == "2" ]; then
		printf "\033[01;91m $(tput setab 7) OPEN FIREWALL PORTS $(tput sgr 0) \033[0m\n\n"
		showOpenFirewallPorts
		printf "\n"
		takeBrake '2.done [Enter] to dig further...'
	elif [ "$selection" == "3" ]; then
		printf "\033[01;91m $(tput setab 7) SHORTING PROCESSES IN RAM $(tput sgr 0) \033[0m\n\n"
		showRAMProcesses
		printf "\n"
		takeBrake '3.done [Enter] to dig further...'
	elif [ "$selection" == "4" ]; then
		printf "\033[01;91m $(tput setab 7) LOOP THROUGH UNSUCCESSFUL LOGIN ATTPETS $(tput sgr 0) \033[0m\n\n"
		loopThroughInvalidLoogins
		printf "\n"
		takeBrake '4.done [Enter] to dig further...'
	elif [ "$selection" == "5" ]; then
		printf "\033[01;91m $(tput setab 7) SUCCSESSFUL APACHE CONNECTIONS (200) $(tput sgr 0) \033[0m\n\n"
		getApacheSuccessfulConnections
		printf "\n"
		takeBrake '5.done [Enter] to dig further...'
	elif [ "$selection" == "6" ]; then
		printf "\033[01;91m $(tput setab 7) UNSUCCSESSFUL APACHE CONNECTIONS (404) $(tput sgr 0) \033[0m\n\n"
		getApacheUnsuccessfulConnections
		printf "\n"
		takeBrake '6.done [Enter] to dig further...'
	elif [ "$selection" == "7" ]; then
		printf "\033[01;91m $(tput setab 7) SEARCH TEXT PATTERN(s) OVER ALL FILES $(tput sgr 0) \033[0m\n\n"
		searchOnFilesForPaterns
		printf "\n"
		takeBrake '7.done [Enter] to dig further...'
	elif [ "$selection" == "8" ]; then
		printf "\033[01;91m $(tput setab 7) FIND ALL FILES WITH LESS THAN 5 LINES $(tput sgr 0) \033[0m\n\n"
		findAllFilesWithLessThan5LinesCode
		printf "\n"
		takeBrake '8.done [Enter] to dig further...'
	elif [ "$selection" == "9" ]; then
		printf "\033[01;91m $(tput setab 7) SEARCH \x__ PATTERN OVER ALL FILES INSIDE A DIRECTORY $(tput sgr 0) \033[0m\n\n"
		searchX__patterInsideGivenDirectory
		printf "\n"
		takeBrake '9.done [Enter] to dig further...'
	elif [ "$selection" == "s" ]; then
		writeToFileOrSendMail=1
		printf "\n\n \033[00;32m writing memo set, choose to exec \033[0m \n\n"
	elif [ "$selection" == "m" ]; then
		writeToFileOrSendMail=2
		printf "\n\n \033[00;32m email memo set, enter email address and choose to exec \033[0m \n\n"
		printf ":::enter email address to send results: \n"
		read emailAddressToSend
	elif [ "$selection" == "0" ]; then
		break
	else
		printf "\n\n \033[00;32m [0-9] only \033[0m \n\n"
	fi
done
