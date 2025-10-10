# 🛡️ Lesson 21: Advanced Kubernetes Security - The SolarWinds Prevention Guide

## 🎯 Objective
Implement enterprise-grade security that prevents supply chain attacks like SolarWinds and runtime threats.

> **"Security is not a feature, it's a foundation."** - Kubernetes Security Team

## 🚨 Why Advanced Security Matters

### The $90 Billion SolarWinds Hack (2020)
- **Target:** 18,000+ companies using SolarWinds Orion
- **Method:** Compromised software supply chain
- **Impact:** Microsoft, FireEye, US Treasury breached
- **Cost:** $90B+ in global remediation costs¹
- **Duration:** 9 months undetected
- **Root cause:** No supply chain security, no runtime monitoring

### What Advanced K8s Security Prevents
```
❌ SolarWinds-style attacks:
- Malicious container images
- Compromised software dependencies
- Runtime privilege escalation
- Lateral movement in clusters

✅ Advanced security stops:
- Supply chain attacks (image signing)
- Runtime threats (Falco monitoring)
- Policy violations (OPA enforcement)
- Privilege escalation (admission control)
```

*¹Reuters SolarWinds Analysis*

## 🔒 Zero Trust Security - Never Trust, Always Verify

### What Zero Trust Means in Kubernetes

**Traditional Security:**
```
🏰 Castle Model:
- Hard perimeter (firewall)
- Soft interior (trust everything inside)
- Problem: Once inside, attackers move freely
```

**Zero Trust Model:**
```
🔐 Zero Trust:
- Verify every request
- Least privilege access
- Continuous monitoring
- Assume breach mentality
```

## 🧪 Experiment 1: Open Policy Agent (OPA) - The Policy Engine

### What is OPA Gatekeeper?
**Simple explanation:** OPA is like a security guard that checks every Kubernetes request against your rules.

**Real-world example:**
- **Rule:** "No containers can run as root"
- **Action:** OPA blocks any pod trying to run as root user
- **Result:** Prevents privilege escalation attacks

### Install OPA Gatekeeper

```powershell
# Install Gatekeeper
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml

# Wait for Gatekeeper to be ready
kubectl wait --for=condition=Ready pod -l gatekeeper.sh/operation=webhook -n gatekeeper-system --timeout=300s

# Verify installation
kubectl get pods -n gatekeeper-system
```

### Create Security Policies

```yaml
# constraint-template-no-root.yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredsecuritycontext
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredSecurityContext
      validation:
        type: object
        properties:
          runAsNonRoot:
            type: boolean
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredsecuritycontext
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.securityContext.runAsNonRoot
          msg := "Container must run as non-root user"
        }
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          container.securityContext.runAsUser == 0
          msg := "Container cannot run as root (UID 0)"
        }
```

```powershell
# Apply the policies
kubectl apply -f constraint-template-no-root.yaml

# Create constraint
@"
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredSecurityContext
metadata:
  name: must-run-as-nonroot
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
    excludedNamespaces: ["kube-system", "gatekeeper-system"]
  parameters:
    runAsNonRoot: true
"@ | kubectl apply -f -

# Wait for constraint to be ready
kubectl wait --for=condition=Ready k8srequiredsecuritycontext must-run-as-nonroot --timeout=60s
```

## 🧪 Experiment 2: Falco Runtime Security - The Kubernetes Watchdog

### What is Falco?
**Simple explanation:** Falco is like a security camera that watches your containers and alerts when something suspicious happens.

**Real-world example:**
- **Normal:** Container runs nginx web server
- **Suspicious:** Someone executes shell commands inside the container
- **Falco action:** Immediately alerts "Shell spawned in container!"

### Install Falco

```powershell
# Add Falco Helm repository
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

# Install Falco with custom configuration
helm install falco falcosecurity/falco `
  --namespace falco-system `
  --create-namespace `
  --set falco.grpc.enabled=true `
  --set falco.grpcOutput.enabled=true `
  --set falco.httpOutput.enabled=true

# Wait for Falco to be ready
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=falco -n falco-system --timeout=300s

# Check Falco is running
kubectl get pods -n falco-system
kubectl logs -l app.kubernetes.io/name=falco -n falco-system --tail=10
```

### Test Falco Detection

```powershell
# Create test pod
@"
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test-container
    image: ubuntu:20.04
    command: ["sleep", "3600"]
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
"@ | kubectl apply -f -

kubectl wait --for=condition=Ready pod test-pod --timeout=60s

# Test shell detection
Write-Host "Triggering shell (should alert Falco)..." -ForegroundColor Yellow
kubectl exec -it test-pod -- /bin/bash -c "echo 'This triggers Falco'"

# Check Falco alerts
Start-Sleep -Seconds 5
kubectl logs -l app.kubernetes.io/name=falco -n falco-system --tail=20

# Clean up
kubectl delete pod test-pod
```

## 🧪 Experiment 3: Supply Chain Security - Prevent the Next SolarWinds

### What is Supply Chain Security?
**Simple explanation:** Make sure container images haven't been tampered with, like checking a food package seal.

**SolarWinds lesson:**
- Attackers modified legitimate software
- No way to verify software integrity
- Malicious code spread to 18,000+ companies
- **Solution:** Digital signatures for container images

### Install Cosign

```powershell
# Install Cosign on Windows
choco install cosign

# Verify installation
cosign version

# Generate signing keys
cosign generate-key-pair
# Creates cosign.key (private) and cosign.pub (public)

$env:COSIGN_PASSWORD = "secure-password"
```

### Sign and Verify Images

```powershell
# Create test image
@"
FROM nginx:1.21-alpine
RUN echo 'Hello from signed container!' > /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
"@ | Out-File -FilePath Dockerfile

# Build image
docker build -t localhost:5000/signed-app:v1.0 .

# Start local registry
docker run -d -p 5000:5000 --name registry registry:2
docker push localhost:5000/signed-app:v1.0

# Sign the image
cosign sign --key cosign.key localhost:5000/signed-app:v1.0

# Verify signature
cosign verify --key cosign.pub localhost:5000/signed-app:v1.0
```

## 🚀 Complete Advanced Security Demo

**Create comprehensive security test script:**

```powershell
# advanced-security-demo.ps1
Write-Host "🛡️ Advanced Kubernetes Security Demo" -ForegroundColor Green

# Check security components
Write-Host "\n🔍 Checking security components..." -ForegroundColor Blue

$gatekeeper = kubectl get pods -n gatekeeper-system --no-headers 2>$null
if ($gatekeeper) {
    Write-Host "✅ OPA Gatekeeper is running" -ForegroundColor Green
} else {
    Write-Host "❌ OPA Gatekeeper not found" -ForegroundColor Red
}

$falco = kubectl get pods -n falco-system --no-headers 2>$null
if ($falco) {
    Write-Host "✅ Falco is running" -ForegroundColor Green
} else {
    Write-Host "❌ Falco not found" -ForegroundColor Red
}

# Test security policies
Write-Host "\n🧪 Testing security policies..." -ForegroundColor Blue

# Test 1: Root user policy
Write-Host "Test 1: Blocking root containers..." -ForegroundColor Yellow
@"
apiVersion: v1
kind: Pod
metadata:
  name: bad-pod
spec:
  containers:
  - name: bad-container
    image: nginx:1.21
    securityContext:
      runAsUser: 0
"@ | kubectl apply -f - 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "✅ Root container blocked by OPA" -ForegroundColor Green
} else {
    Write-Host "❌ Root container was allowed" -ForegroundColor Red
    kubectl delete pod bad-pod --ignore-not-found
}

Write-Host "\n🎉 Security demo complete!" -ForegroundColor Green
```

## 🎯 Security Tools Arsenal

### 🛡️ **Policy Enforcement**
- **OPA Gatekeeper** - Admission control policies
- **Kyverno** - Alternative policy engine
- **ValidatingAdmissionWebhooks** - Custom validation

### 🔍 **Runtime Security**
- **Falco** - Runtime threat detection
- **Sysdig Secure** - Commercial runtime security
- **Aqua Security** - Container runtime protection

### 📦 **Supply Chain Security**
- **Cosign** - Container image signing
- **Notary** - Docker content trust
- **TUF** - Secure software updates

### 🔐 **Vulnerability Management**
- **Trivy** - Vulnerability scanner
- **Clair** - Static analysis
- **Snyk** - Developer-first security

## 🎓 What You Mastered

### Enterprise Security Skills
- ✅ **Zero Trust Architecture** - Never trust, always verify
- ✅ **Policy Enforcement** - OPA Gatekeeper blocking malicious pods
- ✅ **Runtime Security** - Falco detecting suspicious activity
- ✅ **Supply Chain Security** - Cosign preventing SolarWinds-style attacks
- ✅ **Security Automation** - Complete security pipeline

### Career Value
- 💼 **Kubernetes Security Specialist:** $120k-$200k
- 💼 **DevSecOps Engineer:** $110k-$180k
- 💼 **Security Architect:** $140k-$220k

---

## 🚀 Next Challenge

**Try This:**
1. Set up all security tools in your lab
2. Create custom security policies
3. Test with vulnerable containers
4. Build security expertise

**Next:** [Lesson 22: Emerging Technologies](../22-emerging-tech/) - Explore the future!