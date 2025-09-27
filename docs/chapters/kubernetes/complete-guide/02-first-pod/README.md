# ⚡ Lesson 2: First Pod - Understanding the Basics

## 🎪 Objective
Completely understand what Pods are and how to work with them in practice.

## 🔮 What is a Pod?

**Pod = Smallest unit in Kubernetes**

Think of it this way:
- **Container** = A running process
- **Pod** = An "envelope" that can have 1 or more containers
- **99% of cases** = 1 Pod = 1 Container

## 🎭 Experiment 1: Simple Pod

### Create pod via command
```bash
kubectl run my-nginx --image=nginx:alpine --port=80
```

### Check what happened
```bash
kubectl get pods
kubectl describe pod my-nginx
```

**What to observe:**
- Pod Status
- Internal IP
- Events

### Access the pod
```bash
kubectl port-forward pod/my-nginx 8080:80
```
Open http://localhost:8080

### Clean up
```bash
kubectl delete pod my-nginx
```

## 🎨 Experiment 2: Pod via YAML

Create the file `detailed-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-example
  labels:
    app: webapp
    version: v1
    environment: development
spec:
  containers:
  - name: web-server
    image: nginx:alpine
    ports:
    - containerPort: 80
      name: http
    env:
    - name: ENVIRONMENT
      value: "development"
    - name: VERSION
      value: "1.0"
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
  restartPolicy: Always
```

### Apply and test
```bash
kubectl apply -f detailed-pod.yaml
kubectl get pods
kubectl describe pod webapp-example
```

### Check environment variables
```bash
# Windows PowerShell
kubectl exec webapp-example -- env | Select-String -Pattern "(ENVIRONMENT|VERSION)"

# Linux/macOS
kubectl exec webapp-example -- env | grep -E "(ENVIRONMENT|VERSION)"

# Universal alternative
kubectl exec webapp-example -- printenv ENVIRONMENT
kubectl exec webapp-example -- printenv VERSION
```

## 🔍 Experiment 3: Logs and Debug

### View pod logs
```bash
kubectl logs webapp-example
```

### Execute commands inside the pod
```bash
kubectl exec -it webapp-example -- sh
```
**Inside the container:**
```bash
ps aux          # View processes
ls /etc/nginx   # Explore files
exit           # Exit
```

### Detailed information
```bash
kubectl describe pod webapp-example
```

## 🎪 Experiment 4: Multi-Container Pod

**Real scenario:** Web application + log collector

Create `multi-container-pod.yaml` and apply:
```bash
kubectl apply -f multi-container-pod.yaml
```

### Check containers
```bash
kubectl get pod app-with-sidecar
kubectl describe pod app-with-sidecar
```

### View logs from specific containers
```bash
# Logs from main container
kubectl logs app-with-sidecar -c web-app

# Logs from sidecar
kubectl logs app-with-sidecar -c log-collector
```



## 🎲 Practical Exercises

Run the exercises script:
```bash
practical-exercises.bat
```

## 🧠 Important Concepts

### Labels and Selectors
```bash
# Search pods by label
kubectl get pods -l app=webapp
kubectl get pods -l environment=development
```

### Pod States
- **Pending** - Being created
- **Running** - Working
- **Succeeded** - Finished successfully
- **Failed** - Finished with error
- **Unknown** - Unknown state

### Restart Policies
- **Always** - Always restarts (default)
- **OnFailure** - Restarts only if it fails
- **Never** - Never restarts

## ⚙️ Essential Commands

| Command | Function |
|---------|----------|
| `kubectl run name --image=image` | Create pod quickly |
| `kubectl apply -f file.yaml` | Create pod from file |
| `kubectl get pods` | List pods |
| `kubectl describe pod name` | Pod details |
| `kubectl logs name` | View logs |
| `kubectl exec -it name -- command` | Execute command |
| `kubectl delete pod name` | Remove pod |

## 🔧 Troubleshooting

### Pod stays in Pending
```bash
kubectl describe pod nome
# Check Events in output
```
**Common causes:**
- Image not found
- Insufficient resources
- Network problems

### Pod keeps restarting
```bash
kubectl logs nome --previous
```
**Common causes:**
- Application crashing
- Health checks failing
- Incorrect configuration

### Container doesn't start
```bash
kubectl describe pod nome
kubectl logs nome
```

## 🏆 What you learned

- ✅ What Pods are and how they work
- ✅ Create Pods via command and YAML
- ✅ Configure resources, variables and labels
- ✅ Work with logs and debug
- ✅ Multi-container Pods (sidecar pattern)
- ✅ Basic troubleshooting

---

## 🚀 Next Lesson

**Great work!** 🎉 You mastered Pods!

Now go to [Lesson 3: Services - Exposing Applications](../03-services-exposure/) where you'll learn how to expose your Pods to the outside world.