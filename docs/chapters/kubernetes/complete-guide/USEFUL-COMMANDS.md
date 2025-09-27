# 🛠️ Useful Commands - Quick Reference

## 🔧 Basic Commands

### Cluster Information
```cmd
kubectl cluster-info                    # Cluster info
kubectl get nodes                       # List nodes
kubectl get namespaces                  # List namespaces
kubectl config current-context         # Current context
```

### General Resources
```cmd
kubectl get all                         # All resources
kubectl get all -A                      # All resources in all namespaces
kubectl api-resources                   # Available resource types
```

## 🐳 Pods

```cmd
REM Create and manage
kubectl run name --image=nginx          # Create quick pod
kubectl get pods                        # List pods
kubectl get pods -o wide                # With more details
kubectl describe pod name               # Complete details
kubectl delete pod name                 # Remove pod

REM Logs and debug
kubectl logs name                       # View logs
kubectl logs name -f                    # Follow logs
kubectl logs name --previous            # Previous container logs
kubectl exec -it name -- cmd            # Enter container (Windows)
kubectl exec -it name -- sh             # Enter container (Linux)
kubectl port-forward pod/name 8080:80   # Expose port locally
```

## 📈 Deployments

```cmd
REM Create and manage
kubectl create deployment name --image=nginx    # Create deployment
kubectl get deployments                         # List deployments
kubectl describe deployment name                # Details
kubectl delete deployment name                  # Remove

REM Scale
kubectl scale deployment name --replicas=5      # Scale to 5 replicas
kubectl autoscale deployment name --min=2 --max=10 --cpu-percent=80

REM Updates
kubectl set image deployment/name container=new-image  # Update image
kubectl rollout status deployment/name          # Rollout status
kubectl rollout history deployment/name         # History
kubectl rollout undo deployment/name            # Rollback
kubectl rollout restart deployment/name         # Restart deployment
```

## 🌐 Services

```cmd
REM Create and manage
kubectl expose pod name --port=80               # Expose pod
kubectl expose deployment name --port=80 --type=NodePort
kubectl get services                            # List services
kubectl describe service name                   # Details
kubectl delete service name                     # Remove

REM Service types
kubectl expose deployment name --type=ClusterIP    # Internal only
kubectl expose deployment name --type=NodePort     # External via port
kubectl expose deployment name --type=LoadBalancer # Load balancer
```

## 🔐 ConfigMaps and Secrets

```cmd
REM ConfigMaps
kubectl create configmap name --from-literal=key=value
kubectl create configmap name --from-file=file.txt
kubectl get configmaps
kubectl describe configmap name

REM Secrets
kubectl create secret generic name --from-literal=password=123456
kubectl create secret generic name --from-file=cert.pem
kubectl get secrets
kubectl describe secret name
```

## 💾 Volumes

```cmd
REM Persistent Volumes
kubectl get pv                          # List PVs
kubectl get pvc                         # List PVCs
kubectl describe pv name                 # PV details
kubectl describe pvc name                # PVC details
```

## 🏷️ Labels and Selectors

```cmd
REM Working with labels
kubectl get pods --show-labels           # Show labels
kubectl get pods -l app=web              # Filter by label
kubectl label pod name env=prod          # Add label
kubectl label pod name env-              # Remove label
```

## 🔍 Debug and Troubleshooting

```cmd
REM Detailed information
kubectl describe type/name               # Details of any resource
kubectl get events                       # Cluster events
kubectl get events --sort-by=.metadata.creationTimestamp

REM Logs
kubectl logs -l app=name                 # Logs from pods with label
kubectl logs deployment/name             # Deployment logs
kubectl logs name -c container           # Specific container logs

REM Resources and metrics
kubectl top nodes                        # Node resource usage
kubectl top pods                         # Pod resource usage

REM Connectivity
kubectl port-forward service/name 8080:80    # Port forward from service
kubectl proxy                                # Proxy to API server
```

## 🧹 Cleanup

```cmd
REM Remove resources
kubectl delete pod name                  # Remove specific pod
kubectl delete pods --all               # Remove all pods
kubectl delete deployment name          # Remove deployment
kubectl delete service name             # Remove service
kubectl delete all --all                # Remove everything (careful!)

REM Cleanup by label
kubectl delete pods -l app=name         # Remove pods with label
kubectl delete all -l app=name          # Remove everything with label
```

## 📁 YAML Files

```cmd
REM Apply and manage
kubectl apply -f file.yaml              # Apply file
kubectl apply -f folder/                # Apply entire folder
kubectl apply -f https://url/file.yaml  # Apply from internet

kubectl delete -f file.yaml             # Remove resources from file
kubectl diff -f file.yaml               # See differences

REM Generate YAML
kubectl create deployment name --image=nginx --dry-run=client -o yaml
kubectl get deployment name -o yaml     # Export existing YAML
```

## 🔄 Contexts and Namespaces

```cmd
REM Contexts
kubectl config get-contexts             # List contexts
kubectl config use-context name         # Switch context
kubectl config set-context --current --namespace=name

REM Namespaces
kubectl create namespace name           # Create namespace
kubectl get pods -n namespace           # List pods in namespace
kubectl config set-context --current --namespace=name  # Default namespace
```

## 🚀 Production Commands

```cmd
REM Backup
kubectl get all -o yaml > backup.yaml   # Backup resources

REM Monitoring
kubectl get pods -w                     # Watch pods in real time
kubectl get events -w                   # Watch events

REM Performance
kubectl top pods --sort-by=cpu          # Pods by CPU usage
kubectl top pods --sort-by=memory       # Pods by memory usage
```

## 💡 Useful Tips

### Useful Aliases (add to your PowerShell profile)
```powershell
Set-Alias k kubectl
function kgp { kubectl get pods }
function kgs { kubectl get services }
function kgd { kubectl get deployments }
function kdp { kubectl describe pod $args }
function kl { kubectl logs $args }
```

### PowerShell Profile Location
```powershell
# Check if profile exists
Test-Path $PROFILE

# Create profile if it doesn't exist
New-Item -Path $PROFILE -Type File -Force

# Edit profile
notepad $PROFILE
```

### Output Formats
```cmd
kubectl get pods -o wide               # More columns
kubectl get pods -o yaml               # Complete YAML
kubectl get pods -o json               # JSON
kubectl get pods -o jsonpath="{.items[*].metadata.name}"  # JSONPath
```

### Windows-specific Notes
- Use `cmd` or `PowerShell` instead of `sh` when exec into containers
- Use `findstr` instead of `grep` for text filtering
- Use `timeout /t 5 /nobreak >nul` instead of `sleep 5`
- Use `start /B` to run commands in background

---

## 🆘 In case of problems

1. **Check general status:** `kubectl get all`
2. **See events:** `kubectl get events --sort-by=.metadata.creationTimestamp`
3. **Describe resource:** `kubectl describe type/name`
4. **See logs:** `kubectl logs name`
5. **Test connectivity:** `kubectl port-forward`

**Remember:** Docker Desktop must be running with Kubernetes enabled!