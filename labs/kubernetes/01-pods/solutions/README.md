# Challenge Solutions

## Easy Challenge: Sleep Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sleep-pod
spec:
  containers:
  - name: sleep
    image: busybox
    command: ["sleep", "3600"]
```

## Medium Challenge: Two Containers with Shared Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-volume-pod
spec:
  volumes:
  - name: shared-data
    emptyDir: {}
  containers:
  - name: nginx
    image: nginx:1.19.10
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
  - name: redis
    image: redis:6.2
    volumeMounts:
    - name: shared-data
      mountPath: /data
```

## Hard Challenge: Liveness Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-liveness
spec:
  containers:
  - name: nginx
    image: nginx:1.19.10
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
```

## How to Apply the Solutions

1. Save each configuration to a separate file (e.g., `sleep-pod.yaml`)
2. Apply the configuration:
   ```bash
   kubectl apply -f sleep-pod.yaml
   ```
3. Check the status:
   ```bash
   kubectl get pods
   kubectl describe pod <pod-name>
   ```

## Tips and Explanations

1. **Shared Volumes**:
   - `emptyDir` creates an empty directory shared between containers
   - Data persists as long as the Pod exists

2. **Liveness Probe**:
   - Checks if the container is healthy
   - Restarts the container if the check fails
   - `initialDelaySeconds` allows time for container startup
   - `periodSeconds` sets the check frequency

3. **Debugging Commands**:
   ```bash
   # Check Pod events
   kubectl describe pod <pod-name>
   
   # View container logs
   kubectl logs <pod-name> -c <container-name>
   
   # Open a shell in the container
   kubectl exec -it <pod-name> -- /bin/sh
   ```

## Next Steps

Continue exploring Kubernetes features with advanced labs:
- [Deployments and Scaling](../02-deployments/)
- [Services and Service Discovery](../03-services/)
- [ConfigMaps and Secrets](../04-configuration/)
