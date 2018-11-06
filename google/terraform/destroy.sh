#!/bin/bash
TF_VAR_user=$USER TF_VAR_containers=$NUM_CONTAINERS TF_VAR_num_vm=$NUM_VM TF_VAR_project_name=$PROJECT_NAME terraform destroy --auto-approve

sed -i '/named_port/,+4 d' main.tf
