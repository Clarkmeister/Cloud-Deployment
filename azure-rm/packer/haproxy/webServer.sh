#!/bin/bash -eux
tar -xvf /tmp/webServer.tar.gz -C /tmp/
# Replacing Default Docker Daemon File to Allow Wifi Access to VM After Docker Start.
sudo su - -c "mv /tmp/webServer/docker_daemon.json /etc/docker/daemon.json"
# Verifying Replacement was Successful
sudo su - -c "cat /etc/docker/daemon.json"
# Moving Web Server Service Script to (Default Linux Service Script Directory).
sudo su - -c "mv /tmp/webServer/mjolnir_web_service.sh /usr/bin/"
# Verifying move was successful
sudo su - -c "cat /usr/bin/mjolnir_web_service.sh"
# Moving service into Systemd Directory (Default Service Directory).
sudo su - -c "mv /tmp/webServer/mjolnirWebService.service /lib/systemd/system/"
# Verifying move was successful
sudo su - -c "cat /lib/systemd/system/mjolnirWebService.service"
# Reloading system daemon to recognize new service.
sudo su - -c "systemctl daemon-reload"
# Enabling service On-Boot Startup 
sudo su - -c "systemctl enable mjolnirWebService"
# Stopping service because it is no longer needed.
sudo su - -c "systemctl stop mjolnirWebService"
# Registering Private DNS Servers
echo "search corp.dom
nameserver 10.4.240.100
nameserver 10.152.2.100" > /etc/resolv.conf
echo "RSAAuthentication yes" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
