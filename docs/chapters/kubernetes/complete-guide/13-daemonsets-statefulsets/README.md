# 🔄 Lesson 13: DaemonSets & StatefulSets

## 🎯 Objective
Master specialized workload types for system services and stateful applications.

## 🤔 Workload Types Comparison

**Deployment** - Stateless applications (web servers)
**DaemonSet** - One pod per node (monitoring, logging)
**StatefulSet** - Stateful applications (databases, queues)

## 🧪 Experiment 1: DaemonSet

```cmd
kubectl apply -f daemonset-example.yaml
```

## 🧪 Experiment 2: StatefulSet

```cmd
kubectl apply -f statefulset-example.yaml
```

## 🧪 Experiment 3: StatefulSet with Storage

```cmd
kubectl apply -f statefulset-storage.yaml
```

## 🚀 Complete Demo

```cmd
workloads-demo.bat
```

## 🔍 Key Differences

### DaemonSet
- ✅ Runs on every node
- ✅ System-level services
- ✅ No scaling (follows nodes)

### StatefulSet
- ✅ Stable network identity
- ✅ Ordered deployment/scaling
- ✅ Persistent storage per pod

---

## 🎯 Next Lesson

Go to [Lesson 14: Autoscaling & HPA](../14-autoscaling-hpa/)!