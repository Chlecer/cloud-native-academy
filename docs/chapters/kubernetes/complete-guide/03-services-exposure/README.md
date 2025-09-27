# 🌊 Lesson 3: Services - Exposing Applications

## 🎩 Objective
Learn how to expose Pods and create stable communication between applications.

## 🤯 Why do we need Services?

**Problem:** Pods have dynamic IPs and can die/be reborn
**Solution:** Services create a "fixed address" to access Pods

Think of it this way:
- **Pod** = Your house (can change address)
- **Service** = Your ZIP code (always the same, redirects to your current house)

## 🎳 Experiment 1: ClusterIP (Internal)

### First, create some pods
```bash
kubectl run web1 --image=nginx:alpine --labels="app=web"
kubectl run web2 --image=nginx:alpine --labels="app=web"
kubectl run web3 --image=nginx:alpine --labels="app=web"
```

### Wait for pods to be ready
```bash
kubectl wait --for=condition=Ready pod -l app=web --timeout=60s
```

### Check the pods' IPs
```bash
kubectl get pods -o wide
```
**The `-o wide` flag shows additional columns like IP addresses and nodes**

**Observe:** Each pod has a different IP

### Create ClusterIP Service
```bash
kubectl apply -f service-clusterip.yaml
```

### Check the service and endpoints
```bash
kubectl get services
kubectl get endpoints web-service
kubectl describe service web-service
```

### Test internal access
```bash
# Create temporary pod for testing
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://web-service
```
**Result:** Nginx page from one of the pods

## 🎆 Experiment 2: NodePort (External)

### Clean up previous service (if needed)
```bash
kubectl delete service web-service
```

### Create NodePort Service
```bash
kubectl apply -f service-nodeport.yaml
```

### Test external access
```bash
curl http://localhost:30081
```
**Or open http://localhost:30081 in browser**

## ⚖️ Experiment 3: LoadBalancer

### Clean up previous service
```bash
kubectl delete service web-nodeport
```

### Create LoadBalancer Service
```bash
kubectl apply -f service-loadbalancer.yaml
```

### Check the difference
```bash
kubectl get services
```

**Key differences:**
- **NodePort:** You specify the port (30000-32767)
- **LoadBalancer:** Kubernetes assigns a port automatically
- **In Production:** LoadBalancer gets external IP from cloud provider
- **In Docker Desktop:** Shows `localhost` as EXTERNAL-IP with auto-assigned port

### Test LoadBalancer access
```bash
# Access via localhost (Docker Desktop)
curl http://localhost:31777
```
**Note:** Your port will be different - check `kubectl get services`

**Why use LoadBalancer?**
- ✅ **Production ready** - Gets real external IP in AWS/GCP/Azure
- ✅ **No port management** - Cloud handles port allocation
- ✅ **Better for users** - Clean URLs without port numbers

## 🎭 Experiment 4: Complete Application

### Apply deployment + service
```bash
kubectl apply -f complete-app.yaml
```

### Test load balancing
```powershell
# Windows PowerShell - Make multiple requests
1..5 | ForEach-Object { 
    $response = Invoke-WebRequest -Uri http://localhost:30090 -UseBasicParsing
    $response.Content | Select-String "Pod Name:"
    Write-Host "---"
}
```

**Simple test to see different pods:**
```powershell
# Execute multiple times to see different pods
Invoke-WebRequest http://localhost:30090 | Select-Object -ExpandProperty Content | Select-String "Pod Name:"
Invoke-WebRequest http://localhost:30090 | Select-Object -ExpandProperty Content | Select-String "Pod Name:"
Invoke-WebRequest http://localhost:30090 | Select-Object -ExpandProperty Content | Select-String "Pod Name:"
```

**Or use curl.exe directly:**
```cmd
curl.exe http://localhost:30090 | findstr "Pod Name:"
curl.exe http://localhost:30090 | findstr "Pod Name:"
curl.exe http://localhost:30090 | findstr "Pod Name:"
```

**Observe:** Different pod names/IPs appear (load balancing working!)

**If you see the same pod repeatedly:**
```bash
# Check if all pods are running
kubectl get pods -l app=webapp -o wide

# Ensure 3 replicas are running
kubectl scale deployment webapp-deployment --replicas=3

# Wait for all pods to be ready
kubectl wait --for=condition=Available deployment/webapp-deployment --timeout=60s

# Restart deployment to reset load balancing
kubectl rollout restart deployment/webapp-deployment
```

**Note:** Kubernetes load balancing may stick to the same pod for a session. This is normal behavior.

## 🧩 Understanding Service Types

### ClusterIP (Default)
- ✅ **Use:** Internal communication between pods
- ✅ **Access:** Only within the cluster
- ✅ **Example:** Database, internal APIs

### NodePort
- ✅ **Use:** Expose application externally
- ✅ **Access:** `localhost:port` (30000-32767)
- ✅ **Example:** Web applications, public APIs

### LoadBalancer
- ✅ **Use:** Production with cloud providers
- ✅ **Access:** Automatic external IP
- ✅ **Example:** Applications on AWS, GCP, Azure

### ExternalName
- ✅ **Use:** Map external services
- ✅ **Access:** DNS redirection
- ✅ **Example:** External database

## 🎰 Practical Exercises

Run the complete script:
```bash
test-services.bat
```

**Clean up everything:**
```bash
cleanup-services.bat
```

## 🛠️ Essential Commands

| Command | Function |
|---------|----------|
| `kubectl expose pod name --port=80` | Create service quickly |
| `kubectl get services` | List services |
| `kubectl describe service name` | Service details |
| `kubectl delete service name` | Remove service |
| `kubectl get endpoints` | View service endpoints |

## 🔭 Advanced Concepts

### Selectors and Labels
**How Services find Pods:**
```yaml
selector:
  app: web      # Selects pods with label app=web
  version: v1   # AND label version=v1
```
**Example:** Only pods with BOTH labels `app=web` AND `version=v1` will receive traffic.

```bash
# Create pods with different labels
kubectl run pod1 --image=nginx --labels="app=web,version=v1"     # ✅ Selected
kubectl run pod2 --image=nginx --labels="app=web,version=v2"     # ❌ Not selected
kubectl run pod3 --image=nginx --labels="app=api,version=v1"     # ❌ Not selected
```

### Multiple Ports
**Expose different ports from the same pods:**
```yaml
ports:
- port: 80        # Service port 80
  targetPort: 8080 # Goes to pod port 8080
  name: http
- port: 443       # Service port 443
  targetPort: 8443 # Goes to pod port 8443
  name: https
```
**Use case:** Web app with HTTP (8080) and HTTPS (8443) in same pod.

### Session Affinity
**Control which pod handles requests:**
```yaml
spec:
  sessionAffinity: ClientIP  # Same client always goes to same pod
```
**Default:** `None` - random load balancing
**ClientIP:** Same IP address always goes to same pod

**When to use:**
- Shopping carts stored in pod memory
- User sessions not shared between pods
- Stateful applications

## 🕵️ Debug and Troubleshooting

### Service doesn't work
```bash
# Check if pods exist
kubectl get pods -l app=web

# Check endpoints
kubectl get endpoints web-service

# Check labels
kubectl get pods --show-labels
```

### Test connectivity
```bash
# Inside the cluster
kubectl run debug --image=busybox --rm -it -- sh
# wget -qO- http://service-name

# Externally
curl http://localhost:nodePort
```

### Check internal DNS
```bash
kubectl exec -it pod-name -- nslookup service-name
```

## 🎯 Common Patterns

### Frontend + Backend
```yaml
# Frontend (NodePort)
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
  - port: 80
    nodePort: 30080

---
# Backend (ClusterIP)
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - port: 8080
```

## 🏅 What you learned

- ✅ Why Services are necessary
- ✅ Types of Services and when to use them
- ✅ How to expose applications internally and externally
- ✅ Automatic load balancing
- ✅ Selectors and labels
- ✅ Connectivity debugging

---

## 🌈 Next Lesson

**Excellent!** 🎉 You mastered Services!

Now go to [Lesson 4: Deployments - Scalability](../04-deployments-scalability/) where you'll learn how to manage multiple replicas and updates without downtime.