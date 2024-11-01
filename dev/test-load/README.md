# K6 Load Testing Infrastructure with CodePipeline

## Overview
This project implements an automated load testing infrastructure using k6, AWS CodePipeline, InfluxDB, and Grafana. The infrastructure is defined as code using Terraform and Terragrunt, enabling consistent and repeatable deployments.

## Architecture

### Components
- **AWS CodePipeline**: Orchestrates the CI/CD pipeline for automated load testing
- **InfluxDB**: Time-series database for storing test metrics
- **Grafana**: Visualization and monitoring dashboard
- **K6**: Performance testing tool
- **EC2**: Hosts the testing infrastructure
- **Application Load Balancer**: Distributes traffic
- **Route53**: Internal DNS management to Grafana
- **VPC & Networking**: Isolated network infrastructure

## Project Structure
```
test-load/
├── account.hcl # Account-level configurations
└── us-east-1/
├── codepipeline/ # CI/CD pipeline configuration
├── ec2/ # EC2 instance configuration
├── load-balancer/ # ALB configuration
├── network-core/ # VPC and network components
├── route53/ # DNS configuration
├── s3/ # S3 bucket for artifacts
├── secrets-manager/ # AWS Secrets Manager config
└── security-groups/ # Security group definitions
```

## Prerequisites
- AWS Account
- Terraform >= 1.0
- Terragrunt
- AWS CLI configured
- Git

## Components Detail

### CodePipeline Configuration
- Located in `/codepipeline/load-test/`
- Manages the automated testing pipeline
- Includes:
  - Build configuration
  - IAM roles and permissions
  - Pipeline stages definition

### EC2 Infrastructure
- Located in `/ec2/`
- Manages compute resources
- Includes:
  - Instance configuration
  - SSH key management
  - Output definitions

### Load Balancer
- Located in `/load-balancer/`
- Application Load Balancer configuration
- Target group definitions
- Health check settings

### Network Core
- Located in `/network-core/`
- VPC configuration
- Subnet management
- Network ACLs

### Security
- Security Groups (`/security-groups/`)
- Secrets Manager (`/secrets-manager/`)
- IAM roles and policies

## Deployment

### Initial Setup
1. Configure AWS credentials:
```bash
aws configure
```
2. Initialize Terragrunt:

```
cd test-load/us-east-1/<component>
terragrunt init
```

### Deploy Infrastructure
Deploy components in the following order:

1. Network Core:
```
cd network-core
terragrunt apply
```
2. Security Groups:

```
cd network-core
terragrunt apply
```
3. EC2 Instances:
```
cd ../ec2
terragrunt apply
```
4. Continue with remaining components
# Load Testing Pipeline
## Pipeline Stages
1. Source: Retrieves k6 test scripts

2. Build: Prepares test environment

3. Test: Executes k6 load tests

4. Results: Stores metrics in InfluxDB

### Monitoring
Access Grafana dashboard from `Load Balancer URL` for real-time metrics

View test results and performance data

Monitor system resources

### Configuration
Isn't necessary to setup InfluxDB and Grafana. including the dashboard and data source connection, this IaC setup all automatically.

### Environments

The environments is load from `Secrets Manager` in `secret/k6-dev-test-load`, you can add more environments in secrets-manager/terragrunt.hcl. 

### K6 Test Configuration
Test script location

Performance thresholds

Load patterns

### Security Considerations
VPC isolation

Security group rules

IAM least privilege access

Secrets management

Private subnet placement

### Maintenance
####  Backup and Recovery
- InfluxDB data backup

- Grafana dashboard export

- Pipeline configuration backup

#### Updates
- Regular security patches

- Component version updates

- Infrastructure maintenance

### Troubleshooting
#### Common Issues
1. Pipeline Failures

    - Check CodePipeline logs

    - Verify IAM permissions

    - Review k6 script syntax

2. Monitoring Issues

- Verify InfluxDB connectivity

- Check Grafana data source

- Validate metrics flow

3. Connect to Instances:
    - In ec2 is create a key pair k6-test-load-key.pem, you can use to access the instances
    - Load the key at the SSH agent
        ```
        ssh-add k6-test-load-key.pem
        ```

    - Connect to Grafana via bastion
        ```
        ssh -i k6-test-load-key.pem -J ec2-user@PUBLIC_IP_BASTION ubuntu@PRIVATE_IP_GRAFANA
        ```

## Contributing
1. Branch naming convention: feature/, bugfix/, hotfix/

2. Update documentation

3. Test changes locally

4. Submit pull request

## Resource Cleanup
To destroy resources:

```
cd test-load/us-east-1/<component>
terragrunt destroy
```

or

```
terragrunt destroy-all --terragrunt-ignore-external-dependencies
```