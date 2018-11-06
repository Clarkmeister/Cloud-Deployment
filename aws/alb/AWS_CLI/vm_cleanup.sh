#!/bin/bash

#get instance ids
echo "putting all instances in file"


touch resources.json
aws ec2 describe-instances > resources.json


#instances() {
    #touch instance_descriptions.json
    aws ec2 describe-instances > resources.json
    python search_json.py > instance_IDs.txt
    while IFS='' read -r line || [[ -n "$line" ]]; do
        aws ec2 terminate-instances --instance-ids $line
    done < instance_IDs.txt
    rm instance_IDs.txt
#}

