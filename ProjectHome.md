This project consists on developing different techniques inside a single BASH script(s) unit that will assist on performing regular Linux server audits and help eliminate unwanted access and block unwanted traffic. The project will also develop searching techniques for known web attacks through. The minimal research of the know issues is based on:<br />
- reporting projects over the networks<br />
- known malicious patters published by service providers<br />
- documented attacks<br />

### NOTES ###
1) to install GeoIP services call "sudo apt-get install geoip-bin"<br />
2) 1-9 are function calling, "s" in order to store output on local text file, 0 to quit<br />
3) when you create the script for the first time grand access to it "chmod 755 searchDiscover.sh"
### HOW TO USE ###
Run and select 1-9 for operational functions. 0 to quit.
"s" and "m": When on main menu select "s" and then again from the loop menu select the function to be executed and its output will be stored on the logs.txt file in the same directory. When on main menu select "m", when propted enter your email address, and then again from the loop menu select the function to be executed and its' output will be send to you through "mail" and "mutt" (when attachment) to you.

### The scripts will cover ###
Searching with GREP recursively, Altering/Modifying GREP output according to user priorities, Looping through Logs, implementing added information after record analysis, Geo-locating IPs, BASH function calling, parameter passing, String manipulation techniques, Terminal interface altering, BASH I/O, BASH mail sending<br />
### Server side configurations ###
- Configuration of FTP server<br />
- Configuration of MySQL and phpMyAdmin (along with other tools)<br />
Our test housing: Amazon Web Services EC2 with Ubuntu 14, 64bit, root unguarded. Please note a very slight altering for requirements if using CentOS (script is the same but you need to have installed mail, mutt, geoip ect.<br />

To log in via PuTTY

Host Name (or IP adress): 54.69.164.35
Port 22
Connection type **SSH
login as: ubuntu**

(ask with email for the private key in order to connect, no password necessary - remember to switch sudo su)
Working directory: /home/ubuntu/bin/searchDiscover.sh