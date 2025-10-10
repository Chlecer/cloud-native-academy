# 📊 Datadog Observability - Enterprise Monitoring Excellence

## 🎯 Objective
Master Datadog for enterprise-scale observability: APM, infrastructure monitoring, log management, and business metrics like Airbnb and Spotify use.

> **"You can't improve what you can't measure. You can't measure what you can't observe."**

## 📚 Key Concepts

### **APM (Application Performance Monitoring)**
Tracks how your application performs in real-time:
- **Response times** - How fast your app responds
- **Error rates** - How often things break
- **Throughput** - How many requests you handle
- **Dependencies** - What external services you use
- **Code-level insights** - Which functions are slow

### **Infrastructure Monitoring**
Tracks your servers and containers:
- CPU, memory, disk usage
- Network performance
- Container health
- Kubernetes cluster status

### **Log Management**
Collects and analyzes all application logs:
- Error messages
- User actions
- System events
- Security incidents

## 🏗️ How Datadog Works - What Goes Where?

### **Datadog Agent (Runs alongside your application)**
```
┌─────────────────┐    ┌─────────────────┐
│   Your App      │    │  Datadog Agent  │
│                 │    │                 │
│ - Business logic│    │ - Collects data │
│ - API endpoints │◄──►│ - Sends to Datadog │
│ - Database calls│    │ - No app changes│
└─────────────────┘    └─────────────────┘
```

**The Agent runs separately and:**
- Monitors CPU, memory, network
- Collects logs automatically
- No need to change your code

### **APM Library (Runs inside your application)**
```
┌─────────────────────────────┐
│        Your App             │
│                             │
│ ┌─────────────────────────┐ │
│ │    Datadog Library      │ │
│ │                         │ │
│ │ - Tracks response time  │ │
│ │ - Monitors DB queries   │ │
│ │ - Traces function calls │ │
│ └─────────────────────────┘ │
│                             │
│ Your business logic here    │
└─────────────────────────────┘
```

**The APM library:**
- Added as a dependency
- Instruments code automatically
- Measures function performance

### **Simple Summary:**
- **Agent** = Separate program that watches the server
- **APM Library** = Code you add to your app
- **Datadog Cloud** = Where data is sent and visualized

## 🛠️ Real Examples - How to Add Datadog to Your App

### **Step 1: Install Datadog Agent (runs on your server)**
```bash
# Download and install Datadog Agent
DD_API_KEY=your-api-key bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Agent automatically starts monitoring:
# - CPU usage, Memory usage, Network traffic, Disk usage
```

### **Step 2: Add APM to Your Application**

#### **Spring Boot Example**
```xml
<!-- pom.xml - Add this dependency -->
<dependency>
    <groupId>com.datadoghq</groupId>
    <artifactId>dd-java-agent</artifactId>
    <version>1.18.0</version>
</dependency>
```

```java
// Application.java
@SpringBootApplication
public class MyApp {
    public static void main(String[] args) {
        // Tell Datadog about your app
        System.setProperty("dd.service", "my-spring-app");
        System.setProperty("dd.env", "production");
        System.setProperty("dd.version", "1.0.0");
        
        SpringApplication.run(MyApp.class, args);
    }
}

@RestController
public class UserController {
    @GetMapping("/users/{id}")
    public User getUser(@PathVariable Long id) {
        // Datadog automatically tracks:
        // - How long this method takes
        // - If it throws errors
        // - How many times it's called
        
        return userService.findById(id);
    }
}
```

```bash
# Run your app with Datadog agent
java -javaagent:dd-java-agent.jar -jar my-app.jar
```

#### **.NET Example**
```bash
# Add Datadog NuGet package
dotnet add package Datadog.Trace
```

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
var app = builder.Build();

// Set environment variables for Datadog
Environment.SetEnvironmentVariable("DD_SERVICE", "my-dotnet-app");
Environment.SetEnvironmentVariable("DD_ENV", "production");
Environment.SetEnvironmentVariable("DD_VERSION", "1.0.0");

app.MapControllers();
app.Run();
```

```bash
# Run with Datadog
export DD_TRACE_ENABLED=true
dotnet run
```

### **What You Get Automatically**
```
📊 Application Performance:
├── Average response time: 245ms
├── Error rate: 0.1%
├── Requests per minute: 1,247
└── Slowest endpoints: /users/search (1.2s)

🖥️ Infrastructure:
├── CPU usage: 45%
├── Memory usage: 2.1GB / 4GB
├── Disk usage: 67%
└── Network: 15MB/s in, 8MB/s out

🚨 Alerts:
├── High error rate on /payment endpoint
├── Database connection pool exhausted
└── Memory usage above 80%
```

### **Key Point: It's Mostly Automatic**

1. **Install Agent** → Monitors server automatically
2. **Add library** → Tracks app performance automatically  
3. **Set 3 variables** → Identifies your app in Datadog
4. **Run app** → Data flows to Datadog dashboard

**No complex configuration needed for basic monitoring!**

## 🌟 Enterprise Usage

**Companies using Datadog:** Airbnb (150M+ users), Spotify (400M+ users), Samsung, Peloton, WhatsApp (2B+ users)

**Key enterprise features:** Full-stack observability, real-time alerting, business metrics correlation, compliance, cost optimization

## 🏗️ Infrastructure Deployment Options

### **Where Can You Run Datadog Agent?**

Datadog Agent can run in different environments:

#### **1. Native/Bare Metal Server**
```bash
# Simple installation on Linux/Windows server
DD_API_KEY=your-key bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Agent runs as system service
# Monitors: CPU, memory, disk, network, processes
# Good for: Traditional servers, VMs
```

#### **2. Docker Container**
```bash
# Run Datadog Agent in Docker
docker run -d --name datadog-agent \
  -e DD_API_KEY=your-api-key \
  -e DD_SITE="datadoghq.eu" \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /proc/:/host/proc/:ro \
  -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
  gcr.io/datadoghq/agent:7

# Agent monitors: Host + all Docker containers
# Good for: Docker Compose, single Docker host
```

#### **3. Kubernetes Cluster**
```yaml
# Deploy as DaemonSet (runs on every node)
# Monitors: All pods, nodes, cluster resources
# Good for: Production Kubernetes environments
```

### **Which Should You Choose?**

```
🖥️ Native Server:
✅ Simple setup
✅ Direct host access
❌ Manual management
❌ No container visibility

Use when: Traditional infrastructure, VMs

🐳 Docker:
✅ Container awareness
✅ Easy deployment
✅ Portable configuration
❌ Single host only

Use when: Docker Compose, development

☸️ Kubernetes:
✅ Cluster-wide monitoring
✅ Auto-scaling
✅ Enterprise features
❌ More complex setup

Use when: Production K8s, microservices
```

---

## 🔧 Configuration Examples

### **What is Infrastructure Monitoring Configuration?**

The configuration tells Datadog Agent:
- **What to monitor** (CPU, memory, containers, logs)
- **How to connect** (API keys, endpoints)
- **Where to send data** (Datadog EU/US servers)
- **Security settings** (permissions, access controls)

**Think of it as:** Instructions for the Datadog Agent on what to watch and how to report back.

### **Why Do We Need This Configuration?**

```
Without Config:           With Config:
┌─────────────────┐      ┌─────────────────┐
│ Datadog Agent   │      │ Datadog Agent   │
│                 │      │                 │
│ ❌ No API key    │      │ ✅ Has API key   │
│ ❌ Doesn't know  │      │ ✅ Monitors CPU   │
│    what to watch│      │ ✅ Collects logs │
│ ❌ Can't send    │      │ ✅ Sends to DD   │
│    data anywhere│      │ ✅ Secure access │
└─────────────────┘      └─────────────────┘
```

### **Docker Deployment Example**

```yaml
# docker-compose.yml
version: '3'
services:
  datadog:
    image: gcr.io/datadoghq/agent:7
    environment:
      - DD_API_KEY=your-api-key
      - DD_SITE=datadoghq.eu
      - DD_LOGS_ENABLED=true
      - DD_APM_ENABLED=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /proc/:/host/proc/:ro
      - /sys/fs/cgroup/:/host/sys/fs/cgroup:ro
    
  your-app:
    image: your-spring-app:latest
    environment:
      - DD_AGENT_HOST=datadog
    depends_on:
      - datadog
```

**This Docker setup:**
- Runs Datadog Agent in container
- Monitors host system + all containers
- Collects logs from all services
- Your app sends traces to Agent

---

### **Kubernetes Deployment Example**

```yaml
# datadog-agent.yaml - Basic Kubernetes deployment
apiVersion: v1
kind: Secret
metadata:
  name: datadog-secret
type: Opaque
data:
  api-key: <your-base64-encoded-api-key>

---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: datadog-agent
spec:
  selector:
    matchLabels:
      app: datadog-agent
  template:
    metadata:
      labels:
        app: datadog-agent
    spec:
      containers:
      - name: datadog-agent
        image: gcr.io/datadoghq/agent:7.48.0
        env:
        - name: DD_API_KEY
          valueFrom:
            secretKeyRef:
              name: datadog-secret
              key: api-key
        - name: DD_SITE
          value: "datadoghq.eu"
        - name: DD_LOGS_ENABLED
          value: "true"
        - name: DD_APM_ENABLED
          value: "true"
        volumeMounts:
        - name: dockersocket
          mountPath: /var/run/docker.sock
          readOnly: true
        - name: procdir
          mountPath: /host/proc
          readOnly: true
      volumes:
      - name: dockersocket
        hostPath:
          path: /var/run/docker.sock
      - name: procdir
        hostPath:
          path: /proc
```

**This configuration:**
- Deploys Datadog Agent on every Kubernetes node
- Monitors containers and host metrics
- Collects logs from all pods
- Enables APM for application tracing
- Sends data to Datadog EU servers

## 🎯 Next Steps

1. **Start Simple**: Install Agent + add library to one app
2. **Expand Gradually**: Add more applications and services
3. **Configure Alerts**: Set up notifications for critical issues
4. **Create Dashboards**: Build custom views for your team
5. **Optimize**: Fine-tune monitoring based on your needs