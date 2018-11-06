#!/bin/bash
# This script is used to update the haproxy file. This is now implmented into the runterraform.sh script, so it is not necessary anymore.
touch name
chmod 777 name

echo "frontend main" >> name
echo "        bind *:80" >> name
echo "        default_backend app" >> name
echo "" >> name
echo "backend app" >> name
echo "   balance      roundrobin" >> name

sed -i '60, $d' /etc/haproxy/haproxy.cfg
#sudo cat frontEnd.txt >> /etc/haproxy/haproxy.cfg
echo "NUM CONTAINERS: $NUM_CONTAINERS"

count=1
port=5000
for i in $(seq 1 $NUM_CONTAINERS);
do
	ip_port=$"*:"$port
	((port++))
	echo "  server $PROJECT_NAME$count $ip_port check"
	echo "  server $PROJECT_NAME$count $ip_port check" >> name
	((count++))
done 

while IFS='' read -r line || [[ -n "$line" ]]; do #place in file
	echo "$line"
	echo "$line" >> /etc/haproxy/haproxy.cfg
done < name
echo "Process complete."
rm name

