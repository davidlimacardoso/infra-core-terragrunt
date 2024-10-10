# Vprofile Project

## Project Overview

This repository contains the infrastructure-as-code for the Vprofile project, implemented using Terraform and Terragrunt. The project is designed to deploy a scalable and secure application infrastructure in AWS.

## Directory Structure

```
dev/vprofile/
├── account.hcl
└── us-east-1
├── acm
│ ├── main.tf
│ ├── outputs.tf
│ ├── terragrunt.hcl
│ └── vars.tf
├── auto-scaling
│ ├── main.tf
│ ├── outputs.tf
│ ├── terragrunt.hcl
│ └── vars.tf
├── ec2
│ ├── ec2.tf
│ ├── key.tf
│ ├── outputs.tf
│ ├── terragrunt.hcl
│ ├── vars.tf
│ └── vprofile-dev-pair.pem *IS GENERATED WHEN APPLY*
├── iam
│ └── roles
│ ├── outputs.tf
│ ├── roles.tf
│ ├── terragrunt.hcl
│ └── vars.tf
├── load-balancer
│ ├── main.tf
│ ├── outputs.tf
│ ├── terragrunt.hcl
│ └── vars.tf
├── network-core
│ ├── outputs.tf
│ └── terragrunt.hcl
├── region.hcl
├── route53
│ ├── main.tf
│ ├── outputs.tf
│ ├── terragrunt.hcl
│ └── vars.tf
├── s3
│ ├── outputs.tf
│ ├── s3.tf
│ ├── terragrunt.hcl
│ └── vars.tf
└── security-groups
├── output.tf
├── sg.tf
├── terragrunt.hcl
└── vars.tf
```


## Components

1. **ACM (AWS Certificate Manager)**
   - Manages SSL/TLS certificates for secure communications.

2. **Auto Scaling**
   - Configures Auto Scaling groups to ensure application availability and scalability.

3. **EC2 (Elastic Compute Cloud)**
   - Manages EC2 instances and associated resources like key pairs.

4. **IAM (Identity and Access Management)**
   - Defines IAM roles for secure access management.

5. **Load Balancer**
   - Sets up load balancing to distribute traffic across multiple instances.

6. **Network Core**
   - Configures core networking components, likely including VPC setup.

7. **Route 53**
   - Manages DNS configurations for the application.

8. **S3 (Simple Storage Service)**
   - Configures S3 buckets for storage needs.

9. **Security Groups**
   - Defines security groups to control inbound and outbound traffic.

## Getting Started

### Prerequisites

- Terraform
- Terragrunt
- AWS CLI configured with appropriate credentials

### Deployment

1. Navigate to the desired component directory.
2. Review and modify the `terragrunt.hcl` file as needed.
3. Run `terragrunt plan` to preview changes.
4. Execute `terragrunt apply` to apply the changes.

## Configuration

- `account.hcl`: Contains account-specific configurations.
- `region.hcl`: Specifies region-specific settings.
- Individual `terragrunt.hcl` files: Component-specific configurations and dependencies.

## Best Practices

- Use environment variables for sensitive information.
- Regularly update and rotate access keys.
- Follow the principle of least privilege when defining IAM roles.
- Encrypt data at rest and in transit.

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the [LICENSE NAME] - see the LICENSE.md file for details.

## Acknowledgments

- List any third-party libraries, tools, or resources used in the project.
