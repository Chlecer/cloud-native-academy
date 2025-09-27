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

### Blue-Green Deployment
```bash
# Create green version
kubectl apply -f deployment-green.yaml

# Test green
kubectl port-forward deployment/app-green 8080:80

# Switch service to green
kubectl patch service app-service -p '{"spec":{"selector":{"version":"green"}}}'

# Remove blue
kubectl delete deployment app-blue
```

### Canary Deployment
```bash
# 90% v1, 10% v2
kubectl scale deployment app-v1 --replicas=9
kubectl scale deployment app-v2 --replicas=1
```

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