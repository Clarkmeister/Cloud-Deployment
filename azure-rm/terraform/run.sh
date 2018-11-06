#!/bin/bash

terraform init

az login --service-principal -u $AZ_CLIENT_ID -p $AZ_CLIENT_SECRET --tenant $AZ_TENANT_ID

TF_VAR_project_name=$PROJECT_NAME TF_VAR_containers=$NUM_CONTAINERS TF_VAR_num_vms=$NUM_VMS TF_VAR_client_secret=$AZ_CLIENT_SECRET TF_VAR_tenant_id=$AZ_TENANT_ID TF_VAR_client_id=$AZ_CLIENT_ID TF_VAR_subscription_id=$AZ_SUBSCRIPTION_ID terraform apply --auto-approve
