#!/bin/bash

echo "Apply complete. Adding IP addresses to inspec test script."
touch name
touch testfile
addedIPs=0
terraform output vm_public_ip_addresses | sed 's/,//' > testfile # gets IP addresses to add.
	  count=1
	  nl=$'\n'
	  while IFS='' read -r line || [[ -n "$line" ]]; do
	  port=5000
	  ip_address=$line; #:$port;
	  for i in $(seq 1 $NUM_CONTAINERS);
	  do
	  ip_port=$port;
((port++))
	echo "describe host(ip_address$count, port:$ip_port, protocol: 'tcp') do ${nl} it{should be_reachable} ${nl} its('ipaddress'){should include ip_address$count}${nl} end " >> ../testing/connectionTesting/controls/connectionTest.rb
	echo "describe http('http://' + ip_address$count + ':$ip_port/') do ${nl} its('status') {should cmp 200} ${nl} end" >> ../testing/connectionTesting/controls/connectionTest.rb
((addedIPs++))
	done
	echo "ip_address$count='$ip_address'" >> name # adds completed strings to temp file

((count++))
	done < testfile

	cat name ../testing/connectionTesting/controls/connectionTest.rb > $$.tmp && mv $$.tmp ../testing/connectionTesting/controls/connectionTest.rb

	rm name
