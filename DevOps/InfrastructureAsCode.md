---
title: Infrastructure as Code
title_pt: IaC (Infraestrutura como Código)
layer: devops
type: practice
priority: high
version: 1.0.0
tags:
  - DevOps
  - IaC
  - Infrastructure
  - Practice
description: Managing infrastructure through code rather than manual processes.
description_pt: Gerenciar infraestrutura através de código em vez de processos manuais.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Infrastructure as Code

## Description

Infrastructure as Code (IaC) is the practice of managing and provisioning infrastructure through code rather than manual processes. Instead of manually configuring servers, networks, and other infrastructure components, you define them in configuration files that can be versioned, tested, and automated.

IaC brings software engineering practices to infrastructure:
- **Version control** - Track changes to infrastructure
- **Code review** - Review infrastructure changes
- **Testing** - Validate infrastructure before deployment
- **Automation** - Reduce manual errors
- **Reproducibility** - Create consistent environments

Popular IaC tools include Terraform, Pulumi, CloudFormation, and Ansible. Each has different approaches:
- **Terraform/Pulumi** - Declarative, state-based
- **Ansible** - Procedural, agentless
- **CloudFormation** - Cloud-specific, declarative

IaC is fundamental to DevOps practices, enabling:
- Consistent environments
- Rapid provisioning
- Infrastructure scalability
- Disaster recovery

## Purpose

**When IaC is valuable:**
- For reproducible environments
- When managing multiple environments
- For disaster recovery
- In cloud migrations
- When team needs infrastructure automation

**When to avoid:**
- For very simple, static infrastructure
- When learning curve isn't worth it

## Rules

1. **Use version control** - Store IaC in git
2. **Use modules** - Reusable components
3. **Separate configs** - Environment-specific values
4. **Test infrastructure** - Validate before apply
5. **Use state management** - Track changes
6. **Enable drift detection** - Detect configuration changes
7. **Use secrets management** - Never commit secrets

## Examples

### Terraform

```hcl
# main.tf
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "production/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables
# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  
  name = "myapp-${var.environment}"
  cidr = "10.0.0.0/16"
  
  azs            = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = var.environment == "prod" ? false : true
  
  tags = {
    Environment = var.environment
  }
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0"
  
  cluster_name    = "myapp-${var.environment}"
  cluster_version = "1.28"
  
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.medium"]
  }
  
  eks_managed_node_groups = {
    primary = {
      name = "primary-node-group"
      
      instance_types = ["t3.medium"]
      
      capacity_type  = "ON_DEMAND"
      
      min_size     = 2
      max_size     = 10
      desired_size = 3
      
      labels = {
        Environment = var.environment
      }
    }
  }
  
  tags = {
    Environment = var.environment
  }
}

# RDS Database
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.0.0"
  
  identifier = "myapp-${var.environment}-postgres"
  
  engine               = "postgres"
  engine_version      = "15.3"
  family              = "postgres15"
  major_engine_version = "15"
  
  allocated_storage     = 20
  max_allocated_storage = 100
  
  instance_class    = var.environment == "prod" ? "db.r6g.large" : "db.t3.medium"
  multi_az          = var.environment == "prod"
  
  db_name  = "myapp"
  username = var.db_username
  password = var.db_password
  
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [module.vpc.default_security_group_id]
  
  backup_retention_period = var.environment == "prod" ? 30 : 7
  skip_final_snapshot     = var.environment != "prod"
  
  tags = {
    Environment = var.environment
  }
}

# Outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "rds_endpoint" {
  value     = module.rds.db_instance_endpoint
  sensitive = true
}
```

### Ansible Playbook

```yaml
# playbook.yml
---
- name: Web Server Setup
  hosts: webservers
  become: yes
  vars:
    http_port: 80
    https_port: 443
  
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        cache_valid_time: 3600
    
    - name: Install required packages
      apt:
        name:
          - nginx
          - python3-pip
          - git
        state: present
    
    - name: Create application user
      user:
        name: appuser
        comment: "Application User"
        shell: /bin/bash
        home: /opt/app
        create_home: yes
    
    - name: Clone application repository
      git:
        repo: https://github.com/example/app.git
        dest: /opt/app
        version: main
        force: yes
      become_user: appuser
    
    - name: Install Python dependencies
      pip:
        requirements: /opt/app/requirements.txt
        virtualenv: /opt/app/venv
      become_user: appuser
    
    - name: Configure nginx
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      notify: Reload nginx
    
    - name: Enable and start nginx
      service:
        name: nginx
        state: started
        enabled: yes
    
    - name: Configure firewall
      ufw:
        rule: allow
        port: "{{ item }}"
        proto: tcp
      loop:
        - "{{ http_port }}"
        - "{{ https_port }}"
        - 22

  handlers:
    - name: Reload nginx
      service:
        name: nginx
        state: reloaded
```

## Anti-Patterns

### 1. Not Using Modules

```hcl
# BAD - all in one file
resource "aws_vpc" "main" { ... }
resource "aws_subnet" "a" { ... }
resource "aws_subnet" "b" { ... }
resource "aws_instance" "web" { ... }

# GOOD - modular
module "vpc" { ... }
module "subnets" { ... }
module "instances" { ... }
```

### 2. Hardcoding Values

```hcl
# BAD
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  region        = "us-east-1"
}

# GOOD
variable "ami_id" { }
variable "instance_type" { }

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

### 3. Storing Secrets in Code

```hcl
# BAD
resource "aws_db_instance" "db" {
  password = "mysecretpassword"  # Never do this!
}

# GOOD - use secrets management
resource "aws_db_instance" "db" {
  password = var.db_password  # From variable or secret
}
```

## Best Practices

### Directory Structure

```
infrastructure/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eks/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── rds/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── shared/
    ├── backend.tf
    └── providers.tf
```

### Testing with Terratest

```go
// infrastructure_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformExample(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/simple",
        Vars: map[string]interface{}{
            "aws_region": "us-east-1",
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Verify VPC was created
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)
}
```

## Failure Modes

- **State file lost** (Terraform) → can't manage existing resources → backup state, use remote state storage
- **State file corrupted** → Terraform tries to recreate everything → lock state files, version state
- **Manual changes drift** → IaC doesn't match reality → next apply breaks things → drift detection, prevent manual changes
- **Destructive apply** → terraform destroy removes production → use workspaces, require confirmation, plan before apply
- **Secrets in state** → Terraform state contains passwords → encrypt state at rest, restrict access
- **Module version pinning missing** → module updates break infrastructure → pin module versions, test upgrades
- **Circular dependencies** → resource A needs B needs A → apply fails → redesign dependencies
- **Provider API rate limits** → too many resources → throttled → batch operations, use provider caching

## Technology Stack

| Tool | Type | Use Case |
|------|------|----------|
| Terraform | Declarative | Multi-cloud IaC |
| Pulumi | Programmatic | IaC with code |
| Ansible | Procedural | Configuration |
| CloudFormation | Declarative | AWS-specific |
| Azure ARM | Declarative | Azure-specific |

## Related Topics

- [[Kubernetes]]
- [[Docker]]
- [[GitOps]]
- [[CiCd]]
- [[Monitoring]]
- [[SecurityHeaders]]
- [[ContainerOrchestration]]
- [[Logging]]

## Additional Notes

**Terraform Commands:**
```bash
terraform init
terraform plan
terraform apply
terraform destroy
terraform validate
terraform fmt
```

**Best Practices:**
- Use modules for reusability
- Separate environments
- Store state remotely
- Use workspaces or directories
- Enable drift detection
- Test infrastructure changes