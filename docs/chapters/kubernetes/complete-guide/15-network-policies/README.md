# 🛡️ Lesson 15: Network Policies

## 🎯 Objective
Master network security with Kubernetes Network Policies for traffic control and micro-segmentation.

## 🤔 Why Network Policies?

**Default Behavior** - All pods can communicate with all pods
**Network Policies** - Firewall rules for Kubernetes
**Zero Trust** - Deny by default, allow explicitly

## 🧪 Experiment 1: Default Deny Policy

```cmd
kubectl apply -f default-deny.yaml
```

## 🧪 Experiment 2: Allow Specific Traffic

```cmd
kubectl apply -f allow-specific.yaml
```

## 🧪 Experiment 3: Multi-tier Application

```cmd
kubectl apply -f multi-tier-policies.yaml
```

## 🚀 Complete Demo

```cmd
network-policies-demo.bat
```

## 🔒 Policy Types

- **Ingress** - Incoming traffic to pods
- **Egress** - Outgoing traffic from pods
- **Both** - Bidirectional control

---

## 🎯 Next Lesson

Go to [Lesson 16: Custom Resources](../16-custom-resources/)!