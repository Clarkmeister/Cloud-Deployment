#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[1;35m'
WHITE='\033[0m'
CYAN='\033[0;36m'

echo -e "${PURPLE} \n*****Logging in to Azure*****\n ${WHITE}"
if (az login --service-principal -u $AZ_CLIENT_ID -p $AZ_CLIENT_SECRET --tenant $AZ_TENANT_ID); then
	echo -e "${CYAN} \n*****SUCCESSFULLY LOGGED INTO AZURE*****\n ${WHITE}"
else
	echo -e "${RED} \n*****INVALID AZURE CREDENTIALS*****\n ${WHITE}"
	exit 1
fi

echo -e "${PURPLE} Creating Azure Infrastructure for Packer Build ${WHITE}"

if (terraform init); then
	echo -e "${CYAN} \n*****TERRAFORM INIT SUCCESS*****\n ${WHITE}"
else
	echo -e "${RED} \n*****FAILED TO INIT TERRAFORM*****\n ${WHITE}"
	exit 1
fi

echo -e "${PURPLE} \n*****Logging in to Azure*****\n ${WHITE}"
if (az login --service-principal -u $AZ_CLIENT_ID -p $AZ_CLIENT_SECRET --tenant $AZ_TENANT_ID); then
        echo -e "${CYAN} \n*****SUCCESSFULLY LOGGED INTO AZURE*****\n ${WHITE}"
else
        echo -e "${RED} \n*****INVALID AZURE CREDENTIALS*****\n ${WHITE}"
        exit 1
fi

echo -e "${PURPLE} Running Infrastructure Terraform Apply ${WHITE}"

if (TF_VAR_object_id=$AZ_OBJECT_ID TF_VAR_project_name=$PROJECT_NAME TF_VAR_subscription_id=$AZ_SUBSCRIPTION_ID TF_VAR_client_id=$AZ_CLIENT_ID TF_VAR_client_secret=$AZ_CLIENT_SECRET TF_VAR_tenant_id=$AZ_TENANT_ID terraform apply --auto-approve); then
        echo -e "${CYAN} \n*****TERRAFORM APPLY SUCCESS*****\n ${WHITE}";
	AZ_RESOURCE_GROUP=$(cat terraform.tfstate | jq '.modules[].resources."azurerm_resource_group.azure".primary.attributes.name');
	AZ_STORAGE_ACCOUNT=$(cat terraform.tfstate | jq '.modules[].resources."azurerm_storage_account.azure".primary.attributes.name');
	echo "#!/bin/bash" > envSet.sh
	echo "export AZ_RESOURCE_GROUP=$AZ_RESOURCE_GROUP" >> envSet.sh;
	echo "export AZ_STORAGE_ACCOUNT=$AZ_STORAGE_ACCOUNT" >> envSet.sh;	
	echo -e "${CYAN} \n AZ_RESOURCE_GROUP=$AZ_RESOURCE_GROUP \n AZ_STORAGE_ACCOUNT=$AZ_STORAGE_ACCOUNT \n ${WHITE}"
	source envSet.sh
else
        echo -e "${RED} \n*****FAILED TERRAFORM APPLY*****\n ${WHITE}"
        exit 1
fi

echo -e "${PURPLE} Running Packer Build on image.json ${WHITE}"

if (packer build haproxyImage.json); then
        echo -e "${CYAN} \n*****PACKER BUILD SUCCESS*****\n ${WHITE}"
else
        echo -e "${RED} \n*****PACKER BUILD FAILED*****\n ${WHITE}"
        exit 1
fi

echo -e "${PURPLE} *****INFRASTRUCTURE AND IMAGE SUCCESFULLY CREATED***** ${WHITE}"


