# 📦 Lesson 16: Helm Charts - Package Management

## 🎯 Objective
Master Helm for Kubernetes package management, templating, and application lifecycle.

## 🤔 Why Helm?

**Problem:** Managing complex Kubernetes applications with multiple YAML files
**Solution:** Helm packages (charts) with templating and versioning

## 📦 Helm Concepts

- **Chart** - Package of Kubernetes resources
- **Release** - Instance of a chart running in cluster
- **Repository** - Collection of charts
- **Values** - Configuration for charts

## 🧪 Experiment 1: Install Helm

```cmd
# Download Helm from https://helm.sh/docs/intro/install/
# Or use chocolatey: choco install kubernetes-helm
helm version
```

## 🧪 Experiment 2: Using Public Charts

```cmd
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo nginx
helm install my-nginx bitnami/nginx
```

## 🧪 Experiment 3: Create Custom Chart

```cmd
helm create webapp-chart
```

## 🧪 Experiment 4: Deploy with Values

```cmd
helm install webapp ./webapp-chart -f custom-values.yaml
```

## 🚀 Complete Demo

```cmd
helm-demo.bat
```

## 💡 Best Practices

- ✅ Use semantic versioning
- ✅ Template everything configurable
- ✅ Provide good default values
- ✅ Document your charts

---

## 🎯 Next Lesson

**Congratulations!** You've mastered Kubernetes package management with Helm!