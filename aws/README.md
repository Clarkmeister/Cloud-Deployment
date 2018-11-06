# __Amazon Web Services Cloud Deployment__

### __Load balancing virtual machines and docker containers using Packer and Terraform__

## __Setup__

### __Changing environment variables.__

1. Open [.envrc](https://xwtcvpgit:8443/projects/MJOLNIR/repos/cloud-deployment/browse/aws/.envrc) in a text editor.
2. Locate the MODIFIED VARIABLES section.
3. Change the ALB_NAME to a recognizable name. 
* ( This name will be used throught the creation process of the image, vms, and load balancer. )
4. Change the NUM_VM variable to the number of virtual machines you intend to create. 
* ( This can be done after creating the AWS AMI )
5. Change the NUM_CONTAINERS variable to the number of docker containers running the mjolnir web server that you intend to create. 
* ( This can be done after creating the AWS AMI )
6. Save the changes made to the [.envrc](https://xwtcvpgit:8443/projects/MJOLNIR/repos/cloud-deployment/browse/aws/.envrc).
7. Run direnv allow to load the new environment variables.

### __Building an AWS AMI__

#### __Prerequisites__

1. Docker Image wrapped into a tar.gz file and saved to AWS Bucket.
* _(Packer provisioner in [aws-ebs-ami.json](https://xwtcvpgit:8443/projects/MJOLNIR/repos/cloud-deployment/browse/aws/packer-ebs-ami/aws-ebs-ami.json) downloads this image from the AWS Bucket to later be deployed on VM's)_

#### __Building the Image__

1. Navigate to the [packer-ebs-ami](https://xwtcvpgit:8443/projects/MJOLNIR/repos/cloud-deployment/browse/aws/packer-ebs-ami) directory.
* ( *If the directory already contains a webServer.tar.gz file skip step 2* )
2. Run the [packWebServer.sh](https://xwtcvpgit:8443/projects/MJOLNIR/repos/cloud-deployment/browse/aws/packer-ebs-ami/packWebServer.sh?at=README) script. This will pack the webServer directory into a tar file.
3. Run the command `packer build aws-ebs-ami.json`. This will start to create a AMI on Amazon Web Services using Packer.
4. Save the name of the created AWS AMI this is output at the end of the build.

## __Deployment__

### __Deploying Amazon Web Services instances running Mjolnir Docker containers__

1. Simply run the [runApplication.sh](https://xwtcvpgit:8443/projects/MJOLNIR/repos/cloud-deployment/browse/aws/runApplication.sh) script.
2. Navigate to the public_domain_address displayed after terraform finishes.
3. Deployment Completed and you now have a working Load Balanced AWS Web Server.

### __Scaling__

1. Change the variables in the [.envrc](https://xwtcvpgit:8443/projects/MJOLNIR/repos/cloud-deployment/browse/aws/.envrc) to match the number of VM's and Containers you want to deploy and re-run the [runApplication.sh](https://xwtcvpgit:8443/projects/MJOLNIR/repos/cloud-deployment/browse/aws/runApplication.sh) script.

## __Destroying__

1. Simply run the [runApplication.sh](https://xwtcvpgit:8443/projects/MJOLNIR/repos/cloud-deployment/browse/aws/runApplication.sh) script with the `-d` flag.

## __Testing__

1. Simply run the [runApplication.sh](https://xwtcvpgit:8443/projects/MJOLNIR/repos/cloud-deployment/browse/aws/runApplication.sh) script with the `--demo` flag.