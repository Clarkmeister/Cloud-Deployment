#!/bin/bash

function printHelp
{
	echo "					"
	echo "Usage: Run terraform apply/destroy."
	echo "-h,    --help             show brief help"
	echo "-d,    --destroy          run terraform destroy command"
	echo "-demo, --demo             runs terraform create and destory for testing purposes" 
	echo "                          default number of containers = $NUM_CONTAINERS"
	echo "                          the default can be set in ../../.envrc"
	echo "                          running script creates vms"
}

function create
{
        # Build, Deploy, and Test Application.

        echo "Running Packer: (DISABLED AT THE MOMENT)"
        #cd multi-vsphere/vsphereVM/Packer
        #packer validate aws_template.json
	#packer build aws_template.json

	echo "Running Terraform:"
	cd alb
	terraform init
	./run.sh	
	

	echo "Running Inspec Tests:"
	cd ../testing/connectionTesting/
	mkdir controls
	cd controls
	touch connectionTest.rb
	cd ../../../alb
	./addIpsInspec.sh


	end=$((SECONDS+600))
	echo "Checking ip before testing..."
	echo "Timesout after 10 minutes if there is no response."
	port=`expr $NUM_CONTAINERS - 1`
	for i in $(seq 1 $NUM_VM); 
	do
		for j in $(seq 0 $port);
		do
			while [ $SECONDS -lt "$end" ]; do
				line=$(head -n $i testfile)
				line="$line:500$j"
				wget --spider --timeout=0.5 -t 1 "${line}" &> /dev/null
				if [ $? -eq 0 ]; then
					break
				fi
			done 
		done
		
		if [ $SECONDS -ge "$end" ]; then
			break
		fi
	done
	sleep 30s	
	echo "Connections made!"
	cd ../testing/connectionTesting/
	inspec exec controls/
	rm -rf controls/
	rm ../../alb/testfile
	cd ../../
}

function destroy
{
	echo "Removing VM(s):"
	cd alb/
	./destroy.sh
	cd ..
}

function demo
{
    create
    destroy

}

if [[ $# -eq 0 ]] ; then
	create
else
	while test $# -gt 0; do
		case "$1" in
			-demo|--demo)
				shift
				demo
				;;
			-d|--destroy)
				shift
				destroy
				;;
			-h|--help)
				printHelp
				exit 0
				;;
			*)
				break
				;;
		esac
	done
fi
echo "Done"
