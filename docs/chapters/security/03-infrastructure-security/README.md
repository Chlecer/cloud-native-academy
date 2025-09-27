# 🏰 Infrastructure Security - The Foundation of Trust

## 🎯 Objective
Build infrastructure security that prevents the next SolarWinds or Colonial Pipeline attack.

> **"Security is not a product, but a process."** - Bruce Schneier, Cryptographer

## 🌟 Why This Matters - The $10 Trillion Problem

### Companies That Got Infrastructure Security Right

**🏦 JPMorgan Chase** - Spends $15B annually on cybersecurity
- **Challenge:** Protect $3.8 trillion in assets from nation-state attacks
- **Strategy:** Zero-trust architecture + micro-segmentation + secrets rotation
- **Result:** Blocked 45 billion cyberattacks in 2022¹
- **Learning:** Infrastructure security is business survival, not IT overhead

**☁️ Cloudflare** - Protects 25% of internet traffic
- **Scale:** Processes 32 million HTTP requests per second
- **Security:** Hardware security modules + automated certificate management
- **Impact:** Stopped largest DDoS attack in history (71 million requests/second)²
- **Secret:** Security automation at massive scale

**🎮 Sony PlayStation** - Learned from $171M breach in 2011
- **Transformation:** Complete infrastructure redesign after hack
- **Investment:** $2B in security over 5 years
- **Result:** Zero major breaches since 2011 redesign³
- **Lesson:** Sometimes you need to rebuild everything

### The Cost of Infrastructure Security Failures
- **💸 Average breach cost:** $4.45M per incident (IBM 2023)⁴
- **⏰ Detection time:** 277 days average to find breach⁵
- **🏢 Business impact:** 60% of small companies close within 6 months⁶
- **🌍 Global damage:** $10.5 trillion annually by 2025⁷
- **😱 Supply chain attacks:** 742% increase since 2019⁸

*¹JPMorgan Annual Report | ²Cloudflare Blog | ³Sony Security Report | ⁴IBM Cost of Data Breach | ⁵Ponemon Institute | ⁶National Cyber Security Alliance | ⁷Cybersecurity Ventures | ⁸Sonatype Supply Chain Report*

## 🔐 The SolarWinds Lesson - Why Secrets Management Matters

### What Happened (December 2020)
- **🎯 Target:** SolarWinds Orion software (used by 18,000+ companies)
- **💥 Impact:** Microsoft, FireEye, US Treasury, 9 federal agencies compromised
- **🕳️ Root cause:** Weak password "solarwinds123" exposed in GitHub
- **💰 Damage:** $90B+ in remediation costs across all victims⁹
- **⏰ Duration:** Attackers had access for 9 months undetected

### How Proper Secrets Management Would Have Prevented This
```
❌ What SolarWinds Did:
- Hardcoded passwords in source code
- Weak passwords ("solarwinds123")
- No secrets rotation
- No access monitoring

✅ What They Should Have Done:
- HashiCorp Vault for secrets management
- Automated secrets rotation
- Zero-trust network architecture
- Continuous security monitoring
```

*⁹Reuters SolarWinds Analysis*

## 🔐 Secrets Management - The Vault Approach

### Why HashiCorp Vault? (Used by 70% of Fortune 500)

**🏢 Companies using Vault:**
- **Netflix** - Manages 100,000+ secrets across microservices
- **Adobe** - Protects Creative Cloud user data
- **Samsung** - Secures mobile device manufacturing
- **Barclays** - Banking-grade secrets for financial services

**💡 Vault vs Alternatives:**
```
❌ Environment Variables:
- Visible in process lists
- Logged in CI/CD systems
- No rotation or audit trail

❌ Config Files:
- Stored in plain text
- Version controlled accidentally
- No access control

✅ HashiCorp Vault:
- Encrypted at rest and in transit
- Automatic rotation
- Detailed audit logs
- Fine-grained access control
```

### Production Vault Setup (Windows)
```powershell
# Install Vault on Windows
choco install vault

# Create Vault configuration
@"
storage "file" {
  path = "C:\vault\data"
}

listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = 1
}

ui = true
"@ | Out-File -FilePath "C:\vault\config.hcl"

# Start Vault server
vault server -config="C:\vault\config.hcl"

# Initialize Vault (run once)
vault operator init

# Unseal Vault (after each restart)
vault operator unseal <unseal-key-1>
vault operator unseal <unseal-key-2>
vault operator unseal <unseal-key-3>
```

### Real-World Secrets Management
```bash
# Store database credentials with metadata
vault kv put secret/production/database \
  username="prod_user" \
  password="$(openssl rand -base64 32)" \
  host="prod-db.company.com" \
  port="5432" \
  created_by="devops-team" \
  rotation_schedule="monthly"

# Store API keys with expiration
vault kv put secret/production/stripe \
  api_key="sk_live_..." \
  webhook_secret="whsec_..." \
  environment="production" \
  expires="2024-12-31"

# Retrieve secrets in application
vault kv get -field=password secret/production/database
```

### Kubernetes Secrets
```yaml
# Create secret from command line
kubectl create secret generic app-secrets \
  --from-literal=database-url="postgresql://user:pass@host:5432/db" \
  --from-literal=api-key="abc123xyz"

# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  database-url: cG9zdGdyZXNxbDovL3VzZXI6cGFzc0Bob3N0OjU0MzIvZGI=
  api-key: YWJjMTIzeHl6

---
# Use in deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp:latest
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-url
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: api-key
```

## 🌐 Network Security

### VPC Configuration
```hcl
# vpc.tf
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "secure-vpc"
  }
}

# Private subnets for databases
resource "aws_subnet" "private" {
  count = 2
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Public subnets for load balancers
resource "aws_subnet" "public" {
  count = 2
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}
```

### Security Groups
```hcl
# Web tier security group
resource "aws_security_group" "web" {
  name_prefix = "web-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database security group
resource "aws_security_group" "database" {
  name_prefix = "db-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
}
```

## 🔒 SSL/TLS Configuration

### Let's Encrypt with Cert-Manager
```yaml
# cert-manager installation
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# cluster-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx

---
# ingress with TLS
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

## 🔍 Security Scanning

### Vulnerability Scanning with Trivy
```bash
# Scan Docker image
trivy image myapp:latest

# Scan filesystem
trivy fs .

# Scan Kubernetes cluster
trivy k8s cluster

# Generate report
trivy image --format json --output report.json myapp:latest
```

### Infrastructure Scanning with Checkov
```bash
# Install Checkov
pip install checkov

# Scan Terraform files
checkov -d /path/to/terraform

# Scan Kubernetes manifests
checkov -f deployment.yaml

# Custom policy
# .checkov.yaml
framework:
  - terraform
  - kubernetes
skip-check:
  - CKV_K8S_8  # Skip specific check
```

## 🛡️ WAF Configuration

### AWS WAF Rules
```hcl
resource "aws_wafv2_web_acl" "main" {
  name  = "main-waf"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Block common attacks
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rate limiting
  rule {
    name     = "RateLimitRule"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitMetric"
      sampled_requests_enabled   = true
    }
  }
}
```

## 🔐 Identity and Access Management

### AWS IAM Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-app-bucket/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    }
  ]
}
```

### Kubernetes RBAC
```yaml
# service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: myapp-sa
  namespace: default

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: myapp-role
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: myapp-binding
subjects:
- kind: ServiceAccount
  name: myapp-sa
  namespace: default
roleRef:
  kind: Role
  name: myapp-role
  apiGroup: rbac.authorization.k8s.io
```

## 🎓 What You Learned

- ✅ Secrets management with Vault and K8s
- ✅ Network security and VPC configuration
- ✅ SSL/TLS setup with cert-manager
- ✅ Security scanning tools and practices
- ✅ WAF configuration and rules
- ✅ IAM and RBAC implementation

---

**Next:** [Container Security](../04-container-security/)