#!/bin/bash

NUM_CONTAINERS=""

while [ -z "$NUM_CONTAINERS" ] 
do

echo "NUM_CONTAINERS is EMPTY. Still Waiting..."
sleep 0.5
# Source the enviormental file that contains variable of  number of containers
source envVar.sh
export NUM_CONTAINERS

done

echo "NUM_CONTAINERS= $NUM_CONTAINERS"

# Initialize the port and count variable used for loop
port=5000
count=$NUM_CONTAINERS

# Setting up docker imgae to create containers
echo "Starting Docker Service..."
sudo systemctl start docker
echo "Creating Creating Docker Image..."
cd /tmp/webServer/app/
#sudo docker build -t flask-sample-one:latest .
sudo docker load -i webServerDockerImage.tar.gz
sudo docker tag 57966ba415bd flask-sample-one:latest

echo "Starting Web Server..."

# Create x number of containers beased on count variable
until [ $count -lt 1 ]; do
    sudo docker run -d -p $port:5000 flask-sample-one
    ((port+=1))
    ((count-=1))
done

IPADDRESS="$(ip addr show eth0 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n1)"
CONTAINERIDS="$(sudo docker ps --format "{{.ID}}" | head )"

for word in $CONTAINERIDS
do
    sudo docker exec $word  sed -i "13i <p id=\"tag\">IP Address: $IPADDRESS | Docker Container ID:$word</p>" templates/index.html
done

echo "Web Server is Running..."
