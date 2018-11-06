#!/bin/bash

sed -i '/named_port/,+4 d' main.tf

touch baseFile

addedVMs=0
port=5000

for i in $(seq 1 $NUM_CONTAINERS); # build the strings
do
        echo -e "  named_port { \n   name = \"jorts\" \n   port = \"$port\" \n  } \n" >> baseFile
        ((port++))
done

sed -i "/SED HERE/r baseFile" main.tf # place the strings

rm baseFile

TF_VAR_user=$LOGNAME TF_VAR_containers=$NUM_CONTAINERS TF_VAR_num_vm=$NUM_VM TF_VAR_project_name=$PROJECT_NAME terraform apply --auto-approve
