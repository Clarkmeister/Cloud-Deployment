#!/bin/bash 

#
#We need to update haproxy from 1.5 to 1.8. This script should take care of that
#

cd /tmp/
tar -xzf haproxy.tar.gz
mv haproxy-* haproxy/
cd haproxy
make TARGET=2628 USE_PCRE=1 USE_PCRE_JIT=1 USE_OPENSSL=1 USE_ZLIB=1 USE_REGPARM=1
sudo make install
sudo cp -f /usr/local/sbin/haproxy /usr/sbin
sudo service haproxy restart
sudo chkconfig haproxy on
