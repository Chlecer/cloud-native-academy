# ⚡ Quick Start Labs

> **Simple exercises to get you started**

## 🎯 Basic Exercises

### 🏆 **Exercise 1: Simple Web Server**
```bash
echo "Hello World!" > index.html
python -m http.server 8000
# Open browser: http://localhost:8000
```
**What you learned:** Basic web servers and localhost

### 🏆 **Exercise 2: Basic Git Usage**
```bash
git init
git add .
git commit -m "First commit"
```
**What you learned:** Version control basics

### 🏆 **Exercise 3: Docker Container**
```bash
echo 'FROM nginx' > Dockerfile
echo 'COPY index.html /usr/share/nginx/html/' >> Dockerfile
docker build -t my-app .
docker run -p 8080:80 my-app
```
**What you learned:** Containerization basics

### 🏆 **Exercise 4: Kubernetes Deployment**
```yaml
# Save as app.yaml:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: nginx
        ports:
        - containerPort: 80
```
```bash
kubectl apply -f app.yaml
```
**What you learned:** Basic Kubernetes deployments

## 🎯 How to Use These

1. Pick an exercise
2. Follow the commands
3. See what happens
4. Move to the next one
5. Read the related chapters for deeper understanding

**Goal: Get familiar with the tools through practice.**