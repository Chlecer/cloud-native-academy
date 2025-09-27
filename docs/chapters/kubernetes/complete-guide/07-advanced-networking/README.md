# 🌍 Lesson 7: Advanced Networking

## 🎯 Objective
Learn advanced networking concepts including Ingress and network policies.

## 🤔 Why Advanced Networking?

**Beyond Basic Services:**
- **Ingress** - HTTP/HTTPS routing and load balancing
- **Network Policies** - Security and traffic control
- **DNS** - Service discovery

## 🧪 Experiment 1: Ingress Controller

Enable Ingress in Docker Desktop:
```cmd
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

Deploy applications:
```cmd
kubectl apply -f ingress-example.yaml
```

## 🧪 Experiment 2: Multiple Services

```cmd
kubectl apply -f multi-service-ingress.yaml
```

Test routing:
- http://localhost/app1
- http://localhost/app2

## 🚀 Complete Demo

```cmd
networking-demo.bat
```

## 🔒 Network Policies

```cmd
kubectl apply -f network-policy-example.yaml
```

## 💡 Key Concepts

- **Ingress** - Layer 7 load balancing
- **Network Policies** - Firewall rules for pods
- **DNS** - Automatic service discovery

---

## 🎯 Next Lesson

Go to [Lesson 8: Monitoring](../08-monitoring/) to learn about observability!