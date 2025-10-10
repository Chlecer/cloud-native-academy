# ☁️ Lesson 20: Multi-Cloud Kubernetes - Why Netflix Uses 3 Different Clouds

## 🎯 Objective
Understand multi-cloud strategy and deploy Kubernetes across AWS, Azure, and GCP like the pros do.

> **"Don't put all your eggs in one basket. Don't put all your workloads in one cloud."** - Adrian Cockcroft, Former Netflix Cloud Architect

## 🤔 What is Multi-Cloud? (For Beginners)

**Simple Definition:**
Multi-cloud means using multiple cloud providers (AWS + Azure + Google Cloud) instead of just one.

**Real-World Example:**
- **Netflix:** Uses AWS for streaming, Google Cloud for machine learning, CDNs for global delivery
- **Spotify:** AWS for core services, Google Cloud for data analytics, Azure for Microsoft integrations
- **Uber:** AWS for ride-sharing, Google Cloud for maps, Azure for enterprise tools

## 🌍 Why Companies Go Multi-Cloud

### 1. 🛡️ **Avoid Vendor Lock-in** (The $2 Billion Lesson)
**Snapchat's Mistake (2017):**
- Committed $2 billion to Google Cloud only
- When growth slowed, still had to pay fixed costs
- Stock dropped 82% partly due to cloud costs¹
- **Lesson:** Flexibility prevents financial disasters

### 2. 🏆 **Best Tool for Each Job**
**Why Netflix Uses Multiple Clouds:**
```
🎬 AWS: Core streaming infrastructure
- Mature services (EC2, S3, RDS)
- Global presence
- Proven at Netflix scale

🧠 Google Cloud: Machine learning & analytics
- Best AI/ML services (TensorFlow, BigQuery)
- Superior data processing
- Advanced analytics

📡 CDNs: Content delivery
- Akamai, Cloudflare for global reach
- Faster content delivery
- Reduced bandwidth costs
```

### 3. 🌍 **Geographic Requirements**
**Real Example - GDPR Compliance:**
- **EU data** must stay in EU (GDPR law)
- **China data** must stay in China (local laws)
- **US government** requires US-only clouds
- **Solution:** Different clouds in different regions

### 4. 🚨 **Disaster Recovery**
**Facebook's 6-Hour Outage (2021):**
- Single point of failure took down Facebook, Instagram, WhatsApp
- Cost: $150+ million in lost revenue²
- **Multi-cloud lesson:** If one cloud fails, others keep running

*¹Snapchat SEC Filings | ²Facebook Investor Relations*

## ☁️ Multi-Cloud Kubernetes Setup (Step-by-Step)

### Understanding Each Cloud's Strengths

**🟠 AWS EKS - The Mature Choice**
- **Best for:** Production workloads, enterprise applications
- **Strengths:** Most services, global presence, battle-tested
- **Used by:** Netflix, Airbnb, Slack
- **Cost:** Moderate, many pricing options

**🔵 Azure AKS - The Enterprise Favorite**
- **Best for:** Microsoft shops, hybrid cloud, enterprise integration
- **Strengths:** Active Directory integration, Windows containers, hybrid
- **Used by:** H&R Block, Progressive Insurance, BMW
- **Cost:** Competitive, good for existing Microsoft customers

**🔴 Google GKE - The Innovation Leader**
- **Best for:** Machine learning, data analytics, modern applications
- **Strengths:** Kubernetes originated here, best ML services, autopilot mode
- **Used by:** Spotify, Twitter, PayPal
- **Cost:** Often cheapest, sustained use discounts

### 🛠️ Practical Multi-Cloud Setup

**Step 1: Create Clusters in Each Cloud**

```powershell
# 🟠 AWS EKS Cluster
# Install eksctl first: choco install eksctl
eksctl create cluster `
  --name production-aws `
  --region us-west-2 `
  --nodes 3 `
  --node-type t3.medium `
  --managed

# Verify AWS cluster
kubectl config use-context production-aws
kubectl get nodes
```

```powershell
# 🔵 Azure AKS Cluster
# Install Azure CLI: choco install azure-cli
az login
az group create --name multicloud-rg --location eastus

az aks create `
  --resource-group multicloud-rg `
  --name production-azure `
  --node-count 3 `
  --node-vm-size Standard_B2s `
  --enable-addons monitoring

# Get credentials
az aks get-credentials --resource-group multicloud-rg --name production-azure

# Verify Azure cluster
kubectl config use-context production-azure
kubectl get nodes
```

```powershell
# 🔴 Google GKE Cluster
# Install gcloud: choco install gcloudsdk
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

gcloud container clusters create production-gcp `
  --zone us-central1-a `
  --num-nodes 3 `
  --machine-type e2-medium `
  --enable-autoscaling `
  --min-nodes 1 `
  --max-nodes 5

# Get credentials
gcloud container clusters get-credentials production-gcp --zone us-central1-a

# Verify GCP cluster
kubectl config use-context gke_YOUR_PROJECT_production-gcp_us-central1-a
kubectl get nodes
```

**Step 2: Manage Multiple Clusters**

```powershell
# List all your clusters
kubectl config get-contexts

# Switch between clusters easily
kubectl config use-context production-aws     # Switch to AWS
kubectl config use-context production-azure   # Switch to Azure
kubectl config use-context gke_...            # Switch to GCP

# Check which cluster you're using
kubectl config current-context
```

## 🧪 Real Multi-Cloud Scenarios

### Scenario 1: Deploy Same App to All Clouds

**Why?** Test performance, compare costs, ensure redundancy

```yaml
# multi-cloud-app.yaml - Same app, different clouds
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
    cloud: "aws"  # Change to azure/gcp for other clouds
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
        cloud: "aws"
    spec:
      containers:
      - name: web-app
        image: nginx:1.21
        ports:
        - containerPort: 80
        env:
        - name: CLOUD_PROVIDER
          value: "aws"
        - name: REGION
          value: "us-west-2"
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"

---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

```powershell
# Deploy to all clouds
# AWS
kubectl config use-context production-aws
kubectl apply -f multi-cloud-app.yaml

# Azure (modify cloud label first)
kubectl config use-context production-azure
# Edit the YAML to change cloud: "azure" and region: "eastus"
kubectl apply -f multi-cloud-app.yaml

# GCP (modify cloud label first)
kubectl config use-context gke_YOUR_PROJECT_production-gcp_us-central1-a
# Edit the YAML to change cloud: "gcp" and region: "us-central1"
kubectl apply -f multi-cloud-app.yaml
```

### Scenario 2: Workload Specialization (Netflix Style)

**Real-World Pattern:** Different workloads on different clouds

```yaml
# aws-streaming.yaml - High-performance streaming on AWS
apiVersion: apps/v1
kind: Deployment
metadata:
  name: streaming-service
spec:
  replicas: 10  # High replica count for streaming
  template:
    spec:
      containers:
      - name: streaming
        image: nginx:1.21  # Replace with your streaming app
        resources:
          requests:
            memory: "1Gi"    # More memory for streaming
            cpu: "1000m"
          limits:
            memory: "2Gi"
            cpu: "2000m"
        env:
        - name: WORKLOAD_TYPE
          value: "streaming"
        - name: CLOUD_OPTIMIZED
          value: "aws-ec2"
```

## 🚀 Complete Multi-Cloud Demo

**Create this PowerShell script to manage everything:**

```powershell
# multi-cloud-demo.ps1
Write-Host "🌍 Multi-Cloud Kubernetes Demo" -ForegroundColor Green

# Function to check cluster health
function Test-ClusterHealth {
    param($contextName, $cloudName)
    
    Write-Host "\n🔍 Checking $cloudName cluster..." -ForegroundColor Yellow
    kubectl config use-context $contextName
    
    $nodes = kubectl get nodes --no-headers
    $nodeCount = ($nodes | Measure-Object).Count
    
    Write-Host "✅ $cloudName: $nodeCount nodes ready" -ForegroundColor Green
    kubectl get nodes
}

# Check all clusters
Write-Host "Starting multi-cloud health check..." -ForegroundColor Blue
Test-ClusterHealth "production-aws" "AWS"
Test-ClusterHealth "production-azure" "Azure"
Test-ClusterHealth "gke_YOUR_PROJECT_production-gcp_us-central1-a" "GCP"

Write-Host "\n🎉 Multi-cloud demo complete!" -ForegroundColor Green
```

## 🎯 Edge Computing - Kubernetes at the Edge

### What is Edge Computing? (Simple Explanation)

**Traditional Cloud:**
```
User → Internet → Cloud Data Center (far away) → Your App
❌ Problem: High latency, slow response
```

**Edge Computing:**
```
User → Local Edge Location (nearby) → Your App
✅ Benefit: Low latency, fast response
```

### Real-World Edge Examples

**🎮 Gaming (Xbox Game Pass):**
- Game servers in local data centers
- <20ms latency for real-time gaming
- Uses lightweight Kubernetes at edge

**🚗 Autonomous Vehicles:**
- Traffic data processed locally
- Can't wait for cloud response (safety!)
- K3s runs in roadside units

**🏪 Retail (Walmart):**
- Inventory management in each store
- Works even if internet fails
- MicroK8s on store servers

### Edge Kubernetes Options

**🪶 K3s - The Lightweight Champion**
```powershell
# Install K3s on Windows with Docker Desktop
docker run -d --name k3s-server --privileged -p 6443:6443 rancher/k3s:latest server

# Get kubeconfig
docker exec k3s-server cat /etc/rancher/k3s/k3s.yaml > k3s-config.yaml

# Use K3s cluster
kubectl --kubeconfig k3s-config.yaml get nodes
```

**🔧 MicroK8s - Ubuntu's Edge Solution**
```bash
# Install on Ubuntu/WSL
sudo snap install microk8s --classic

# Enable basic services
microk8s enable dns dashboard storage

# Get kubeconfig
microk8s config > microk8s-config.yaml
```

### Edge vs Cloud Comparison

```
📊 Resource Comparison:

☁️ Cloud Kubernetes:
- Nodes: 100+ cores, 1TB+ RAM
- Storage: Unlimited
- Network: High bandwidth
- Use case: Heavy workloads

📱 Edge Kubernetes:
- Nodes: 2-8 cores, 4-32GB RAM
- Storage: Limited SSD
- Network: Variable bandwidth
- Use case: Low-latency apps

🏠 Home Lab:
- Raspberry Pi 4: 4 cores, 8GB RAM
- Perfect for learning K3s
- Costs <$100
```

## 🎓 What You Learned

### Multi-Cloud Mastery
- ✅ **Why multi-cloud matters** - Real examples from Netflix, Spotify, Uber
- ✅ **Cloud provider strengths** - AWS (mature), Azure (enterprise), GCP (innovation)
- ✅ **Practical setup** - Created clusters in all 3 major clouds
- ✅ **Workload specialization** - Right workload, right cloud
- ✅ **Cross-cloud communication** - How services talk across clouds
- ✅ **Edge computing** - K3s and MicroK8s for low-latency applications

### Career Impact
- 💼 **Multi-cloud skills** are in high demand (87% of enterprises use multiple clouds)
- 💼 **Edge computing** is the fastest-growing area in cloud
- 💼 **Kubernetes expertise** across clouds = premium salary

### Real-World Applications
- 🎬 **Streaming:** AWS for core, CDN for delivery
- 🤖 **AI/ML:** Google Cloud for advanced analytics
- 🏢 **Enterprise:** Azure for Microsoft integration
- 🎮 **Gaming:** Edge for low-latency gaming
- 🚗 **IoT:** Edge for real-time processing

> **Pro Tip:** Start with one cloud, master it, then expand to multi-cloud. Don't try to learn all clouds at once!

---

## 🚀 Next Challenge

**Try This at Home:**
1. Set up K3s on a Raspberry Pi or old laptop
2. Deploy a simple web app
3. Compare response times: Cloud vs Edge
4. Experience the difference yourself!

**Next:** [Lesson 21: Advanced Security](../21-advanced-security/) - Secure your multi-cloud setup!