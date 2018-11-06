#!/bin/bash

start=$SECONDS
green='\033[0;32m'
white='\033[0m'

sed -i '/target0/,$d' main.tf

count=$NUM_CONTAINERS
port=5000
index=0
while [ $count -gt 0 ]; do
    echo 'resource "aws_alb_target_group_attachment" "target'$index'" {' >> main.tf
    echo -e '\ttarget_group_arn = "${aws_lb_target_group.test.arn}"' >> main.tf
    echo -e '\ttarget_id        = "${element(aws_instance.web.*.id, count.index)}"' >> main.tf
    echo -e '\tport             = '$port >> main.tf
    echo -e '\tcount         = "${var.num_vm}"' >> main.tf
    echo '}' >> main.tf
    let port+=1
    let count-=1
	let index+=1
done

TF_VAR_ami_id=$AWS_AMI TF_VAR_aws_region=$AWS_REGION TF_VAR_key_name=$AWS_KEY_NAME TF_VAR_security_group_id=$AWS_SECURITY_GROUP_ID TF_VAR_username=$AWS_USERNAME TF_VAR_containers=$NUM_CONTAINERS TF_VAR_num_vm=$NUM_VM TF_VAR_alb_name=$ALB_NAME TF_VAR_vpc_id=$AWS_VPC_ID TF_VAR_aws_access_key=$AWS_ACCESS_KEY TF_VAR_aws_secret_key=$AWS_SECRET_KEY terraform apply --auto-approve

duration=$(( SECONDS - start ))

seconds=$((duration % 60))

minute=$(( (duration - seconds)/60 ))

echo "Build Time: $minute""m$seconds""s"$'\n'
