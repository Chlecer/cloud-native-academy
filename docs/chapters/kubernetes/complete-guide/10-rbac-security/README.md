# 🔐 Lesson 10: RBAC & Security

## 🎯 Objective
Master Kubernetes security with Role-Based Access Control, Security Contexts, and Pod Security Standards.

## 🛡️ Security Fundamentals

### Authentication vs Authorization
- **Authentication** - Who are you? (Users, Service Accounts)
- **Authorization** - What can you do? (RBAC, ABAC)
- **Admission Control** - Policy enforcement

## 🧪 Experiment 1: Service Accounts

```cmd
kubectl apply -f service-account-example.yaml
```

## 🧪 Experiment 2: RBAC Roles

```cmd
kubectl apply -f rbac-example.yaml
```

## 🧪 Experiment 3: Security Contexts

```cmd
kubectl apply -f security-context-example.yaml
```

## 🧪 Experiment 4: Pod Security Standards

```cmd
kubectl apply -f pod-security-example.yaml
```

## 🚀 Complete Demo

```cmd
security-demo.bat
```

## 🔒 Security Best Practices

- ✅ Use least privilege principle
- ✅ Enable Pod Security Standards
- ✅ Scan images for vulnerabilities
- ✅ Use Network Policies
- ✅ Rotate secrets regularly

---

## 🎯 Next Lesson

Go to [Lesson 11: Namespaces & Resource Quotas](../11-namespaces-quotas/)!