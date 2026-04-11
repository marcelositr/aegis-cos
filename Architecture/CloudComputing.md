---
title: Cloud Computing
title_pt: Computação em Nuvem
layer: architecture
type: concept
priority: medium
version: 1.0.0
tags:
  - Architecture
  - Cloud
  - Computing
description: Cloud computing concepts and services.
description_pt: Conceitos e serviços de computação em nuvem.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Cloud Computing

## Description

Cloud computing delivers computing services over the internet, including servers, storage, databases, networking, and software. Major providers include AWS, Azure, and GCP.

Service Models:
- **IaaS** - Infrastructure as a Service (virtual machines, networking)
- **PaaS** - Platform as a Service (runtime, middleware, OS)
- **SaaS** - Software as a Service (complete applications)

Deployment Models:
- **Public Cloud** - Owned and operated by provider
- **Private Cloud** - For single organization
- **Hybrid Cloud** - Mix of public and private
- **Multi-Cloud** - Using multiple providers

## Purpose

**When cloud computing is valuable:**
- When you need scalability
- When you want to reduce infrastructure management
- For variable workloads
- For global availability

**When to consider alternatives:**
- For strict data residency requirements
- When latency is critical
- For predictable, steady workloads

## Rules

1. **Use managed services** - Less operational overhead
2. **Design for failure** - Assume components will fail
3. **Implement cost monitoring** - Track spending
4. **Use infrastructure as code** - Reproducible environments
5. **Plan for exit** - Avoid vendor lock-in

## Examples

### AWS Service Categories

```python
# Example: Using AWS services
import boto3

# Compute
ec2 = boto3.resource('ec2')
lambda_client = boto3.client('lambda')

# Storage
s3 = boto3.resource('s3')

# Database
dynamodb = boto3.resource('dynamodb')
rds = boto3.client('rds')

# Networking
vpc = boto3.resource('ec2').Vpc('vpc-id')
```

### Azure Resource Groups

```yaml
# Azure resource group
resourceGroup 'rg-production' {
  location: 'eastus'
  
  resource 'storage-account' {
    type: 'Microsoft.Storage/storageAccounts'
    sku: 'Standard_LRS'
  }
  
  resource 'app-service' {
    type: 'Microsoft.Web/sites'
    kind: 'web'
  }
}
```

### GCP Project Structure

```
my-project/
├── compute/
│   ├── main.tf
│   ├── variables.tf
│   └── instance.tf
├── networking/
│   ├── vpc.tf
│   ├── firewall.tf
│   └── routes.tf
├── storage/
│   ├── bucket.tf
│   └── lifecycle.tf
└── database/
    ├── cloudsql.tf
    └── backup.tf
```

## Anti-Patterns

### 1. Not Using Managed Services

**Bad:**
- Managing your own databases
- Running your own message queue

**Solution:**
- Use RDS, DynamoDB, SQS, etc.

### 2. Ignoring Cost

**Bad:**
- Leaving resources running
- Using expensive instance types

**Solution:**
- Use cost explorer
- Set budgets and alerts
- Use spot instances for batch jobs

### 3. No Exit Strategy

**Bad:**
- Using proprietary services only
- No containerization

**Solution:**
- Use open standards
- Containerize applications

## Best Practices

### Cost Optimization

```python
# Right-sizing instances
import boto3

ce = boto3.client('ce')

# Get cost and usage
response = ce.get_cost_and_usage(
    TimePeriod={'Start': '2024-01-01', 'End': '2024-01-31'},
    Granularity='DAILY',
    Metrics=['UnblendedCost'],
    GroupBy=[{'Type': 'DIMENSION', 'Key': 'INSTANCE_TYPE'}]
)
```

### Security Best Practices

```yaml
# Enable encryption everywhere
storage:
  encrypted: true
  versioning: true
  
# Use IAM roles
iam:
  - role: app-role
    policies:
      - s3-read-only
      
# Network isolation
vpc:
  private_subnets: true
  nat_gateway: true
```

### Architecture Patterns

```yaml
# Multi-region deployment
region:
  primary: us-east-1
  secondary: us-west-2
  
failover:
  dns: Route53
  database: Aurora Global
  cdn: CloudFront
```

## Technology Stack

| Provider | Services |
|----------|----------|
| AWS | EC2, S3, RDS, Lambda, EKS |
| Azure | VMs, Blob, SQL, Functions, AKS |
| GCP | GCE, Cloud Storage, Cloud SQL, Cloud Run |
| Oracle | OCI, OKE |

## Failure Modes

- **Uncontrolled cloud spending** → resources left running without monitoring → budget overruns → implement cost alerts, auto-shutdown policies, and regular resource audits
- **Vendor lock-in through proprietary services** → architecture depends on cloud-specific APIs → impossible to migrate without complete rewrite → abstract cloud services behind interfaces and prefer open standards
- **Misconfigured cloud storage exposing data** → S3 buckets or databases left publicly accessible → data breaches → enforce infrastructure-as-code with security scanning and least-privilege IAM
- **Single region dependency** → all services deployed in one availability zone → complete outage during regional failure → design multi-region architectures with automated failover
- **Over-provisioned resources** → using largest instance types for light workloads → paying for unused capacity → right-size instances based on metrics and use auto-scaling
- **Missing exit strategy** → no plan for cloud provider changes → forced migration under duress → maintain containerized deployments and document migration procedures
- **Shared responsibility model gaps** → assuming cloud provider handles all security → unpatched OS or misconfigured firewalls → clearly delineate security responsibilities and audit your portion regularly

## Related Topics

- [[Architecture MOC]]
- [[Serverless]]
- [[EdgeComputing]]
- [[Docker]]
- [[Kubernetes]]

## Key Takeaways

- Cloud computing delivers on-demand compute, storage, networking, and software services over the internet via IaaS, PaaS, and SaaS models
- Valuable for scalability, variable workloads, global availability, and reducing infrastructure management overhead
- Avoid for strict data residency requirements, latency-critical applications, or predictable steady workloads where on-prem is cheaper
- Tradeoff: operational simplicity and elasticity versus vendor lock-in risk, ongoing costs, and shared responsibility security gaps
- Main failure mode: uncontrolled spending from unmonitored resources combined with misconfigured storage exposing sensitive data
- Best practice: use managed services, implement cost monitoring with alerts, design for failure, use infrastructure as code, and plan exit strategies
- Related: serverless, edge computing, Docker, Kubernetes, infrastructure as code

## Additional Notes

**Major Providers:**
- AWS - Most services
- Azure - Microsoft ecosystem
- GCP - Data/ML focus

**Cost Management:**
- Use savings plans
- Spot instances for batch
- Reserved capacity for steady workloads

**Migration:**
- Assess existing applications
- Start with lift-and-shift
- Refactor over time