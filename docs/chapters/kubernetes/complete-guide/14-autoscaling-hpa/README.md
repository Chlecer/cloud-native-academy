# 📊 Lesson 14: Autoscaling & HPA

## 🎯 Objective
Master automatic scaling based on metrics like CPU, memory, and custom metrics.

## 🤔 Scaling Types

**Manual Scaling** - `kubectl scale`
**Horizontal Pod Autoscaler (HPA)** - Scale pods based on metrics
**Vertical Pod Autoscaler (VPA)** - Adjust resource requests/limits
**Cluster Autoscaler** - Scale nodes based on demand

## 🧪 Experiment 1: HPA with CPU

```cmd
kubectl apply -f hpa-cpu-example.yaml
```

## 🧪 Experiment 2: Load Testing

```cmd
kubectl apply -f load-generator.yaml
```

## 🧪 Experiment 3: Custom Metrics HPA

```cmd
kubectl apply -f hpa-custom-metrics.yaml
```

## 🚀 Complete Demo

```cmd
autoscaling-demo.bat
```

## 📈 HPA Algorithm

```
desiredReplicas = ceil[currentReplicas * (currentMetricValue / desiredMetricValue)]
```

## 💡 Best Practices

- ✅ Set appropriate resource requests
- ✅ Use multiple metrics
- ✅ Configure scale-up/down policies
- ✅ Monitor scaling events

---

## 🎯 Next Lesson

Go to [Lesson 15: Network Policies](../15-network-policies/)!