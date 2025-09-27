# 🔧 Lesson 1: Setup and Verification

## 🎯 Objective
Verify that your Kubernetes environment is working and learn basic commands.

## 📋 Initial Checklist

### 1. Check Docker Desktop
```cmd
docker --version
```
**Expected result:** Docker version (e.g., Docker version 24.0.7)

### 2. Check Kubernetes
```cmd
kubectl version --client
```
**Expected result:** kubectl version

### 3. Check Local Cluster
```cmd
kubectl cluster-info
```
**Expected result:** 
```
Kubernetes control plane is running at https://kubernetes.docker.internal:6443
CoreDNS is running at https://kubernetes.docker.internal:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

## 🧪 Practical Test 1: Exploring the Cluster

### See all nodes
```cmd
kubectl get nodes
```
**What you'll see:** A node called `docker-desktop`

### See detailed node information
```cmd
kubectl describe node docker-desktop
```
**What to learn:** Capacity, operating system, Kubernetes version

## 🧪 Practical Test 2: Exploring Namespaces

### See all namespaces
```cmd
kubectl get namespaces
```
**What you'll see:**
- `default` - where your resources go by default
- `kube-system` - Kubernetes system resources
- `kube-public` - public resources
- `kube-node-lease` - node lease information

### See system pods
```cmd
kubectl get pods -n kube-system
```
**What to learn:** Kubernetes runs many components as pods

## 🧪 Practical Test 3: First Useful Command

### See all resources in default namespace
```cmd
kubectl get all
```
**Expected result:** `No resources found in default namespace.`

### Create a test file
Create the file `connection-test.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: connection-test
  labels:
    app: test
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
  restartPolicy: Never
```

### Apply the file
```cmd
kubectl apply -f connection-test.yaml
```

### Check if it worked
```cmd
kubectl get pods
```
**Expected result:** Pod `connection-test` with status `Running`

### Test connectivity
```cmd
kubectl port-forward pod/connection-test 8080:80
```
Open http://localhost:8080 in browser - you should see the Nginx page!

### Clean up the test
```cmd
kubectl delete pod connection-test
```

## 🚀 Automated Test

To test everything at once, run:
```cmd
test-commands.bat
```

## 🎓 What you learned

- ✅ How to verify if Kubernetes is working
- ✅ Basic kubectl commands
- ✅ How to create your first Pod
- ✅ How to expose an application locally
- ✅ How to clean up resources

## 🔍 Essential Commands Learned

| Command | What it does |
|---------|-------------|
| `kubectl get nodes` | List cluster nodes |
| `kubectl get pods` | List pods |
| `kubectl apply -f file.yaml` | Create resources from file |
| `kubectl port-forward` | Expose port locally |
| `kubectl delete pod name` | Remove a pod |

## ❓ Troubleshooting

**Problem:** `kubectl` is not recognized
**Solution:** Check if Docker Desktop is running and Kubernetes is enabled

**Problem:** Pod stays in `Pending`
**Solution:** Wait a few seconds, it might be downloading the image

**Problem:** Port-forward doesn't work
**Solution:** Check if the pod is `Running` first

---

## 🎯 Next Lesson

**Congratulations!** 🎉 Your environment is working!

Now go to [Lesson 2: First Pod](../02-first-pod/) where you'll learn everything about Pods in detail.