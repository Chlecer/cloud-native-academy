# 🗝 Lesson 5: ConfigMaps and Secrets

## 🎴 Objective
Learn how to manage configurations and sensitive data securely in Kubernetes.

## 🤨 Why ConfigMaps and Secrets?

**Problem:** Hard-coded configurations in containers
**Solution:** External configuration management

- **ConfigMaps** = Non-sensitive configuration data
- **Secrets** = Sensitive data (passwords, tokens, keys)

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

### ConfigMaps
- ✅ Use for non-sensitive configuration
- ✅ Environment-specific settings
- ✅ Application properties

### Secrets
- ✅ Use for passwords, tokens, keys
- ✅ Always base64 encoded
- ✅ Limited access with RBAC

---

## 🌲 Next Lesson

Go to [Lesson 6: Volumes - Persistence](../06-volumes-persistence/) to learn about data storage!