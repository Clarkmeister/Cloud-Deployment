#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[1;35m'
WHITE='\033[0m'
CYAN='\033[0;36m'

echo -e "${PURPLE} Running Infrastructure Terraform Destroy ${WHITE}"

if (TF_VAR_object_id=$AZ_OBJECT_ID TF_VAR_project_name=$PROJECT_NAME TF_VAR_subscription_id=$AZ_SUBSCRIPTION_ID TF_VAR_client_id=$AZ_CLIENT_ID TF_VAR_client_secret=$AZ_CLIENT_SECRET TF_VAR_tenant_id=$AZ_TENANT_ID terraform destroy --auto-approve); then
        echo -e "${CYAN} \n*****TERRAFORM DESTROY SUCCESS*****\n ${WHITE}"
else
        echo -e "${RED} \n*****FAILED TERRAFORM DESTROY*****\n ${WHITE}"
        exit 1
fi

