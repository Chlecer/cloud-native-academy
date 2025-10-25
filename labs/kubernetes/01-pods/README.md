# Lab 01: Working with Kubernetes Pods

> **Duration**: 30-45 minutes  
> **Level**: Beginner  
> **Prerequisites**: Minikube installed, kubectl configured

## Learning Objectives

By the end of this lab, you will be able to:
- Create and manage Kubernetes Pods
- Check Pod status and logs
- Understand the Pod lifecycle
- Configure environment variables in Pods

## Lab Tasks

### Task 1: Start the Environment

```bash
# Start Minikube
minikube start

# Check cluster status
kubectl get nodes
```

### Task 2: Create Your First Pod

1. Create a file named `nginx-pod.yaml` with the following content:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.19.10
    ports:
    - containerPort: 80
```

2. Apply the configuration:

```bash
kubectl apply -f nginx-pod.yaml
```

3. Check the Pod status:

```bash
kubectl get pods
kubectl describe pod nginx-pod
```

### Task 3: Access Pod Logs

```bash
# Check container logs
kubectl logs nginx-pod

# Stream logs in real-time
kubectl logs -f nginx-pod
```

### Task 4: Execute Commands in the Pod

```bash
# Open a shell in the container
kubectl exec -it nginx-pod -- /bin/bash

# Execute a specific command
kubectl exec nginx-pod -- nginx -v
```

### Task 5: Configure Environment Variables

1. Update `nginx-pod.yaml` to include environment variables:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.19.10
    env:
    - name: ENVIRONMENT
      value: "development"
    - name: LOG_LEVEL
      value: "debug"
```

2. Apply the changes:

```bash
kubectl apply -f nginx-pod.yaml

# Verify environment variables
kubectl exec nginx-pod -- env | grep ENVIRONMENT
```

## Optional Challenges

1. **Easy Challenge**: Create a Pod that runs the command `sleep 3600`
2. **Medium Challenge**: Create a Pod with two containers (nginx and redis) sharing a volume
3. **Hard Challenge**: Configure a liveness probe for the nginx container

## Cleanup

```bash
# Delete the Pod
kubectl delete pod nginx-pod

# Verify the Pod is removed
kubectl get pods
```

## Solutions

Solutions are available in the [solutions/](./solutions/) directory. Try to solve the challenges before checking them.

## Next Steps

Proceed to the next lab: [Deployments and Scaling](../02-deployments/)

## Additional Resources

- [Kubernetes Official Documentation - Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Kubernetes By Example - Pods](https://kubebyexample.com/concept/pods)
- [Interactive Tutorial - Managing Pods](https://kubernetes.io/docs/tutorials/kubernetes-basics/explore/explore-intro/)
