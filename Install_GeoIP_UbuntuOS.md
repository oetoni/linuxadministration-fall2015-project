In order to use the script you MUST have installed the following module. The script take advantage of executing and collecting the results of "geoiplookup" command.<br />
Installation Process:
<br />
Step 1:<br />
$ sudo apt-get install geoip-bin<br />
...and you're done.<br />
Execution commands:<br />
for country level lookup use this<br />
$ geoiplookup 8.8.8.8<br />
<br />
for city level lookup use this<br />
$ geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat 8.8.8.8<br />
<br />
References:
http://xmodulo.com/geographic-location-ip-address-command-line.html