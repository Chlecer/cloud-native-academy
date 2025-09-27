# 🏗️ Infrastructure as Code

## 🎯 Objective
Build and manage infrastructure using code instead of manual processes.

> **"Infrastructure as Code is not just about automation, it's about reliability at scale."** - Kief Morris, ThoughtWorks

## 🌆 Why This Matters - Scale Without Chaos

### Companies Doing IaC Right

**🎬 Netflix** - Manages 100,000+ AWS instances with code
- **Strategy:** Spinnaker + Terraform + immutable infrastructure
- **Result:** Deploy 4,000+ times per day with 99.99% uptime¹
- **Secret:** Everything is code - no manual changes allowed

**📺 Spotify** - Runs 4,000+ microservices across multiple clouds
- **Challenge:** Consistent infrastructure across AWS, GCP, Azure
- **Solution:** Terraform modules + GitOps + automated testing
- **Impact:** 90% reduction in infrastructure provisioning time²

**🏦 Capital One** - Migrated entire bank to cloud using IaC
- **Scale:** 100+ applications, petabytes of data
- **Strategy:** Terraform + AWS + automated compliance
- **Result:** $2.6B in cloud savings, 50% faster deployments³

### The Cost of Manual Infrastructure
- **⏰ Time waste:** Manual provisioning takes 5-10x longer⁴
- **🐛 Error rate:** 67% of outages caused by manual changes⁵
- **💸 Downtime cost:** $5,600 per minute for manual recovery⁶
- **😱 Security risk:** 95% of cloud breaches due to misconfiguration⁷

*¹Netflix Tech Blog | ²Spotify Engineering | ³Capital One Tech Blog | ⁴HashiCorp State of Cloud Infrastructure | ⁵Puppet State of DevOps | ⁶Gartner Infrastructure Report | ⁷IBM Security Report*

## 🛠️ Terraform Fundamentals

### Basic Terraform Structure
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
}

provider "aws" {
  region = var.aws_region
}

# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
```

### VPC and Networking
```hcl
# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# Public subnets
resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
    Type = "public"
  }
}

# Private subnets
resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}-private-${count.index + 1}"
    Type = "private"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}
```

### EKS Cluster
```hcl
# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.environment}-cluster"
  role_arn = aws_iam_role.cluster.arn
  version  = "1.28"

  vpc_config {
    subnet_ids              = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  tags = {
    Name = "${var.environment}-eks-cluster"
  }
}

# Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.environment}-nodes"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_group_AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Name = "${var.environment}-eks-nodes"
  }
}
```

## 🔧 Terraform Best Practices

### State Management
```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Module Structure
```
modules/
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── eks/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── rds/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf

environments/
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── staging/
└── prod/
```

### Using Modules
```hcl
# environments/dev/main.tf
module "vpc" {
  source = "../../modules/vpc"
  
  environment = "dev"
  cidr_block  = "10.0.0.0/16"
}

module "eks" {
  source = "../../modules/eks"
  
  environment = "dev"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids
}
```

## 🚀 Deployment Pipeline

### GitHub Actions Workflow
```yaml
# .github/workflows/terraform.yml
name: Terraform

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.6.0
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
    
    - name: Terraform Init
      run: terraform init
      working-directory: ./environments/dev
    
    - name: Terraform Plan
      run: terraform plan -no-color
      working-directory: ./environments/dev
    
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main'
      run: terraform apply -auto-approve
      working-directory: ./environments/dev
```

### Validation and Testing
```bash
# Format check
terraform fmt -check -recursive

# Validation
terraform validate

# Security scanning with tfsec
tfsec .

# Cost estimation with infracost
infracost breakdown --path .
```

## 📊 Monitoring Infrastructure

### CloudWatch Alarms
```hcl
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EKS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EKS CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }
}
```

### Backup Strategy
```hcl
# EBS Snapshot Lifecycle
resource "aws_dlm_lifecycle_policy" "ebs_backup" {
  description        = "EBS snapshot lifecycle policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types   = ["VOLUME"]
    target_tags = {
      Environment = var.environment
    }

    schedule {
      name = "Daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["03:00"]
      }

      retain_rule {
        count = 7
      }

      copy_tags = true
    }
  }
}
```

## 🎯 Practical Exercise

### Deploy Complete Infrastructure
```bash
# 1. Initialize Terraform
cd environments/dev
terraform init

# 2. Plan deployment
terraform plan -var-file="terraform.tfvars"

# 3. Apply infrastructure
terraform apply -var-file="terraform.tfvars"

# 4. Verify deployment
kubectl get nodes
kubectl get pods --all-namespaces
```

## 🎓 What You Learned

### Technical Skills
- ✅ **Terraform mastery** - Industry-standard IaC tool (used by 76% of companies)⁸
- ✅ **Infrastructure modules** - Reusable components like Netflix uses
- ✅ **State management** - Team collaboration without conflicts
- ✅ **CI/CD integration** - Automated infrastructure deployment
- ✅ **Monitoring & backup** - Production-ready infrastructure
- ✅ **Security & cost optimization** - Enterprise-grade practices

### Career Impact (Infrastructure Market Data)
- 💼 **DevOps Engineer:** $95k-$160k (IaC skills required)⁹
- 💼 **Site Reliability Engineer:** $120k-$200k¹⁰
- 💼 **Cloud Architect:** $130k-$220k¹¹
- 💼 **Infrastructure Consultant:** $120-$250/hour¹²
- 💼 **Job demand:** 89% of companies actively hiring IaC skills¹³

*⁸HashiCorp User Survey | ⁹Stack Overflow Developer Survey | ¹⁰Levels.fyi SRE Data | ¹¹Glassdoor Cloud Architect | ¹²Upwork Infrastructure Rates | ¹³LinkedIn Skills Report*

### Industry Certifications This Prepares You For
- 🏅 **HashiCorp Certified: Terraform Associate** - Most valuable IaC cert
- 🏅 **AWS Certified Solutions Architect** - Cloud infrastructure design
- 🏅 **Google Cloud Professional Cloud Architect** - Multi-cloud expertise
- 🏅 **Azure Solutions Architect Expert** - Microsoft cloud mastery

> **IaC fact:** Companies using Infrastructure as Code deploy 208x more frequently and recover 2,604x faster from failures.¹⁴

---

## 📚 Sources & Further Reading

### Industry Reports & Research
- [HashiCorp State of Cloud Infrastructure 2023](https://www.hashicorp.com/state-of-the-cloud) - IaC adoption trends
- [Puppet State of DevOps Report 2023](https://puppet.com/resources/report/2023-state-of-devops-report/) - Infrastructure automation impact
- [DORA State of DevOps 2023](https://cloud.google.com/devops/state-of-devops) - Performance metrics
- [Gartner Infrastructure & Operations](https://www.gartner.com/en/information-technology/insights/infrastructure-operations) - Market analysis

### Company Engineering Blogs
- [Netflix Tech Blog - Infrastructure](https://netflixtechblog.com/tagged/infrastructure) - Large-scale IaC
- [Spotify Engineering - Platform](https://engineering.atspotify.com/category/platform/) - Multi-cloud infrastructure
- [Capital One Tech Blog](https://www.capitalone.com/tech/cloud/) - Banking-scale cloud migration
- [HashiCorp Learn](https://learn.hashicorp.com/terraform) - Official Terraform tutorials

### Tools & Documentation
- [Terraform Documentation](https://www.terraform.io/docs) - Official Terraform docs
- [AWS CloudFormation](https://aws.amazon.com/cloudformation/) - AWS native IaC
- [Azure Resource Manager](https://docs.microsoft.com/en-us/azure/azure-resource-manager/) - Azure IaC
- [Google Cloud Deployment Manager](https://cloud.google.com/deployment-manager) - GCP IaC

**Next:** [Monitoring & Observability](../02-monitoring-observability/) - See what's happening in your 100,000+ instances!