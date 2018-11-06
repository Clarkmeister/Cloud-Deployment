#!/bin/bash

start=$SECONDS

TF_VAR_ami_id=$AWS_AMI TF_VAR_aws_region=$AWS_REGION TF_VAR_key_name=$AWS_KEY_NAME TF_VAR_security_group_id=$AWS_SECURITY_GROUP_ID TF_VAR_username=$AWS_USERNAME TF_VAR_containers=$NUM_CONTAINERS TF_VAR_num_vm=$NUM_VM TF_VAR_alb_name=$ALB_NAME TF_VAR_vpc_id=$AWS_VPC_ID TF_VAR_aws_access_key=$AWS_ACCESS_KEY TF_VAR_aws_secret_key=$AWS_SECRET_KEY terraform destroy --auto-approve

sed -i '/target0/,$d' main.tf

duration=$(( SECONDS - start ))

seconds=$((duration % 60))

minute=$(( (duration - seconds)/60 ))

echo "Build Time: $minute""m$seconds""s"$'\n'
