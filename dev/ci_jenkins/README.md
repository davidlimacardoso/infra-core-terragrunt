# Jenkins CI/CD Infrastructure Project

This project sets up the infrastructure for a Jenkins CI/CD environment in AWS using Terragrunt and Terraform.

## Overview

The project configures the following components:
- Jenkins server
- Bastion host for secure SSH access
- Elastic Load Balancer (ELB) for Jenkins
- Associated security groups

## Prerequisites

- AWS account
- Terraform installed
- Terragrunt installed
- Appropriate AWS credentials configured

## Infrastructure Components

### Security Groups

1. **Jenkins Server Security Group**
   - Allows SSH access from the bastion host
   - Allows inbound traffic on port 8080 from the ELB

2. **Bastion Host Security Group**
   - Allows SSH access from any IP (0.0.0.0/0)

3. **Jenkins ELB Security Group**
   - Allows HTTP (80) and HTTPS (443) traffic from any IP

### Network

- Uses an existing VPC (referenced as a dependency)

## Deployment

To deploy this infrastructure:

1. Ensure you have the correct AWS credentials set up.
2. Navigate to the project directory.
3. Run the following commands:

```
terragrunt init
terragrunt plan
terragrunt apply
```


## Architecture

               +----------------+
               |                |
        +----->|  Jenkins ELB   |
        |      |                |
        |      +----------------+
        |               |
        |               |
        |               v
    +---------+ | +----------------+
    | | | | |
    | Bastion +------->| Jenkins Server |
    | | | |
    +---------+ +----------------+


## Security Considerations

- The Jenkins server is not directly accessible from the internet. All traffic is routed through the ELB.
- SSH access to the Jenkins server is only allowed via the bastion host.
- The bastion host is the only component with a public IP and direct SSH access from the internet.

## Customization

You can customize the security group rules and other configurations by modifying the `terragrunt.hcl` file.

## Maintenance

Remember to regularly update your Jenkins server and associated plugins to ensure security and stability.

## Jenkins Configuration

- Join into bastion server with a key generated inside ../ec2/jenkins-key.pem with command `ssh -i jenkins-key.pem ec2-user@PUBLIC_IP_BASTION`.

- Copy jenkins-key.pem into bastion server, `echo "DATA OF KEY" > jenkins-key.pem` and set permissions file `chmod 400 jenkins-key.pem`.

- Connect to jenkins server `ssh -i jenkins-key.pem ubuntu@PRIVATE_IP_JENKINS_SERVER` 

- Verify the Jenkins states with command `sudo systemctl status jenkins`

- Access domain load balancer https://jenkins-server-dev-lb-XXXXXXXX.us-east-1.elb.amazonaws.com/

- Verify the first password generated `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`. Will be generated the password example 2afa4930010f4f6bb674094f1078b591, copy and paste the password at Jenkins login page. 

- After of configuration, set you user and password. 

## Contributing


## License

MIT