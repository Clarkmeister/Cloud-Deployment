#!/bin/bash
touch test1
touch test2
# get current list of IPs from haproxy config, so we can check if they exist
sed -e '1,/backend web-backend/d' -e '/# round robin balancing between the various backends/,$d' /etc/haproxy/haproxy.cfg > test1 
sed -i '1d;$d' test1
sed 's/^[ \t]*//;s/[ \t]*$//' test1 | cut -d ' ' -f 3 > test2
count=0
# uses wget to check if the ip address is still alive. Use --spider to not download any files, with a short timeout
while read url; do
	wget --spider --timeout=0.5 -t 1 "${url}" &> /dev/null # Checks if IP exists 
	if [ $? -eq 0 ] 
	then
		echo "URL exists: $url"
	else
		echo "URL does not exist: $url"
		sudo sed -i '/'"$url"'/d' /etc/haproxy/haproxy.cfg # if doesn't exist, remove from haproxy config.
		((count++))
		echo "Removed $url from haproxy file"
	fi	
done < test2
echo "deleted $count IPs from proxyfile"
rm test1 # cleanup
rm test2
