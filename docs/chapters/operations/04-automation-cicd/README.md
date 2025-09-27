# 🤖 Automation & CI/CD - Deploy Like Netflix

## 🎯 Objective
Automate operations tasks and implement GitOps workflows that scale to thousands of deployments per day.

> **"The best way to avoid human error is to remove humans from the equation."** - Werner Vogels, Amazon CTO

## 🌟 Why Automation Matters - The Deployment Revolution

### Companies Mastering Automation

**🎬 Netflix** - Deploys 4,000+ times per day
- **Strategy:** Spinnaker + GitOps + automated canary deployments
- **Result:** 99.99% uptime despite constant changes¹
- **Secret:** Every deployment is automated, tested, and reversible
- **Impact:** Engineers focus on features, not deployment mechanics

**🎵 Spotify** - 1,200+ autonomous teams deploying independently
- **Challenge:** Coordinate deployments across 4,000+ microservices
- **Solution:** GitOps + ArgoCD + automated testing pipelines
- **Result:** 10,000+ deployments per day with 99.9% success rate²
- **Learning:** Automation enables team autonomy at scale

**🏠 Airbnb** - Reduced deployment time from 4 hours to 15 minutes
- **Problem:** Manual deployments blocked feature releases
- **Strategy:** Kubernetes + GitOps + automated rollbacks
- **Impact:** 16x faster deployments, 90% fewer deployment issues³
- **Bonus:** Engineers deploy confidently, even on Fridays

### The Cost of Manual Operations
- **⏰ Time waste:** Manual deployments take 10-20x longer⁴
- **🐛 Error rate:** 70% of outages caused by manual changes⁵
- **😱 Fear factor:** 60% of teams avoid Friday deployments⁶
- **💸 Opportunity cost:** Manual ops teams deploy 200x less frequently⁷
- **😤 Developer frustration:** 40% of dev time wasted on deployment issues⁸

*¹Netflix Tech Blog | ²Spotify Engineering | ³Airbnb Engineering | ⁴DORA State of DevOps | ⁵Puppet Infrastructure Report | ⁶Stack Overflow Survey | ⁷Google DevOps Research | ⁸JetBrains Developer Survey*

## 🔄 GitOps - The Netflix Way

### What is GitOps?
**GitOps = Git + Operations**
- 📝 **Git as single source of truth** - All config in version control
- 🤖 **Automated deployment** - Changes in Git trigger deployments
- 🔄 **Continuous reconciliation** - System self-heals to match Git state
- 🔙 **Easy rollbacks** - Revert Git commit = instant rollback

**Why GitOps vs Traditional CI/CD?**
```
Traditional CI/CD:
Developer → CI/CD Pipeline → kubectl apply → Cluster
❌ Problems: Pipeline has cluster access, hard to audit, complex rollbacks

GitOps:
Developer → Git Commit → ArgoCD pulls changes → Cluster
✅ Benefits: No external cluster access, Git audit trail, simple rollbacks
```

### ArgoCD - The GitOps Engine (Used by 10,000+ Companies)

**What is ArgoCD?**
- 🔍 **Kubernetes-native** - Runs inside your cluster
- 👁️ **Continuous monitoring** - Watches Git repos for changes
- 🔄 **Auto-sync** - Keeps cluster in sync with Git
- 📊 **Visual dashboard** - See all applications and their health

**Companies using ArgoCD:**
- **Red Hat** - Manages OpenShift deployments
- **Intuit** - Deploys TurboTax and QuickBooks
- **Adobe** - Handles Creative Cloud infrastructure
- **Tesla** - Manages manufacturing systems

### ArgoCD Application Configuration
```yaml
# application.yaml - This defines what ArgoCD should deploy
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp                    # Application name in ArgoCD UI
  namespace: argocd              # ArgoCD namespace
spec:
  project: default               # ArgoCD project (for RBAC)
  
  # WHERE to get the code
  source:
    repoURL: https://github.com/company/k8s-manifests  # Git repository
    targetRevision: HEAD          # Branch/tag to track (HEAD = latest)
    path: apps/myapp              # Folder containing Kubernetes manifests
  
  # WHERE to deploy
  destination:
    server: https://kubernetes.default.svc  # Kubernetes cluster
    namespace: production         # Target namespace
  
  # HOW to deploy
  syncPolicy:
    automated:                   # Enable automatic deployment
      prune: true               # Delete resources not in Git
      selfHeal: true            # Fix manual changes automatically
    syncOptions:
    - CreateNamespace=true      # Create namespace if it doesn't exist
    - PrunePropagationPolicy=foreground  # How to delete resources
    - PruneLast=true            # Delete resources after new ones are ready
```

**Why each setting matters:**
- `prune: true` - **Prevents config drift** (removes manually created resources)
- `selfHeal: true` - **Fixes manual changes** (kubectl edits get reverted)
- `CreateNamespace=true` - **Simplifies setup** (no need to pre-create namespaces)

### GitOps Workflow in Action
```
1. Developer commits code change
   → git commit -m "Update user service to v2.1"
   → git push origin main

2. CI pipeline builds and tests
   → Docker build → Run tests → Push image
   → Update k8s-manifests repo with new image tag

3. ArgoCD detects Git change
   → Polls Git repo every 3 minutes
   → Sees new image tag in deployment.yaml

4. ArgoCD syncs cluster
   → kubectl apply new manifests
   → Rolling update with zero downtime
   → Health checks ensure success

5. Monitoring confirms deployment
   → Prometheus metrics show healthy pods
   → ArgoCD UI shows green status
```

## 🔧 Infrastructure Automation - Beyond Deployments

### When ArgoCD Isn't Enough - Real Scenarios

**🏦 Bank of America** - Uses Ansible for compliance automation
- **Problem:** Need to ensure all 50+ Kubernetes clusters meet regulatory requirements
- **Solution:** Ansible playbooks that audit and fix security policies
- **Why not ArgoCD?** ArgoCD deploys apps, Ansible manages cluster configuration

**📺 Disney+** - Multi-cloud Kubernetes management
- **Challenge:** Deploy same app to AWS, Azure, and on-premises clusters
- **Solution:** Ansible inventory manages different cluster types
- **Why Ansible?** Single playbook works across all environments

**🏭 Walmart** - Day-2 operations automation
- **Scenario:** Need to patch 200+ clusters, update certificates, manage users
- **Solution:** Ansible automates operational tasks beyond app deployment
- **Real example:** Certificate renewal across all clusters in one command

### Specific Use Cases Where You Need Ansible

**1. 🔒 Cluster Setup & Configuration**
```bash
# ArgoCD can't do this - it needs a cluster to exist first
# Ansible sets up the cluster itself
```

**2. 📄 Compliance & Security Auditing**
```bash
# Check if all clusters have required security policies
# Fix non-compliant clusters automatically
```

**3. 🔄 Day-2 Operations**
```bash
# Certificate rotation across 100+ clusters
# User management and RBAC updates
# Backup verification and restoration
```

**4. 🌍 Multi-Cloud Deployments**
```bash
# Deploy to AWS EKS, Azure AKS, Google GKE with same playbook
# Handle cloud-specific configurations
```

**5. 🛠️ Disaster Recovery**
```bash
# Rebuild entire cluster from scratch
# Restore applications and data
```

### Why Ansible for These Tasks?
- 📜 **Declarative** - "Ensure all clusters have this security policy"
- 🔄 **Idempotent** - Run certificate renewal monthly, only updates when needed
- 📡 **Agentless** - Works with any Kubernetes cluster (no installation required)
- 📊 **Inventory management** - One playbook for dev/staging/prod clusters

### Real-World Ansible Playbook (Certificate Renewal)
```yaml
# cert-renewal.yml - Real scenario: Renew certificates across all clusters
---
- name: Renew Kubernetes certificates across all clusters
  hosts: all_k8s_clusters        # Inventory groups: prod_clusters, staging_clusters
  gather_facts: false
  vars:
    cert_expiry_days: 30         # Renew if expires in 30 days
    
  tasks:
    # Check certificate expiry (this is why you need Ansible, not ArgoCD)
    - name: Check certificate expiration
      shell: |
        kubectl get secret tls-cert -n default -o jsonpath='{.data.tls\.crt}' | \
        base64 -d | openssl x509 -noout -enddate
      register: cert_info
      
    - name: Parse certificate expiry date
      set_fact:
        cert_expires: "{{ cert_info.stdout | regex_search('notAfter=(.+)', '\\1') | first }}"
        
    - name: Check if certificate needs renewal
      set_fact:
        needs_renewal: "{{ (cert_expires | to_datetime('%b %d %H:%M:%S %Y %Z') - ansible_date_time.epoch | int) < (cert_expiry_days * 86400) }}"
        
    # Only renew if needed (idempotent)
    - name: Generate new certificate
      shell: |
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout tls.key -out tls.crt -subj "/CN={{ inventory_hostname }}"
      when: needs_renewal
      delegate_to: localhost
      
    - name: Update certificate secret
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Secret
          metadata:
            name: tls-cert
            namespace: default
          type: kubernetes.io/tls
          data:
            tls.crt: "{{ lookup('file', 'tls.crt') | b64encode }}"
            tls.key: "{{ lookup('file', 'tls.key') | b64encode }}"
      when: needs_renewal
      
    # Restart pods to pick up new certificate
    - name: Restart deployments using the certificate
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: "{{ item }}"
            namespace: default
            annotations:
              deployment.kubernetes.io/revision: "{{ ansible_date_time.epoch }}"
          spec:
            template:
              metadata:
                annotations:
                  cert-renewed: "{{ ansible_date_time.iso8601 }}"
      loop:
        - web-server
        - api-gateway
      when: needs_renewal
      
    # Verify certificate is working
    - name: Test HTTPS endpoint
      uri:
        url: "https://{{ inventory_hostname }}/health"
        method: GET
        validate_certs: yes
        status_code: 200
      retries: 3
      delay: 10
      when: needs_renewal
      
    # Notification with cluster-specific info
    - name: Notify certificate renewal
      uri:
        url: "{{ slack_webhook_url }}"
        method: POST
        body_format: json
        body:
          text: "🔒 Certificate renewed on {{ inventory_hostname }} ({{ ansible_date_time.date }})"
          attachments:
            - color: "good"
              fields:
                - title: "Cluster"
                  value: "{{ inventory_hostname }}"
                  short: true
                - title: "Environment"
                  value: "{{ group_names[0] }}"
                  short: true
      when: needs_renewal
```

### Ansible Inventory for Multi-Cluster Management
```ini
# inventory/hosts - This is why Ansible is powerful
[prod_clusters]
k8s-prod-us-east.company.com
k8s-prod-eu-west.company.com
k8s-prod-asia.company.com

[staging_clusters]
k8s-staging-us.company.com
k8s-staging-eu.company.com

[dev_clusters]
k8s-dev-local.company.com

[aws_clusters:children]
prod_clusters
staging_clusters

[all_k8s_clusters:children]
aws_clusters
dev_clusters

[all_k8s_clusters:vars]
ansible_connection=kubectl
ansible_kubectl_namespace=default
slack_webhook_url=https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
```

**Run certificate renewal on all production clusters:**
```bash
ansible-playbook -i inventory/hosts cert-renewal.yml --limit prod_clusters
```

**This is impossible with ArgoCD because:**
- ArgoCD deploys applications, not cluster operations
- ArgoCD can't check certificate expiry dates
- ArgoCD can't run commands across multiple clusters
- ArgoCD can't handle conditional logic ("only if cert expires soon")

### More Real Ansible Use Cases

**🛡️ Security Policy Enforcement (Used by Financial Services)**
```yaml
# Ensure all clusters have required security policies
- name: Enforce Pod Security Standards
  kubernetes.core.k8s:
    state: present
    definition:
      apiVersion: v1
      kind: Namespace
      metadata:
        name: "{{ item }}"
        labels:
          pod-security.kubernetes.io/enforce: restricted
          pod-security.kubernetes.io/audit: restricted
  loop: "{{ application_namespaces }}"
```

**📊 Multi-Cloud Deployment (Used by Netflix, Spotify)**
```yaml
# Deploy same app to AWS EKS, Azure AKS, Google GKE
- name: Deploy to cloud-specific configuration
  kubernetes.core.k8s:
    state: present
    definition: "{{ lookup('template', 'app-{{ cloud_provider }}.yaml.j2') }}"
  vars:
    cloud_provider: "{{ 'aws' if 'eks' in inventory_hostname else 'azure' if 'aks' in inventory_hostname else 'gcp' }}"
```

**🔄 Disaster Recovery (Used by Banks, Healthcare)**
```yaml
# Rebuild cluster from backup
- name: Restore cluster from backup
  include_tasks: restore-{{ backup_type }}.yml
  vars:
    backup_date: "{{ ansible_date_time.date }}"
```

## 🚀 Advanced Automation Patterns

### Blue-Green Deployments with ArgoCD
```yaml
# blue-green-rollout.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: myapp-rollout
spec:
  replicas: 5
  strategy:
    blueGreen:
      activeService: myapp-active      # Production traffic
      previewService: myapp-preview    # Testing traffic
      autoPromotionEnabled: false      # Manual approval required
      scaleDownDelaySeconds: 30        # Keep old version for 30s
      prePromotionAnalysis:            # Automated testing
        templates:
        - templateName: success-rate
        args:
        - name: service-name
          value: myapp-preview
```

### Key Metrics to Track
```
📈 Deployment Frequency
- How often you deploy (Netflix: 4,000/day)
- Target: Multiple times per day

⏱️ Lead Time
- Code commit to production (Netflix: <1 hour)
- Target: <4 hours

🔄 Deployment Success Rate
- Percentage of successful deployments
- Target: >95%

🔙 Mean Time to Recovery (MTTR)
- How fast you fix issues (Netflix: <15 minutes)
- Target: <1 hour
```

## 🎓 What You Learned

### Technical Skills
- ✅ **GitOps mastery** - Deploy like Netflix (4,000+ times/day)
- ✅ **ArgoCD expertise** - Used by 10,000+ companies worldwide
- ✅ **Ansible automation** - Infrastructure as code for Kubernetes
- ✅ **Advanced deployments** - Blue-green, canary, automated rollbacks
- ✅ **Monitoring automation** - Track deployment metrics like DORA

### Career Impact (Automation Market Data)
- 💼 **DevOps Engineer:** $95k-$160k (automation skills essential)⁹
- 💼 **Site Reliability Engineer:** $120k-$200k¹⁰
- 💼 **Platform Engineer:** $110k-$180k (fastest growing role)¹¹
- 💼 **DevOps Consultant:** $120-$250/hour¹²
- 💼 **Job growth:** 25% increase in automation roles (2023-2033)¹³

*⁹Stack Overflow Survey | ¹⁰Levels.fyi | ¹¹LinkedIn Jobs Report | ¹²Upwork Rates | ¹³Bureau of Labor Statistics*

### Industry Certifications This Prepares You For
- 🏅 **Certified Kubernetes Administrator (CKA)** - Kubernetes expertise
- 🏅 **GitOps Fundamentals** - CNCF GitOps certification
- 🏅 **AWS Certified DevOps Engineer** - Cloud automation
- 🏅 **Red Hat Certified Specialist in Ansible** - Automation mastery

> **Automation fact:** Companies with advanced automation deploy 208x more frequently and have 2,604x faster recovery times.¹⁴

---

## 📚 Sources & Further Reading

### Industry Reports & Research
- [DORA State of DevOps Report 2023](https://cloud.google.com/devops/state-of-devops) - Deployment performance metrics
- [Puppet State of DevOps 2023](https://puppet.com/resources/report/2023-state-of-devops-report/) - Automation impact
- [JetBrains Developer Survey 2023](https://www.jetbrains.com/lp/devecosystem-2023/) - Developer productivity
- [Stack Overflow Developer Survey 2023](https://survey.stackoverflow.co/2023/) - Tool adoption

### Company Engineering Blogs
- [Netflix Tech Blog - Deployment](https://netflixtechblog.com/tagged/deployment) - Large-scale automation
- [Spotify Engineering - Platform](https://engineering.atspotify.com/category/platform/) - GitOps at scale
- [Airbnb Engineering - Infrastructure](https://medium.com/airbnb-engineering/tagged/infrastructure) - Kubernetes automation
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/) - Official GitOps guide

### Tools & Platforms
- [ArgoCD](https://argoproj.github.io/cd/) - GitOps continuous delivery
- [Ansible](https://docs.ansible.com/ansible/latest/collections/kubernetes/core/) - Kubernetes automation
- [Argo Rollouts](https://argoproj.github.io/rollouts/) - Advanced deployment strategies
- [Prometheus](https://prometheus.io/docs/prometheus/latest/querying/basics/) - Metrics and monitoring

**Next:** [Performance Scaling](../05-performance-scaling/) - Scale like Netflix handles 1 billion hours of streaming!