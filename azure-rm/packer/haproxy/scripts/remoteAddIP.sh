#!/bin/bash
# This script is used to update the haproxy file. This is now implmented into the runterraform.sh script, so it is not necessary anymore.

########################################################
#
# After geting Terraform IP ouputs and ports from terraform put into a file called 'name', we send that file to the targeted VM. This scripts assumes that the name file already exists at the directory /tmp/.
########################################################

#
#We are looking for the place to add the IP addresses
#
while IFS='' read -r line || [[ -n "$line" ]]; do #place in file
        sudo sed -i 's/.*backend web-backend.*/&\n '"$line"'/' /etc/haproxy/haproxy.cfg
#
#adding the IP addresses to the right location
#
done < name
#
#adding necessary lines to run HAPROXY (load balancing and name of our server list)
#
sudo sed -i 's/.*backend web-backend.*/&\n   balance     roundrobin/' /etc/haproxy/haproxy.cfg
echo "Process complete."
rm name
