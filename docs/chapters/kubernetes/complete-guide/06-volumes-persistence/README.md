# 💾 Lesson 6: Volumes - Persistence

## 🎯 Objective
Learn how to persist data in Kubernetes beyond pod lifecycle.

## 🤔 Why Volumes?

**Problem:** Containers are ephemeral - data is lost when pod dies
**Solution:** Volumes provide persistent storage

## 📊 Volume Types

- **emptyDir** - Temporary storage (pod lifetime)
- **hostPath** - Node's filesystem (development only)
- **persistentVolume** - Persistent storage (production)

## 🧪 Experiment 1: EmptyDir Volume

```cmd
kubectl apply -f emptydir-example.yaml
```

Test shared storage:
```cmd
kubectl exec -it volume-demo -c writer -- sh -c "echo 'Hello from writer' > /shared/message.txt"
kubectl exec -it volume-demo -c reader -- cat /shared/message.txt
```

## 🧪 Experiment 2: Persistent Volume

```cmd
kubectl apply -f persistent-volume-example.yaml
```

## 🧪 Experiment 3: Database with Persistence

```cmd
kubectl apply -f database-example.yaml
```

## 🚀 Complete Demo

```cmd
volumes-demo.bat
```

## 💡 Best Practices

- ✅ Use PersistentVolumes for production
- ✅ Backup important data regularly
- ✅ Choose appropriate storage class

---

## 🎯 Next Lesson

Go to [Lesson 7: Advanced Networking](../07-advanced-networking/) to learn about Ingress and network policies!