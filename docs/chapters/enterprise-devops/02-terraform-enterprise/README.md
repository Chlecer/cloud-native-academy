# 🏗️ Enterprise Terraform Patterns - Infrastructure as Code Mastery

## 🤔 What is Terraform?

**Terraform is like a blueprint system for cloud infrastructure.**

```
🖱️ TRADITIONAL WAY          📝 TERRAFORM WAY
┌─────────────────┐         ┌─────────────────┐
│ Click AWS       │         │ Write Code      │
│ Console         │   VS    │ Once            │
│ ↓               │         │ ↓               │
│ Manual Work     │         │ Automatic       │
│ ↓               │         │ ↓               │
│ Errors & Chaos  │         │ Perfect Copy    │
└─────────────────┘         └─────────────────┘
```

### 🏠 Real World Analogy
```
🔨 TRADITIONAL CONSTRUCTION    📋 TERRAFORM CONSTRUCTION
┌─────────────────────────┐   ┌─────────────────────────┐
│ Go to site daily        │   │ Create blueprint once   │
│ Tell workers what to do │   │ Any team can build      │
│ Hope they remember      │   │ Perfect every time      │
│ Different every time    │   │ Identical houses        │
└─────────────────────────┘   └─────────────────────────┘
```

### 🏢 Fortune 500 Success Stories
```
🎬 NETFLIX     📊 100,000+ AWS resources managed by code
🏠 AIRBNB      🚀 1,000+ environments deployed daily  
🚗 UBER        🌍 25+ regions provisioned consistently
🛒 SHOPIFY     💰 Black Friday traffic managed automatically
```

## 🌐 What is a VPC?

**VPC = Your private floor in the AWS building**

```
        🌍 INTERNET
           |
    ┌─────────────────┐
    │  AWS BUILDING   │
    │                 │
    │ ┌─────────────┐ │ ← 🏢 Other companies
    │ │ YOUR FLOOR  │ │ ← 🎯 YOUR VPC
    │ │             │ │
    │ │ 🌐📱💻      │ │ ← 🔓 Public rooms (web servers)
    │ │ 🔒🖥️⚙️      │ │ ← 🔒 Private rooms (apps)
    │ │ 🔐💾🗄️      │ │ ← 🔐 Vault (databases)
    │ └─────────────┘ │
    └─────────────────┘
```

### 🏗️ VPC Components Visual
```
🏢 VPC              = Your private floor
🚪 Subnets          = Individual rooms
🚪 Internet Gateway = Main street entrance
🚪 NAT Gateway      = Secure back door
🗺️ Route Tables     = Direction signs
```

### 🎯 Why This Structure?
```
🌐 PUBLIC SUBNETS    🔒 PRIVATE SUBNETS    🔐 DATABASE SUBNETS
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ 🌍 Internet     │  │ 🛡️ Protected    │  │ 🔐 Ultra-secure │
│ 📱 Web servers  │  │ ⚙️ Applications  │  │ 💾 Databases    │
│ 🔓 Public access│  │ 🔒 No direct    │  │ 🔐 Apps only    │
│                 │  │    access       │  │                 │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

## 🧩 What are Terraform Modules?

**Modules = LEGO instruction manuals for infrastructure**

```
🧱 INDIVIDUAL PIECES        📦 LEGO MODULE
┌─────────────────────┐     ┌─────────────────────┐
│ 🔩 Screw by         │     │ 📋 Follow manual    │
│    screw            │ VS  │ 🏗️ Perfect result   │
│ 🔧 Bolt by bolt     │     │ ✅ Same every time  │
│ ❌ Different always │     │ 🚀 Super fast       │
└─────────────────────┘     └─────────────────────┘
```

### 🎯 Why Modules Are Amazing
```
✅ CONSISTENCY  = Same result everywhere
🚀 SPEED        = Don't reinvent the wheel  
🏆 QUALITY      = 1 tested vs 100 custom
👥 TEAMWORK     = Everyone uses same "LEGO sets"
```

### Enterprise Requirements
- **Multi-environment management** (dev/staging/prod)
- **Team collaboration** without conflicts
- **State management** at scale
- **Security** and compliance
- **Cost optimization** and governance

## 📁 Enterprise Terraform Structure

**This is how Fortune 500 companies organize Terraform code.** Think of this as organizing a massive construction company:

```
terraform/
├── environments/          # Different construction sites
│   ├── dev/               # Development site (testing)
│   │   ├── main.tf         # Main blueprint for this site
│   │   ├── variables.tf    # Customizable settings
│   │   ├── terraform.tfvars # Actual values for this site
│   │   └── backend.tf      # Where to save progress
│   ├── staging/           # Pre-production site
│   └── prod/              # Production site (real customers)
├── modules/              # Reusable LEGO instruction manuals
│   ├── vpc/               # Network foundation instructions
│   ├── ecs-cluster/       # Container platform instructions
│   ├── rds/               # Database instructions
│   ├── s3-bucket/         # File storage instructions
│   └── monitoring/        # Monitoring system instructions
├── shared/               # Common tools and data
│   ├── data-sources.tf    # Info about existing AWS resources
│   └── locals.tf          # Calculated values and shortcuts
└── scripts/              # Automation tools
    ├── deploy.ps1         # Automatic deployment script
    └── validate.ps1       # Quality verification script
```

### 🎯 Why This Structure?
```
📁 environments/  = 🏗️ Different construction sites
📁 modules/       = 🧩 Reusable LEGO manuals  
📁 shared/        = 🔧 Common tools and data
📁 scripts/       = 🤖 Automation robots
```

## 🧩 Enterprise Terraform Modules

### VPC Module - The Network Foundation

**The VPC module is like the electrical and plumbing blueprint of a building.** Before you can put in offices, meeting rooms, or equipment, you need the basic infrastructure.

#### Understanding IP Addresses and Networks

**Before we dive into code, you need to understand how network addresses work.**

##### What are these 10.0.0.0 addresses?

**They are private IP addresses - like internal phone extensions in a company.** Just like your company might use extensions 1001, 1002, 1003 internally, but the outside world calls the main number, private IPs work within your network but aren't directly accessible from the internet.

##### 🌍 The Three Private IP Ranges (RFC 1918)
```
🏢 BIG COMPANIES     🏬 MEDIUM COMPANIES    🏠 HOME NETWORKS
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ 10.0.0.0        │  │ 172.16.0.0      │  │ 192.168.0.0     │
│ to              │  │ to              │  │ to              │
│ 10.255.255.255  │  │ 172.31.255.255  │  │ 192.168.255.255 │
│                 │  │                 │  │                 │
│ 📊 16.7 million │  │ 📊 1 million    │  │ 📊 65,000       │
│    addresses    │  │    addresses    │  │    addresses    │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

**🎯 Why 10.0.0.0 Wins?**
```
🚀 HUGE SPACE     = Never run out of IPs
🧠 EASY MEMORY    = Simple to remember  
🏆 INDUSTRY STD   = Netflix, Google, Amazon use it
```

##### CIDR Notation - Why /8, /16, /24?

**Each number in the IP (like 10.0.1.5) takes 8 bits in the computer.**

**A complete IP has 32 bits total:**
```
10    .    0    .    1    .    5
8 bits + 8 bits + 8 bits + 8 bits = 32 bits total
```

**The number after the slash (/) tells how many bits stay fixed:**

**10.0.0.0/8** = First 8 bits fixed = 1st number fixed (10)
```
[10 - FIXED] . [0-255] . [0-255] . [0-255]
   8 bits      8 bits    8 bits    8 bits
```
- You can use: 10.0.0.1, 10.5.2.3, 10.255.255.254
- **Total:** 16.7 million addresses

**10.0.0.0/16** = First 16 bits fixed = 2 numbers fixed (10.0)
```
[10 - FIXED] . [0 - FIXED] . [0-255] . [0-255]
   8 bits      8 bits       8 bits    8 bits
   \_____ 16 bits fixed ____/
```
- You can use: 10.0.0.1, 10.0.5.2, 10.0.255.254
- **Total:** 65,536 addresses

**10.0.1.0/24** = First 24 bits fixed = 3 numbers fixed (10.0.1)
```
[10 - FIXED] . [0 - FIXED] . [1 - FIXED] . [0-255]
   8 bits      8 bits       8 bits      8 bits
   \_________ 24 bits fixed __________/
```
- You can use: 10.0.1.1, 10.0.1.2, 10.0.1.254
- **Total:** 256 addresses

**🧮 Now it makes sense:**
```
/8  = 8 bits fixed  = 1 number fixed  = 🐋 HUGE
/16 = 16 bits fixed = 2 numbers fixed = 🦏 BIG  
/24 = 24 bits fixed = 3 numbers fixed = 🐰 SMALL

📐 FORMULA: bits ÷ 8 = fixed numbers
```

##### How We Divide the Network (Now That You Understand Bits)

**We start with 10.0.0.0/16 and create smaller pieces:**

```
ENTIRE VPC: 10.0.0.0/16 (65,536 addresses available)

┌─ Public ──────────────────────────────────────┐
│ 10.0.1.0/24 → 10.0.1.1 to 10.0.1.254        │ (256 addresses)
│ 10.0.2.0/24 → 10.0.2.1 to 10.0.2.254        │ (256 addresses)
└───────────────────────────────────────────────┘

┌─ Private ─────────────────────────────────────┐
│ 10.0.11.0/24 → 10.0.11.1 to 10.0.11.254     │ (256 addresses)
│ 10.0.12.0/24 → 10.0.12.1 to 10.0.12.254     │ (256 addresses)
└───────────────────────────────────────────────┘

┌─ Database ────────────────────────────────────┐
│ 10.0.21.0/24 → 10.0.21.1 to 10.0.21.254     │ (256 addresses)
│ 10.0.22.0/24 → 10.0.22.1 to 10.0.22.254     │ (256 addresses)
└───────────────────────────────────────────────┘
```

**Number logic:**
- **10.0.1.x, 10.0.2.x** = Public (low numbers)
- **10.0.11.x, 10.0.12.x** = Private (middle numbers)
- **10.0.21.x, 10.0.22.x** = Databases (high numbers)
- **Empty spaces** = For future growth

#### What This Module Creates
1. **VPC** - Your network space (10.0.0.0/16 = 65,536 addresses)
2. **Public Subnets** - Internet accessible (10.0.1.0/24 = 256 addresses each)
3. **Private Subnets** - Protected (10.0.11.0/24 = 256 addresses each)
4. **Database Subnets** - Ultra-secure (10.0.21.0/24 = 256 addresses each)
5. **Internet Gateway** - Main internet door
6. **NAT Gateways** - Secure exits for private resources
7. **Route Tables** - Traffic routing rules



#### How Terraform Creates the Network (Step-by-Step Visual)

**🎯 GOAL:** Create a network with automatically organized subnets

**📋 STEP 1: Define what we want**
```
🏢 Main VPC: 10.0.0.0/16 (65,536 addresses)
🌍 AWS Regions: eu-west-1a, eu-west-1b, eu-west-1c
📊 How many zones: 3
```

**🧮 STEP 2: Terraform calculates IPs automatically**
```
For each zone (1, 2, 3), create:

🌐 PUBLIC:
   Zone 1 → 10.0.1.0/24  (10.0.1.1 to 10.0.1.254)
   Zone 2 → 10.0.2.0/24  (10.0.2.1 to 10.0.2.254) 
   Zone 3 → 10.0.3.0/24  (10.0.3.1 to 10.0.3.254)

🔒 PRIVATE:
   Zone 1 → 10.0.11.0/24 (10.0.11.1 to 10.0.11.254)
   Zone 2 → 10.0.12.0/24 (10.0.12.1 to 10.0.12.254)
   Zone 3 → 10.0.13.0/24 (10.0.13.1 to 10.0.13.254)

💾 DATABASE:
   Zone 1 → 10.0.21.0/24 (10.0.21.1 to 10.0.21.254)
   Zone 2 → 10.0.22.0/24 (10.0.22.1 to 10.0.22.254)
   Zone 3 → 10.0.23.0/24 (10.0.23.1 to 10.0.23.254)
```

**🏗️ STEP 3: Terraform builds everything**
```
1️⃣ Creates the VPC (10.0.0.0/16)
2️⃣ Creates 9 subnets (3 public + 3 private + 3 database)
3️⃣ Creates Internet Gateway (internet door)
4️⃣ Creates 3 NAT Gateways (secure exits)
5️⃣ Creates Route Tables (traffic rules)
6️⃣ Connects everything together
```

**🎉 FINAL RESULT:**
```
        🌐 INTERNET
           |
    [Internet Gateway]
           |
    ┌─────────────────┐
    │   VPC 10.0.0.0/16   │
    │                 │
    │ 🌍 PUBLIC      │ 🔒 PRIVATE     │ 💾 DATABASES
    │ 10.0.1.0/24     │ 10.0.11.0/24   │ 10.0.21.0/24
    │ 10.0.2.0/24     │ 10.0.12.0/24   │ 10.0.22.0/24
    │ 10.0.3.0/24     │ 10.0.13.0/24   │ 10.0.23.0/24
    └─────────────────┘
```

**💡 THE MAGIC:** Terraform does all this automatically with just a few lines of code!

#### Simplified Terraform Code

```hcl
# 1️⃣ Create the main VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # Our network space
  
  tags = {
    Name = "my-vpc"
  }
}

# 2️⃣ Create public subnets (one per zone)
resource "aws_subnet" "public" {
  count = 3  # Create 3 subnets
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"  # 10.0.1.0, 10.0.2.0, 10.0.3.0
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "public-${count.index + 1}"
  }
}

# 3️⃣ Create private subnets (one per zone)
resource "aws_subnet" "private" {
  count = 3  # Create 3 subnets
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 11}.0/24"  # 10.0.11.0, 10.0.12.0, 10.0.13.0
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "private-${count.index + 1}"
  }
}
```

**🔥 THAT'S IT!** With this simple code, Terraform creates the entire network infrastructure!
          # IP range for your network (e.g., 10.0.0.0/16)
  enable_dns_hostnames = true                  # Allow resources to have DNS names
  enable_dns_support   = true                  # Enable DNS resolution

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc"            # Name like "myapp-prod-vpc"
  })
}

# Internet Gateway (the main door to the internet)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id                     # Attach to our VPC

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-igw"            # Name like "myapp-prod-igw"
  })
}

# Public Subnets (accessible from internet - for load balancers, web servers)
resource "aws_subnet" "public" {
  count = var.az_count                         # Create one per availability zone

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnets[count.index]      # Use calculated IP ranges
  availability_zone       = local.availability_zones[count.index]  # Spread across zones
  map_public_ip_on_launch = true                                   # Auto-assign public IPs

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-${count.index + 1}"         # "myapp-prod-public-1"
    Type = "public"
  })
}

# Private Subnets (protected from direct internet access - for applications)
resource "aws_subnet" "private" {
  count = var.az_count                         # Create one per availability zone

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnets[count.index]           # Use calculated IP ranges
  availability_zone = local.availability_zones[count.index]        # Spread across zones

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-${count.index + 1}"        # "myapp-prod-private-1"
    Type = "private"
  })
}

# Database Subnets (ultra-secure - only for databases)
resource "aws_subnet" "database" {
  count = var.az_count                         # Create one per availability zone

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.database_subnets[count.index]          # Use calculated IP ranges
  availability_zone = local.availability_zones[count.index]        # Spread across zones

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-database-${count.index + 1}"       # "myapp-prod-database-1"
    Type = "database"
  })
}

# NAT Gateways (secure exits for private resources to reach internet)
# First, create static IP addresses for NAT Gateways
resource "aws_eip" "nat" {
  count = var.az_count                         # One per availability zone for high availability

  domain = "vpc"                              # This IP belongs to our VPC
  depends_on = [aws_internet_gateway.main]    # Wait for internet gateway first

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"        # "myapp-prod-nat-eip-1"
  })
}

# Create NAT Gateways (allow private resources to reach internet securely)
resource "aws_nat_gateway" "main" {
  count = var.az_count                         # One per availability zone

  allocation_id = aws_eip.nat[count.index].id # Use the static IP we created
  subnet_id     = aws_subnet.public[count.index].id # Place in public subnet

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-${count.index + 1}"           # "myapp-prod-nat-1"
  })

  depends_on = [aws_internet_gateway.main]    # Wait for internet gateway first
}

# Route Tables (traffic direction rules)
# Public Route Table (directs traffic to internet gateway)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                # All internet traffic (0.0.0.0/0 means "everything")
    gateway_id = aws_internet_gateway.main.id # Send it through internet gateway
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-rt"    # "myapp-prod-public-rt"
  })
}

# Private Route Tables (directs traffic through NAT gateways)
resource "aws_route_table" "private" {
  count = var.az_count                       # One per availability zone

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"            # All internet traffic
    nat_gateway_id = aws_nat_gateway.main[count.index].id # Send through NAT gateway
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-rt-${count.index + 1}"     # "myapp-prod-private-rt-1"
  })
}

# Route Table Associations (connect subnets to their routing rules)
# Connect public subnets to public route table
resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id    # This public subnet
  route_table_id = aws_route_table.public.id            # Uses public routing rules
}

# Connect private subnets to their respective private route tables
resource "aws_route_table_association" "private" {
  count = var.az_count

  subnet_id      = aws_subnet.private[count.index].id   # This private subnet
  route_table_id = aws_route_table.private[count.index].id # Uses its zone's NAT gateway
}
```

```hcl
# modules/vpc/variables.tf
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones"
  type        = number
  default     = 2
  
  validation {
    condition     = var.az_count >= 2 && var.az_count <= 4
    error_message = "AZ count must be between 2 and 4 for enterprise deployments."
  }
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
```

```hcl
# modules/vpc/outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "nat_gateway_ips" {
  description = "Public IPs of NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}
```

### ECS Cluster Module (Production-Ready)

```hcl
# modules/ecs-cluster/main.tf
# ECS Cluster with Container Insights
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = var.kms_key_id
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_exec.name
      }
    }
  }

  tags = var.common_tags
}

# Capacity Provider for cost optimization
resource "aws_ecs_capacity_provider" "fargate" {
  name = "${var.cluster_name}-fargate"

  fargate_capacity_provider {
    fargate_base = var.fargate_base_capacity
    fargate_weight = var.fargate_weight
  }

  tags = var.common_tags
}

resource "aws_ecs_capacity_provider" "fargate_spot" {
  name = "${var.cluster_name}-fargate-spot"

  fargate_capacity_provider {
    fargate_base = var.fargate_spot_base_capacity
    fargate_weight = var.fargate_spot_weight
  }

  tags = var.common_tags
}

# Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [
    aws_ecs_capacity_provider.fargate.name,
    aws_ecs_capacity_provider.fargate_spot.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.fargate.name
    weight           = var.fargate_weight
    base            = var.fargate_base_capacity
  }

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.fargate_spot.name
    weight           = var.fargate_spot_weight
    base            = var.fargate_spot_base_capacity
  }
}

# CloudWatch Log Group for ECS Exec
resource "aws_cloudwatch_log_group" "ecs_exec" {
  name              = "/aws/ecs/exec/${var.cluster_name}"
  retention_in_days = var.log_retention_days

  tags = var.common_tags
}

# Service Discovery Namespace
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = var.service_discovery_namespace
  description = "Service discovery namespace for ${var.cluster_name}"
  vpc         = var.vpc_id

  tags = var.common_tags
}
```

```hcl
# modules/ecs-cluster/variables.tf
variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where cluster will be created"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
}

variable "service_discovery_namespace" {
  description = "Service discovery namespace"
  type        = string
  default     = "local"
}

variable "fargate_base_capacity" {
  description = "Base capacity for Fargate"
  type        = number
  default     = 1
}

variable "fargate_weight" {
  description = "Weight for Fargate capacity provider"
  type        = number
  default     = 1
}

variable "fargate_spot_base_capacity" {
  description = "Base capacity for Fargate Spot"
  type        = number
  default     = 0
}

variable "fargate_spot_weight" {
  description = "Weight for Fargate Spot capacity provider"
  type        = number
  default     = 4
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
```

## 🌍 Multi-Environment Management

### Environment-Specific Configuration

```hcl
# environments/prod/main.tf
terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

# Local values for production
locals {
  environment = "prod"
  
  common_tags = {
    Environment   = local.environment
    Project      = var.project_name
    ManagedBy    = "terraform"
    Owner        = var.team_name
    CostCenter   = var.cost_center
    Compliance   = "required"
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  name_prefix = "${var.project_name}-${local.environment}"
  vpc_cidr    = var.vpc_cidr
  az_count    = var.availability_zone_count
  
  common_tags = local.common_tags
}

# ECS Cluster Module
module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  cluster_name                 = "${var.project_name}-${local.environment}"
  vpc_id                      = module.vpc.vpc_id
  kms_key_id                  = aws_kms_key.main.arn
  service_discovery_namespace = "${local.environment}.local"
  
  # Production-specific settings
  fargate_base_capacity      = 2
  fargate_weight            = 2
  fargate_spot_base_capacity = 1
  fargate_spot_weight       = 3
  log_retention_days        = 90
  
  common_tags = local.common_tags
}

# RDS Module for production
module "rds" {
  source = "../../modules/rds"

  identifier     = "${var.project_name}-${local.environment}"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  
  vpc_id               = module.vpc.vpc_id
  subnet_ids          = module.vpc.database_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  # Production-specific settings
  allocated_storage     = 100
  max_allocated_storage = 1000
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  multi_az              = true
  deletion_protection   = true
  
  common_tags = local.common_tags
}

# KMS Key for encryption
resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.project_name} ${local.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.common_tags
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${local.environment}"
  target_key_id = aws_kms_key.main.key_id
}
```

```hcl
# environments/prod/variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "team_name" {
  description = "Name of the team"
  type        = string
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_count" {
  description = "Number of availability zones"
  type        = number
  default     = 3
}

variable "db_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "15.4"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.r6g.large"
}
```

```hcl
# environments/prod/terraform.tfvars
project_name = "enterprise-app"
team_name    = "platform-team"
cost_center  = "engineering"

vpc_cidr                = "10.0.0.0/16"
availability_zone_count = 3

db_engine_version = "15.4"
db_instance_class = "db.r6g.large"
```

```hcl
# environments/prod/backend.tf
terraform {
  backend "s3" {
    bucket         = "enterprise-terraform-state-prod"
    key            = "infrastructure/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-prod"
    
    # Workspace isolation
    workspace_key_prefix = "workspaces"
  }
}
```

## 🔒 Enterprise State Management

### Remote State with Locking

```hcl
# shared/state-backend/main.tf
# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  for_each = toset(var.environments)
  
  bucket = "${var.project_name}-terraform-state-${each.key}"

  tags = {
    Name        = "Terraform State - ${each.key}"
    Environment = each.key
    Purpose     = "terraform-state"
  }
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  for_each = aws_s3_bucket.terraform_state
  
  bucket = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  for_each = aws_s3_bucket.terraform_state

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  for_each = aws_s3_bucket.terraform_state

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  for_each = toset(var.environments)
  
  name           = "terraform-state-lock-${each.key}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock - ${each.key}"
    Environment = each.key
    Purpose     = "terraform-state-lock"
  }
}
```

## 🚀 Enterprise Deployment Scripts

### PowerShell Deployment Automation

```powershell
# scripts/deploy.ps1
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [switch]$Plan,
    
    [Parameter(Mandatory=$false)]
    [switch]$Apply,
    
    [Parameter(Mandatory=$false)]
    [switch]$Destroy,
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoApprove
)

# Set error handling
$ErrorActionPreference = "Stop"

# Configuration
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$EnvironmentPath = Join-Path $ProjectRoot "environments\$Environment"
$LogPath = Join-Path $ProjectRoot "logs"

# Ensure log directory exists
if (!(Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath -Force
}

$LogFile = Join-Path $LogPath "deploy-$Environment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    Add-Content -Path $LogFile -Value $LogMessage
}

function Test-TerraformVersion {
    try {
        $Version = terraform version -json | ConvertFrom-Json
        $CurrentVersion = [Version]$Version.terraform_version
        $RequiredVersion = [Version]"1.5.0"
        
        if ($CurrentVersion -lt $RequiredVersion) {
            throw "Terraform version $CurrentVersion is below required version $RequiredVersion"
        }
        
        Write-Log "Terraform version $CurrentVersion is compatible"
        return $true
    }
    catch {
        Write-Log "Error checking Terraform version: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Initialize-Terraform {
    Write-Log "Initializing Terraform for $Environment environment"
    
    Push-Location $EnvironmentPath
    try {
        # Initialize with backend configuration
        terraform init -backend-config="bucket=enterprise-terraform-state-$Environment" `
                      -backend-config="key=infrastructure/terraform.tfstate" `
                      -backend-config="region=eu-west-1" `
                      -backend-config="dynamodb_table=terraform-state-lock-$Environment"
        
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform init failed"
        }
        
        Write-Log "Terraform initialized successfully"
    }
    finally {
        Pop-Location
    }
}

function Invoke-TerraformValidate {
    Write-Log "Validating Terraform configuration"
    
    Push-Location $EnvironmentPath
    try {
        terraform validate
        
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform validation failed"
        }
        
        Write-Log "Terraform configuration is valid"
    }
    finally {
        Pop-Location
    }
}

function Invoke-TerraformPlan {
    Write-Log "Creating Terraform plan for $Environment"
    
    Push-Location $EnvironmentPath
    try {
        $PlanFile = "terraform-$Environment.tfplan"
        
        terraform plan -var-file="terraform.tfvars" -out=$PlanFile
        
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform plan failed"
        }
        
        Write-Log "Terraform plan created successfully: $PlanFile"
        return $PlanFile
    }
    finally {
        Pop-Location
    }
}

function Invoke-TerraformApply {
    param([string]$PlanFile)
    
    Write-Log "Applying Terraform plan for $Environment"
    
    Push-Location $EnvironmentPath
    try {
        if ($AutoApprove) {
            terraform apply -auto-approve $PlanFile
        } else {
            terraform apply $PlanFile
        }
        
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform apply failed"
        }
        
        Write-Log "Terraform apply completed successfully"
    }
    finally {
        Pop-Location
    }
}

function Invoke-TerraformDestroy {
    Write-Log "Destroying Terraform infrastructure for $Environment"
    
    if ($Environment -eq "prod") {
        Write-Log "Production environment destruction requires manual confirmation" "WARNING"
        $Confirmation = Read-Host "Type 'DESTROY PRODUCTION' to confirm"
        if ($Confirmation -ne "DESTROY PRODUCTION") {
            Write-Log "Destruction cancelled" "WARNING"
            return
        }
    }
    
    Push-Location $EnvironmentPath
    try {
        if ($AutoApprove) {
            terraform destroy -var-file="terraform.tfvars" -auto-approve
        } else {
            terraform destroy -var-file="terraform.tfvars"
        }
        
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform destroy failed"
        }
        
        Write-Log "Terraform destroy completed successfully"
    }
    finally {
        Pop-Location
    }
}

# Main execution
try {
    Write-Log "Starting Terraform deployment for $Environment environment"
    
    # Pre-flight checks
    if (!(Test-Path $EnvironmentPath)) {
        throw "Environment path not found: $EnvironmentPath"
    }
    
    if (!(Test-TerraformVersion)) {
        throw "Terraform version check failed"
    }
    
    # Initialize Terraform
    Initialize-Terraform
    
    # Validate configuration
    Invoke-TerraformValidate
    
    # Execute requested action
    if ($Plan -or $Apply) {
        $PlanFile = Invoke-TerraformPlan
        
        if ($Apply) {
            Invoke-TerraformApply -PlanFile $PlanFile
        }
    }
    
    if ($Destroy) {
        Invoke-TerraformDestroy
    }
    
    Write-Log "Deployment completed successfully"
}
catch {
    Write-Log "Deployment failed: $($_.Exception.Message)" "ERROR"
    exit 1
}
```

### Validation Script

```powershell
# scripts/validate.ps1
param(
    [Parameter(Mandatory=$false)]
    [string]$Environment = "all"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

function Test-TerraformFiles {
    param([string]$Path)
    
    Write-Host "🔍 Validating Terraform files in: $Path" -ForegroundColor Yellow
    
    Push-Location $Path
    try {
        # Format check
        terraform fmt -check -recursive
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Terraform formatting issues found" -ForegroundColor Red
            return $false
        }
        
        # Validation
        terraform init -backend=false
        terraform validate
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Terraform validation failed" -ForegroundColor Red
            return $false
        }
        
        Write-Host "✅ Terraform files are valid" -ForegroundColor Green
        return $true
    }
    finally {
        Pop-Location
    }
}

function Test-SecurityCompliance {
    param([string]$Path)
    
    Write-Host "🛡️ Running security compliance checks" -ForegroundColor Yellow
    
    # Check for hardcoded secrets
    $SecretPatterns = @(
        "password\s*=\s*['\"][^'\"]+['\"]",
        "secret\s*=\s*['\"][^'\"]+['\"]",
        "token\s*=\s*['\"][^'\"]+['\"]",
        "key\s*=\s*['\"][^'\"]+['\"]"
    )
    
    $Issues = @()
    Get-ChildItem -Path $Path -Recurse -Include "*.tf", "*.tfvars" | ForEach-Object {
        $Content = Get-Content $_.FullName -Raw
        foreach ($Pattern in $SecretPatterns) {
            if ($Content -match $Pattern) {
                $Issues += "Potential hardcoded secret in: $($_.FullName)"
            }
        }
    }
    
    if ($Issues.Count -gt 0) {
        Write-Host "❌ Security issues found:" -ForegroundColor Red
        $Issues | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        return $false
    }
    
    Write-Host "✅ No security issues found" -ForegroundColor Green
    return $true
}

function Test-CostOptimization {
    param([string]$Path)
    
    Write-Host "💰 Checking cost optimization" -ForegroundColor Yellow
    
    $CostIssues = @()
    
    # Check for expensive instance types in non-prod
    if ($Path -notmatch "prod") {
        Get-ChildItem -Path $Path -Recurse -Include "*.tf" | ForEach-Object {
            $Content = Get-Content $_.FullName -Raw
            if ($Content -match 'instance_type\s*=\s*"[^"]*\.large"' -or 
                $Content -match 'instance_type\s*=\s*"[^"]*\.xlarge"') {
                $CostIssues += "Large instance type in non-prod environment: $($_.FullName)"
            }
        }
    }
    
    if ($CostIssues.Count -gt 0) {
        Write-Host "⚠️ Cost optimization suggestions:" -ForegroundColor Yellow
        $CostIssues | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    } else {
        Write-Host "✅ Cost optimization looks good" -ForegroundColor Green
    }
    
    return $true
}

# Main validation
try {
    Write-Host "🚀 Starting Terraform validation" -ForegroundColor Cyan
    
    $Environments = if ($Environment -eq "all") {
        @("dev", "staging", "prod")
    } else {
        @($Environment)
    }
    
    $AllValid = $true
    
    foreach ($Env in $Environments) {
        $EnvPath = Join-Path $ProjectRoot "environments\$Env"
        
        if (Test-Path $EnvPath) {
            Write-Host "`n📁 Validating $Env environment" -ForegroundColor Cyan
            
            $Valid = Test-TerraformFiles -Path $EnvPath
            $Secure = Test-SecurityCompliance -Path $EnvPath
            $Optimized = Test-CostOptimization -Path $EnvPath
            
            if (!$Valid -or !$Secure) {
                $AllValid = $false
            }
        } else {
            Write-Host "⚠️ Environment path not found: $EnvPath" -ForegroundColor Yellow
        }
    }
    
    # Validate modules
    $ModulesPath = Join-Path $ProjectRoot "modules"
    if (Test-Path $ModulesPath) {
        Write-Host "`n📦 Validating modules" -ForegroundColor Cyan
        Get-ChildItem -Path $ModulesPath -Directory | ForEach-Object {
            $ModuleValid = Test-TerraformFiles -Path $_.FullName
            $ModuleSecure = Test-SecurityCompliance -Path $_.FullName
            
            if (!$ModuleValid -or !$ModuleSecure) {
                $AllValid = $false
            }
        }
    }
    
    if ($AllValid) {
        Write-Host "`n🎉 All validations passed!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "`n❌ Validation failed!" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "💥 Validation error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

## 🎓 What You Mastered

### Enterprise Terraform Skills
- ✅ **Modular architecture** - Reusable, maintainable infrastructure
- ✅ **Multi-environment management** - Dev/staging/prod isolation
- ✅ **Remote state management** - Team collaboration without conflicts
- ✅ **Security best practices** - Encryption, access control, compliance
- ✅ **Cost optimization** - Spot instances, right-sizing, governance
- ✅ **Automation scripts** - PowerShell deployment and validation

### Industry Best Practices
- 🏗️ **Module-first approach** - Like Netflix and Airbnb use
- 🔒 **State security** - S3 + DynamoDB locking
- 🌍 **Environment isolation** - Separate state per environment
- 📊 **Cost governance** - Automated cost optimization checks
- 🛡️ **Security scanning** - Automated compliance validation
- 🚀 **CI/CD integration** - Ready for GitLab pipelines

### Career Impact
- 💼 **Infrastructure Engineer:** $100k-$160k
- 💼 **DevOps Architect:** $120k-$180k
- 💼 **Platform Engineer:** $110k-$170k

---

**Next:** [GitLab CI/CD Mastery](../03-gitlab-cicd/) - Pipeline automation that scales!