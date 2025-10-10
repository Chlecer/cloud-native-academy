# 🌋 Lesson 4: Deployments - Scalability and Updates

## 🎱 Objective
Learn how to manage multiple replicas, perform updates without downtime, and ensure high availability.

## 🤓 Why Deployments?

**Problem with individual Pods:**
- If the pod dies, application goes down
- Hard to scale (create/remove pods manually)
- Updates are complicated

**Solution - Deployments:**
- Ensures X replicas are always running
- Automatic scalability
- Rolling updates (updates without downtime)
- Automatic rollback if something goes wrong

## 🎪 Experiment 1: First Deployment

### Create deployment
```bash
kubectl apply -f basic-deployment.yaml
```

### Check status
```bash
kubectl get deployments
kubectl get pods -l app=webapp
kubectl describe deployment webapp-deployment
```

### Create service to access
```bash
kubectl apply -f service-deployment.yaml
```

### Test application
```bash
curl http://localhost:30100
```

## 🌀 Experiment 2: Scalability

### Scale to more replicas
```bash
kubectl scale deployment webapp-deployment --replicas=5
```

### Check scaling
```bash
kubectl get pods -l app=webapp
kubectl get deployment webapp-deployment
```

### Test load balancing
```bash
for i in {1..5}; do curl http://localhost:30100; echo; done
```
**Observe:** Different pods respond!

### Scale down
```bash
kubectl scale deployment webapp-deployment --replicas=2
```

## 🌊 Experiment 3: Rolling Updates

### Update to new version
```bash
kubectl apply -f deployment-v2.yaml
```

### Follow the rollout
```bash
kubectl rollout status deployment/webapp-deployment
```

### View history
```bash
kubectl rollout history deployment/webapp-deployment
```

### Test new version
```bash
curl http://localhost:30100
```
**Result:** Should show "Version v2.0"

## ⏪ Experiment 4: Rollback

### Perform rollback
```bash
kubectl rollout undo deployment/webapp-deployment
```

### Check rollback
```bash
kubectl rollout status deployment/webapp-deployment
curl http://localhost:30100
```

### Rollback to specific version
```bash
kubectl rollout undo deployment/webapp-deployment --to-revision=2
```

## 🎬 Complete Demo

Run the complete script:
```bash
complete-demo.bat
```

## 📜 Essential Commands

| Command | Function |
|---------|----------|
| `kubectl create deployment name --image=image` | Create deployment quickly |
| `kubectl get deployments` | List deployments |
| `kubectl scale deployment name --replicas=N` | Scale |
| `kubectl rollout status deployment/name` | Rollout status |
| `kubectl rollout history deployment/name` | History |
| `kubectl rollout undo deployment/name` | Rollback |
| `kubectl delete deployment name` | Remove |

## 🎲 Deployment Strategies

### RollingUpdate (Default)
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 25%    # Maximum unavailable
    maxSurge: 25%         # Maximum extra
```
**Advantage:** Zero downtime
**Disadvantage:** Mixed versions temporarily

### Recreate
```yaml
strategy:
  type: Recreate
```
**Advantage:** Only one version at a time
**Disadvantage:** Downtime during update

## 🩺 Health Checks

### Liveness Probe
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
```
**Function:** Restarts container if it doesn't respond

### Readiness Probe
```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```
**Function:** Removes from service if not ready

### Startup Probe
```yaml
startupProbe:
  httpGet:
    path: /startup
    port: 8080
  failureThreshold: 30
  periodSeconds: 10
```
**Function:** For applications that take time to start

## ⚙️ Advanced Configurations

### Resources
```yaml
resources:
  requests:     # Minimum guaranteed
    memory: "64Mi"
    cpu: "250m"
  limits:       # Maximum allowed
    memory: "128Mi"
    cpu: "500m"
```

### Node Selector
```yaml
nodeSelector:
  disktype: ssd
```

### Tolerations
```yaml
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoSchedule"
```

## 🔎 Troubleshooting

### Deployment doesn't update
```bash
# Check events
kubectl describe deployment name

# Check pods
kubectl get pods -l app=name

# View logs
kubectl logs -l app=name
```

### Rollout stuck
```bash
# Check status
kubectl rollout status deployment/name

# Force rollout
kubectl rollout restart deployment/name
```

### Pods don't become ready
```bash
# Check health checks
kubectl describe pod pod-name

# View logs
kubectl logs pod-name
```

## 🔭 Monitoring

### Basic metrics
```bash
# General status
kubectl get deployment name -o wide

# Event history
kubectl get events --sort-by=.metadata.creationTimestamp

# Resources (if metrics server available)
kubectl top pods -l app=name
```

### Real-time watch
```bash
# Monitor pods
kubectl get pods -l app=name -w

# Monitor deployment
kubectl get deployment name -w
```

## 🎭 Production Patterns

### **What Are Deployment Patterns?**

Deployment patterns are strategies for updating applications in production safely.

### **Blue-Green Deployment**

**What it is:** Two identical environments - only one serves traffic

```
Step 1: Blue is live          Step 2: Deploy to Green       Step 3: Switch traffic
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│ 🔵 Blue (v1.0)    │         │ 🔵 Blue (v1.0)    │         │ 🔵 Blue (v1.0)    │
│ ◀── Traffic       │         │                 │         │                 │
│                 │         │                 │         │                 │
│ 🟢 Green (empty)  │         │ 🟢 Green (v2.0)   │         │ 🟢 Green (v2.0)   │
│                 │         │     (testing)   │         │ ◀── Traffic       │
└─────────────────┘         └─────────────────┘         └─────────────────┘
```

**Advantages:**
- ✅ Instant rollback (switch back to blue)
- ✅ Zero downtime
- ✅ Full testing before switch

**Disadvantages:**
- ❌ Needs double resources
- ❌ Database migrations tricky

**How to do it:**
```bash
# Step 1: Create green version (new)
kubectl apply -f deployment-green.yaml

# Step 2: Test green version
kubectl port-forward deployment/app-green 8080:80
# Test: curl http://localhost:8080

# Step 3: Update service selector to route traffic to green deployment
kubectl patch service app-service -p '{"spec":{"selector":{"version":"green"}}}'

# Step 4: Remove blue (old) when confident
kubectl delete deployment app-blue
```

---

### **Canary Deployment**

**What it is:** Gradually shift traffic from old to new version

```
Step 1: 100% v1           Step 2: 90% v1, 10% v2      Step 3: 50% v1, 50% v2
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│ v1: 10 pods      │      │ v1: 9 pods       │      │ v1: 5 pods       │
│ v2: 0 pods       │      │ v2: 1 pod        │      │ v2: 5 pods       │
│                 │      │                 │      │                 │
│ All traffic → v1 │      │ 90% → v1, 10% → v2│      │ 50% → v1, 50% → v2│
└─────────────────┘      └─────────────────┘      └─────────────────┘
```

**Advantages:**
- ✅ Gradual rollout (less risk)
- ✅ Real user feedback
- ✅ Easy to stop if problems

**Disadvantages:**
- ❌ Mixed versions in production
- ❌ More complex monitoring

**How to do it:**
```bash
# Step 1: Start with 90% old, 10% new
kubectl scale deployment app-v1 --replicas=9
kubectl scale deployment app-v2 --replicas=1

# Step 2: Monitor metrics, if good, increase v2
kubectl scale deployment app-v1 --replicas=5
kubectl scale deployment app-v2 --replicas=5

# Step 3: Eventually 100% v2
kubectl scale deployment app-v1 --replicas=0
kubectl scale deployment app-v2 --replicas=10

# Step 4: Remove old version
kubectl delete deployment app-v1
```

**Why the name "Canary"?**
Like canaries in coal mines - they detect danger first. If the canary (small % of users) has problems, you know to stop before affecting everyone.

---

### **Understanding Kubernetes Selectors**

**What is a Selector?**

A selector is how Kubernetes resources find and connect to each other. Think of it like a filter or search query.

**How Selectors Work:**

```
Step 1: Pods have LABELS          Step 2: Services have SELECTORS
┌─────────────────┐              ┌─────────────────┐
│ Pod A           │              │ Service         │
│ labels:         │              │                 │
│   app: webapp   │              │ selector:       │
│   version: blue │              │   app: webapp   │
│   tier: frontend│              │   version: blue │
└─────────────────┘              └─────────────────┘
                                          │
┌─────────────────┐              │
│ Pod B           │              │
│ labels:         │ ◄────────────┘ MATCHES!
│   app: webapp   │              Service finds pods where:
│   version: blue │              app=webapp AND version=blue
│   tier: frontend│
└─────────────────┘

┌─────────────────┐
│ Pod C           │
│ labels:         │ ← NO MATCH (version is green)
│   app: webapp   │
│   version: green│
│   tier: frontend│
└─────────────────┘
```

**Real Example:**

```yaml
# Pod with labels
apiVersion: v1
kind: Pod
metadata:
  name: webapp-blue-123
  labels:
    app: webapp
    version: blue
    tier: frontend
spec:
  containers:
  - name: webapp
    image: nginx:1.20

---
# Service with selector
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  selector:
    app: webapp      # Must match pod label
    version: blue    # Must match pod label
  ports:
  - port: 80
    targetPort: 8080
```

**How Traffic Routing Works:**

1. **User makes request** → `http://webapp-service`
2. **Service looks for pods** with matching labels: `app=webapp AND version=blue`
3. **Kubernetes finds matching pods** and sends traffic to them
4. **If no pods match** → no traffic is routed (service has no endpoints)

**Key Point:** When you change the selector, you change which pods receive traffic!

### **Understanding the Blue-Green Switch Command**

**The traffic switching command:** `kubectl patch service app-service -p '{"spec":{"selector":{"version":"green"}}}'`

**What this does:**

```
Before (Service points to Blue):
┌─────────────────┐      ┌─────────────────┐
│    Service      │      │  Blue Pods      │
│                 │      │                 │
│ selector:       │────▶ │ labels:         │
│   version: blue │      │   version: blue │
│                 │      │   app: myapp    │
└─────────────────┘      └─────────────────┘
                         ┌─────────────────┐
                         │ Green Pods      │
                         │                 │
                         │ labels:         │
                         │   version: green│ ← Not receiving traffic
                         │   app: myapp    │
                         └─────────────────┘

After (Service points to Green):
┌─────────────────┐      ┌─────────────────┐
│    Service      │      │  Blue Pods      │
│                 │      │                 │
│ selector:       │      │ labels:         │ ← Not receiving traffic
│   version: green│      │   version: blue │
│                 │      │   app: myapp    │
└─────────────────┘      └─────────────────┘
          │              ┌─────────────────┐
          └────────────▶ │ Green Pods      │
                         │                 │
                         │ labels:         │
                         │   version: green│ ← Now receiving traffic
                         │   app: myapp    │
                         └─────────────────┘
```

**What this command does step by step:**

```bash
kubectl patch service app-service -p '{"spec":{"selector":{"version":"green"}}}'
```

**Before the command:**
- Service selector: `{app: webapp, version: blue}`
- Traffic goes to: Pods with labels `app=webapp AND version=blue`
- Result: Blue pods receive all traffic

**The command changes:**
- Service selector: `{app: webapp, version: green}`
- Traffic goes to: Pods with labels `app=webapp AND version=green`
- Result: Green pods receive all traffic

**Command breakdown:**
- `kubectl patch`: Modifies existing Kubernetes resources
- `service app-service`: Target service to modify
- `-p`: Specifies patch content in JSON format
- `{"spec":{"selector":{"version":"green"}}}`: Updates only the version part of the selector

**Why this works:**
1. **Atomic operation**: The selector change happens instantly
2. **No downtime**: Traffic immediately flows to green pods
3. **Reversible**: Change back to blue instantly if needed
4. **Safe**: Both blue and green pods can run simultaneously

**Practical example with real labels:**

```yaml
# Blue deployment pods have these labels:
labels:
  app: webapp
  version: blue

# Green deployment pods have these labels:
labels:
  app: webapp
  version: green

# Service initially selects blue:
selector:
  app: webapp
  version: blue    # ← This line determines which pods get traffic

# After patch command, service selects green:
selector:
  app: webapp
  version: green   # ← Now green pods get traffic
```

**Alternative ways to do the same thing:**

```bash
# Method 1: Using kubectl patch (what we showed)
kubectl patch service app-service -p '{"spec":{"selector":{"version":"green"}}}'

# Method 2: Using kubectl edit (interactive)
kubectl edit service app-service
# Then manually change: selector.version from "blue" to "green"

# Method 3: Using a new YAML file
kubectl apply -f service-green.yaml
```

**Why this works:**
- Kubernetes Services use **label selectors** to find pods
- When you change the selector, the service immediately starts routing to different pods
- No restart needed, no downtime, instant switch!

### **Complete Blue-Green Example**

**Step-by-step with explanations:**

```bash
# 1. Check current service (should point to blue)
kubectl get service app-service -o yaml | grep selector
# Output: version: blue

# 2. Deploy green version
kubectl apply -f deployment-green.yaml

# 3. Wait for green to be ready
kubectl wait --for=condition=available deployment/app-green

# 4. Test green version directly (bypass service)
kubectl port-forward deployment/app-green 8080:80 &
curl http://localhost:8080  # Should show v2.0
kill %1  # Stop port-forward

# 5. Update service selector to route traffic to green deployment
kubectl patch service app-service -p '{"spec":{"selector":{"version":"green"}}}'

# 6. Test through service (should now show v2.0)
curl http://your-service-url

# 7. If everything works, remove blue
kubectl delete deployment app-blue

# 8. If problems, rollback instantly
# kubectl patch service app-service -p '{"spec":{"selector":{"version":"blue"}}}'
```

### **Which Pattern to Choose?**

| Situation | Best Pattern |
|-----------|-------------|
| High-risk changes | Blue-Green |
| Need instant rollback | Blue-Green |
| Limited resources | Canary |
| Want gradual feedback | Canary |
| Database changes | Rolling Update |
| Simple updates | Rolling Update |

## 🏆 What you learned

- ✅ Difference between Pods and Deployments
- ✅ How to scale applications horizontally
- ✅ Rolling updates without downtime
- ✅ Automatic rollback
- ✅ Health checks and monitoring
- ✅ Deployment strategies
- ✅ Deployment troubleshooting

---

## 🌟 Next Lesson

**Fantastic!** 🎉 You mastered Deployments!

Now go to [Lesson 5: ConfigMaps and Secrets](../05-configmaps-secrets/) where you'll learn how to manage configurations and sensitive data securely.