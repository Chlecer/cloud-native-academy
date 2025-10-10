# 🗝 Lesson 5: ConfigMaps and Secrets

## 🎴 Objective
Learn how to manage configurations and sensitive data securely in Kubernetes.

## 🤨 The Configuration Problem

### **Real-World Scenario**

Imagine you're building a web application that needs:
- **Database connection string** (changes per environment)
- **API keys** for external services (secret!)
- **Feature flags** (enable/disable features)
- **SSL certificates** (very secret!)

### **Bad Approach: Hard-coded in Container**
```dockerfile
# DON'T DO THIS!
FROM node:16
ENV DATABASE_URL="postgresql://prod-server:5432/myapp"
ENV API_KEY="sk_live_abc123xyz789"
ENV DEBUG="false"
COPY . .
CMD ["npm", "start"]
```

**Problems:**
- ❌ **Security risk**: Secrets visible in image
- ❌ **Inflexible**: Need new image for each environment
- ❌ **Audit nightmare**: Who has access to what?
- ❌ **Rotation impossible**: Can't change passwords easily

### **Kubernetes Solution: ConfigMaps & Secrets**

```
🏢 Development Environment:
┌─────────────────────────┐
│ ConfigMap:              │
│ - DATABASE_URL=dev-db   │
│ - DEBUG=true            │
│                         │
│ Secret:                 │
│ - API_KEY=test_key      │
└─────────────────────────┘

🔴 Production Environment:
┌─────────────────────────┐
│ ConfigMap:              │
│ - DATABASE_URL=prod-db  │
│ - DEBUG=false           │
│                         │
│ Secret:                 │
│ - API_KEY=live_key      │
└─────────────────────────┘

Same container image works in both!
```

### **What Are ConfigMaps and Secrets?**

- **ConfigMaps** = Non-sensitive configuration (database URLs, feature flags)
- **Secrets** = Sensitive data (passwords, API keys, certificates)

### **Enterprise Alternatives**

**For production environments, consider:**

- **HashiCorp Vault** - Enterprise secret management
  - Dynamic secrets, encryption, audit logs
  - Used by: Netflix, Uber, Samsung
  
- **AWS Secrets Manager** - Cloud-native secret storage
  - Automatic rotation, fine-grained access
  - Integrates with EKS
  
- **Azure Key Vault** - Microsoft's secret management
  - Hardware security modules (HSM)
  - Integrates with AKS
  
- **Google Secret Manager** - Google Cloud secrets
  - Automatic encryption, versioning
  - Integrates with GKE

**When to use what:**
- **Kubernetes Secrets**: Learning, development, simple production
- **Enterprise solutions**: Large-scale production, compliance requirements

**This lesson covers Kubernetes native approach - foundation for understanding enterprise solutions.**

## 🎵 Experiment 1: ConfigMaps

### Create ConfigMap from literals
```cmd
kubectl create configmap app-config --from-literal=DATABASE_URL=postgresql://localhost:5432/mydb --from-literal=DEBUG=true
```

### Create ConfigMap from file
```cmd
kubectl create configmap nginx-config --from-file=nginx.conf
```

### View ConfigMaps
```cmd
kubectl get configmaps
kubectl describe configmap app-config
```

## 🔑 Experiment 2: Secrets

### Create Secret from literals
```cmd
kubectl create secret generic app-secrets --from-literal=db-password=supersecret --from-literal=api-key=abc123xyz
```

### Create Secret from files
```cmd
kubectl create secret generic tls-secret --from-file=tls.crt --from-file=tls.key
```

### View Secrets (encoded)
```cmd
kubectl get secrets
kubectl describe secret app-secrets
```

## 🎯 Experiment 3: Using in Pods

Apply the complete example:
```cmd
kubectl apply -f complete-config-example.yaml
```

Test the configuration:
```cmd
kubectl exec -it config-demo -- env | findstr /C:"DATABASE_URL DB_PASSWORD"
```

## 🎬 Complete Demo

Run the automated demo:
```cmd
config-demo.bat
```

## 📝 Best Practices

### **ConfigMaps**
- ✅ **Non-sensitive data only** (database URLs, feature flags)
- ✅ **Environment-specific settings** (dev vs prod configurations)
- ✅ **Application properties** (timeouts, limits, endpoints)
- ❌ **Never store passwords** or API keys

### **Secrets**
- ✅ **Sensitive data only** (passwords, tokens, certificates)
- ✅ **Base64 encoded** (not encrypted - just encoded!)
- ✅ **RBAC protection** (limit who can read secrets)
- ✅ **Regular rotation** (change passwords periodically)
- ⚠️ **Not encrypted at rest** by default (enable encryption)

### **Security Considerations**

```
Kubernetes Secrets Limitations:
❌ Stored as base64 (not encrypted)
❌ Visible to cluster admins
❌ No automatic rotation
❌ No audit logging by default

Enterprise Solutions (Vault, etc.):
✅ True encryption
✅ Dynamic secrets
✅ Automatic rotation
✅ Detailed audit logs
✅ Fine-grained access control
```

### **Real-World Usage**

**Startups/Small teams**: Kubernetes ConfigMaps + Secrets
**Enterprise/Compliance**: Vault + Kubernetes integration
**Cloud-native**: Cloud provider secret managers (AWS/Azure/GCP)

### **Migration Path**

```
Phase 1: Learn Kubernetes basics (this lesson)
↓
Phase 2: Implement in development
↓
Phase 3: Evaluate enterprise needs
↓
Phase 4: Migrate to Vault/Cloud solutions for production
```

---

## 🌲 Next Lesson

Go to [Lesson 6: Volumes - Persistence](../06-volumes-persistence/) to learn about data storage!