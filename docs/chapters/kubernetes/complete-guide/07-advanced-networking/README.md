# 🌍 Lesson 7: Advanced Networking

## 🎯 Objective
Master enterprise networking patterns: multi-tenant ingress, zero-trust network policies, service mesh integration, and production-grade traffic management.

## 🚨 The Real Problems

**Airbnb's Challenge:** 15,000+ microservices need secure communication without performance bottlenecks
**Netflix's Issue:** Multi-region traffic routing with 99.99% uptime requirements
**Goldman Sachs Problem:** Zero-trust networking with strict compliance and audit trails
**Your Challenge:** How do you route traffic, enforce security, and maintain performance at scale?

## 🏢 Why Basic Services Aren't Enough

### The LoadBalancer Limitation
**Problem:** Each service gets its own cloud load balancer
- **Cost:** $20/month per LoadBalancer × 100 services = $2,000/month
- **IP exhaustion:** Limited public IPs in cloud providers
- **SSL complexity:** Managing certificates for each service
- **No path-based routing:** Can't route /api/users vs /api/orders to different services

### The NodePort Nightmare
**Problem:** Exposing services on random high ports
- **Security risk:** Opens firewall holes on all nodes
- **User experience:** Users can't remember port 32547 for your API
- **Load balancing:** No intelligent traffic distribution
- **SSL termination:** Each service handles its own certificates

### The ClusterIP Isolation
**Problem:** Services only accessible within cluster
- **External access:** No way for users to reach your applications
- **API gateways:** Need complex proxy configurations
- **Monitoring:** External tools can't reach internal services

## 🧠 Core Concepts Explained

### Multi-Tenant Ingress

**What is Multi-Tenant Ingress?**
A single ingress controller serving multiple isolated customers/teams on the same Kubernetes cluster, with complete separation of traffic, configuration, and security policies.

**Real-World Example:** SaaS platform serving 1000+ customers
- **customer1.saas.com** → Customer 1's application pods
- **customer2.saas.com** → Customer 2's application pods
- **Each tenant isolated** from others (can't see each other's data/traffic)
- **Shared infrastructure** but separate virtual networks

**Why Multi-Tenancy Matters:**
- **Cost efficiency:** One cluster serves many customers
- **Resource sharing:** Better utilization of compute/memory
- **Operational simplicity:** One control plane to manage
- **Compliance:** Strict isolation for regulatory requirements

### Zero-Trust Network Policies

**What is Zero-Trust?**
Security model where **nothing is trusted by default** - every connection must be explicitly allowed and continuously verified.

**Traditional Network:** "Trust but verify"
- Internal network = trusted
- External network = untrusted
- Once inside, you can access everything

**Zero-Trust Network:** "Never trust, always verify"
- **No implicit trust** anywhere
- **Every connection** must be authenticated and authorized
- **Microsegmentation:** Each service isolated by default
- **Continuous verification:** Monitor all traffic patterns

**Real-World Impact:**
- **Breach containment:** Compromised service can't spread laterally
- **Compliance:** Meets PCI DSS, SOX, HIPAA requirements
- **Audit trails:** Every connection logged and monitored

### Service Mesh Integration

**What is a Service Mesh?**
Dedicated infrastructure layer that handles service-to-service communication with advanced traffic management, security, and observability.

**Without Service Mesh:**
```
Service A → Service B (direct connection)
- No encryption
- No retry logic
- No circuit breakers
- No traffic metrics
- Manual load balancing
```

**With Service Mesh (Istio/Linkerd):**
```
Service A → Sidecar Proxy → Sidecar Proxy → Service B
- Automatic mTLS encryption
- Intelligent retries
- Circuit breaker protection
- Detailed metrics/tracing
- Advanced load balancing
```

**Service Mesh Components:**
- **Data Plane:** Sidecar proxies (Envoy) handling traffic
- **Control Plane:** Management layer (Istio, Linkerd)
- **Observability:** Metrics, logs, distributed tracing
- **Security:** mTLS, authorization policies

### Production-Grade Traffic Management

**What is Production-Grade Traffic Management?**
Advanced routing, load balancing, and failure handling patterns that ensure high availability and performance at enterprise scale.

**Basic Traffic Management:**
- Round-robin load balancing
- Simple health checks
- Manual failover

**Production-Grade Traffic Management:**

#### Canary Deployments
**What:** Gradually shift traffic from old version to new version
**Example:** Deploy v2, send 5% traffic to test, gradually increase to 100%
**Benefits:** Reduce blast radius of bugs, real-world testing

#### Blue-Green Deployments
**What:** Two identical environments, switch traffic instantly
**Example:** Blue (current), Green (new), switch DNS/load balancer
**Benefits:** Zero-downtime deployments, instant rollback

#### Circuit Breakers
**What:** Stop calling failing services to prevent cascade failures
**Example:** After 5 failures in 30s, stop calling for 60s
**Benefits:** Prevent system-wide outages, faster recovery

#### Intelligent Retries
**What:** Smart retry logic with exponential backoff and jitter
**Example:** Retry after 1s, then 2s, then 4s, then give up
**Benefits:** Handle transient failures without overwhelming services

#### Rate Limiting
**What:** Limit requests per user/IP to prevent abuse
**Example:** 100 requests per minute per user
**Benefits:** Protect against DDoS, ensure fair usage

#### Geographic Routing
**What:** Route users to nearest data center
**Example:** EU users → eu-west-1, US users → us-east-1
**Benefits:** Lower latency, compliance with data residency

#### Weighted Routing
**What:** Split traffic based on percentages for A/B testing
**Example:** 80% see old UI, 20% see new UI
**Benefits:** Data-driven decisions, gradual feature rollouts

## 🌐 Enterprise Networking Architecture

### Ingress - The Smart Gateway
**What it solves:**
- **Single entry point:** One load balancer for all services
- **Path-based routing:** /api/users → user-service, /api/orders → order-service
- **Host-based routing:** api.company.com → API services, app.company.com → frontend
- **SSL termination:** Centralized certificate management
- **Rate limiting:** Protect services from abuse
- **Authentication:** Centralized auth before reaching services

### Network Policies - Zero Trust Security
**What it solves:**
- **Microsegmentation:** Database only accessible by API services
- **Compliance:** PCI/SOX requirements for network isolation
- **Breach containment:** Compromised pod can't access everything
- **Multi-tenancy:** Team A services can't access Team B services

### Service Mesh - Advanced Traffic Management
**What it solves:**
- **Observability:** Automatic metrics, tracing, logging for every request
- **Security:** Automatic mTLS encryption between all services
- **Traffic management:** Canary deployments, circuit breakers, retries
- **Policy enforcement:** Consistent security and routing across all services

**When You Need Service Mesh:**
- **100+ microservices** with complex communication patterns
- **Multi-cluster** deployments across regions/clouds
- **Compliance requirements** for encryption and audit trails
- **Advanced patterns** like circuit breakers, retries, timeouts
- **Observability needs** for debugging distributed systems

## 🧪 Real-World Example 1: E-commerce Platform Ingress

**Scenario:** Multi-service e-commerce platform with frontend, API, admin panel, and payment processing

### Step 1: Deploy the Applications

```yaml
# ecommerce-services.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: frontend-config
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: frontend-config
        configMap:
          name: frontend-nginx-config
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
spec:
  replicas: 5
  selector:
    matchLabels:
      app: api-service
  template:
    metadata:
      labels:
        app: api-service
    spec:
      containers:
      - name: api
        image: node:18-alpine
        command: ["node", "server.js"]
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: url
        - name: REDIS_URL
          value: "redis://redis-service:6379"
---
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  selector:
    app: api-service
  ports:
  - port: 80
    targetPort: 3000
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: admin-panel
spec:
  replicas: 2
  selector:
    matchLabels:
      app: admin-panel
  template:
    metadata:
      labels:
        app: admin-panel
    spec:
      containers:
      - name: admin
        image: react-admin:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: admin-service
spec:
  selector:
    app: admin-panel
  ports:
  - port: 80
    targetPort: 80
```

### Step 2: Production-Grade Ingress Configuration

```yaml
# ecommerce-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  annotations:
    # NGINX Ingress Controller specific
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    
    # Rate limiting
    nginx.ingress.kubernetes.io/rate-limit-connections: "10"
    nginx.ingress.kubernetes.io/rate-limit-requests-per-minute: "60"
    
    # Security headers
    nginx.ingress.kubernetes.io/configuration-snippet: |
      add_header X-Frame-Options "SAMEORIGIN" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header X-XSS-Protection "1; mode=block" always;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Load balancing
    nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
    
    # Timeouts
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
    
    # CORS for API
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: "https://shop.company.com"
    
    # Certificate management
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - shop.company.com
    - api.company.com
    - admin.company.com
    secretName: ecommerce-tls
  rules:
  # Frontend - Main shopping site
  - host: shop.company.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
  
  # API - Backend services
  - host: api.company.com
    http:
      paths:
      - path: /v1/users
        pathType: Prefix
        backend:
          service:
            name: user-service
            port:
              number: 80
      - path: /v1/products
        pathType: Prefix
        backend:
          service:
            name: product-service
            port:
              number: 80
      - path: /v1/orders
        pathType: Prefix
        backend:
          service:
            name: order-service
            port:
              number: 80
      - path: /v1/payments
        pathType: Prefix
        backend:
          service:
            name: payment-service
            port:
              number: 80
  
  # Admin Panel - Internal management
  - host: admin.company.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: admin-service
            port:
              number: 80
```

### Step 3: Advanced Ingress Features

```yaml
# advanced-ingress-features.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: advanced-ecommerce-ingress
  annotations:
    # Canary deployments
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "10"  # 10% traffic to canary
    
    # Authentication
    nginx.ingress.kubernetes.io/auth-url: "https://auth.company.com/oauth2/auth"
    nginx.ingress.kubernetes.io/auth-signin: "https://auth.company.com/oauth2/start"
    
    # Custom error pages
    nginx.ingress.kubernetes.io/custom-http-errors: "404,503"
    nginx.ingress.kubernetes.io/default-backend: "error-page-service"
    
    # Request/Response modification
    nginx.ingress.kubernetes.io/server-snippet: |
      # Add request ID for tracing
      set $req_id $request_id;
      proxy_set_header X-Request-ID $req_id;
      
      # Add real IP
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    
    # Circuit breaker pattern
    nginx.ingress.kubernetes.io/upstream-max-fails: "3"
    nginx.ingress.kubernetes.io/upstream-fail-timeout: "30s"
spec:
  # Same rules as before but with advanced features
  rules:
  - host: api.company.com
    http:
      paths:
      - path: /v1/
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

## 🔒 Zero-Trust Network Policies

**The Problem:** By default, all pods can communicate with all other pods. This is a security nightmare.

### Real-World Example: Banking Application Security

**Scenario:** Banking app with frontend, API, database, and payment processor that must comply with PCI DSS

```yaml
# banking-network-policies.yaml
# Policy 1: Default Deny All
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: banking-prod
spec:
  podSelector: {}  # Applies to all pods
  policyTypes:
  - Ingress
  - Egress
  # No ingress or egress rules = deny all
---
# Policy 2: Frontend can only talk to API
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
  namespace: banking-prod
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  egress:
  # Allow DNS resolution
  - to: []
    ports:
    - protocol: UDP
      port: 53
  # Allow HTTPS to API service only
  - to:
    - podSelector:
        matchLabels:
          app: api-service
    ports:
    - protocol: TCP
      port: 443
  # Allow external HTTPS (for CDN, external APIs)
  - to: []
    ports:
    - protocol: TCP
      port: 443
---
# Policy 3: API can only talk to Database and Payment Service
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-service-policy
  namespace: banking-prod
spec:
  podSelector:
    matchLabels:
      app: api-service
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # Accept connections from frontend
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 443
  # Accept connections from ingress controller
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 443
  egress:
  # Allow DNS
  - to: []
    ports:
    - protocol: UDP
      port: 53
  # Allow connection to database
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
  # Allow connection to payment service
  - to:
    - podSelector:
        matchLabels:
          app: payment-processor
    ports:
    - protocol: TCP
      port: 8080
  # Allow external HTTPS for third-party APIs
  - to: []
    ports:
    - protocol: TCP
      port: 443
---
# Policy 4: Database accepts connections only from API
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
  namespace: banking-prod
spec:
  podSelector:
    matchLabels:
      app: postgres
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # Only API service can connect
  - from:
    - podSelector:
        matchLabels:
          app: api-service
    ports:
    - protocol: TCP
      port: 5432
  # Allow backup service (different namespace)
  - from:
    - namespaceSelector:
        matchLabels:
          name: backup-system
      podSelector:
        matchLabels:
          app: postgres-backup
    ports:
    - protocol: TCP
      port: 5432
  egress:
  # Allow DNS only
  - to: []
    ports:
    - protocol: UDP
      port: 53
---
# Policy 5: Payment Processor - Highly Restricted
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: payment-processor-policy
  namespace: banking-prod
spec:
  podSelector:
    matchLabels:
      app: payment-processor
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # Only API service can initiate payments
  - from:
    - podSelector:
        matchLabels:
          app: api-service
    ports:
    - protocol: TCP
      port: 8080
  egress:
  # DNS resolution
  - to: []
    ports:
    - protocol: UDP
      port: 53
  # Only specific external payment gateways
  - to:
    - ipBlock:
        cidr: 52.84.0.0/16  # Stripe IP range
  - to:
    - ipBlock:
        cidr: 64.4.240.0/20  # PayPal IP range
    ports:
    - protocol: TCP
      port: 443
```

### Multi-Tenant Network Isolation

```yaml
# multi-tenant-policies.yaml
# Isolate different teams/customers
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: tenant-isolation
  namespace: saas-platform
spec:
  podSelector:
    matchLabels:
      tenant: customer-a
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # Only allow traffic from same tenant
  - from:
    - podSelector:
        matchLabels:
          tenant: customer-a
  # Allow ingress controller
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
  egress:
  # DNS
  - to: []
    ports:
    - protocol: UDP
      port: 53
  # Only to same tenant pods
  - to:
    - podSelector:
        matchLabels:
          tenant: customer-a
  # Shared services (monitoring, logging)
  - to:
    - namespaceSelector:
        matchLabels:
          name: shared-services
    - podSelector:
        matchLabels:
          type: shared
```

## 🕸️ Service Mesh - Next Level Networking

**When you need Service Mesh:**
- **100+ microservices** with complex communication patterns
- **Multi-cluster** deployments across regions
- **Compliance requirements** for encryption and audit trails
- **Advanced traffic management** like circuit breakers, retries

### Istio Implementation Example

```yaml
# istio-banking-setup.yaml
# Enable Istio injection for namespace
apiVersion: v1
kind: Namespace
metadata:
  name: banking-prod
  labels:
    istio-injection: enabled
---
# Virtual Service for traffic routing
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: banking-api
  namespace: banking-prod
spec:
  hosts:
  - api.bank.com
  gateways:
  - banking-gateway
  http:
  # Canary deployment: 90% to v1, 10% to v2
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: api-service
        subset: v2
      weight: 100
  - route:
    - destination:
        host: api-service
        subset: v1
      weight: 90
    - destination:
        host: api-service
        subset: v2
      weight: 10
    fault:
      delay:
        percentage:
          value: 0.1
        fixedDelay: 5s
    retries:
      attempts: 3
      perTryTimeout: 2s
---
# Destination Rule for load balancing
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: api-service
  namespace: banking-prod
spec:
  host: api-service
  trafficPolicy:
    loadBalancer:
      consistentHash:
        httpHeaderName: "user-id"  # Session affinity
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        maxRequestsPerConnection: 10
    circuitBreaker:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 30s
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
---
# Security Policy - mTLS
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: banking-prod
spec:
  mtls:
    mode: STRICT  # Require mTLS for all communication
---
# Authorization Policy
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: api-access-control
  namespace: banking-prod
spec:
  selector:
    matchLabels:
      app: api-service
  rules:
  # Allow frontend to access API
  - from:
    - source:
        principals: ["cluster.local/ns/banking-prod/sa/frontend"]
    to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/api/v1/*"]
  # Allow admin access
  - from:
    - source:
        principals: ["cluster.local/ns/banking-prod/sa/admin"]
    to:
    - operation:
        methods: ["*"]
```

## 🚀 Complete Production Demo

```bash
# production-networking-demo.sh
#!/bin/bash

echo "🌍 DEPLOYING PRODUCTION NETWORKING STACK"

# 1. Install NGINX Ingress Controller
echo "📦 Installing NGINX Ingress Controller..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.metrics.enabled=true \
  --set controller.podAnnotations."prometheus\.io/scrape"="true" \
  --set controller.podAnnotations."prometheus\.io/port"="10254"

# 2. Install cert-manager for SSL
echo "🔐 Installing cert-manager..."
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

# 3. Deploy applications
echo "🚀 Deploying e-commerce applications..."
kubectl apply -f ecommerce-services.yaml
kubectl wait --for=condition=ready pod -l app=frontend --timeout=300s
kubectl wait --for=condition=ready pod -l app=api-service --timeout=300s

# 4. Deploy ingress
echo "🌐 Configuring ingress routing..."
kubectl apply -f ecommerce-ingress.yaml

# 5. Apply network policies
echo "🔒 Applying zero-trust network policies..."
kubectl apply -f banking-network-policies.yaml

# 6. Test connectivity
echo "🧪 Testing network connectivity..."
./test-networking.sh

# 7. Display status
echo "✅ NETWORKING DEPLOYMENT COMPLETE"
echo ""
echo "=== Ingress Status ==="
kubectl get ingress -A
echo ""
echo "=== Network Policies ==="
kubectl get networkpolicies -A
echo ""
echo "=== Access URLs ==="
echo "🛒 Frontend: https://shop.company.com"
echo "🔌 API: https://api.company.com/v1/health"
echo "👨‍💼 Admin: https://admin.company.com"
echo ""
echo "=== Next Steps ==="
echo "1. Configure DNS: Point domains to $(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo "2. Monitor traffic: kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx"
echo "3. Test policies: ./test-network-policies.sh"
```

### Network Testing Suite

```bash
# test-networking.sh
#!/bin/bash

echo "🧪 COMPREHENSIVE NETWORKING TESTS"

# Test 1: Ingress Routing
echo "=== Test 1: Ingress Routing ==="
INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test frontend routing
if curl -s -H "Host: shop.company.com" http://$INGRESS_IP/ | grep -q "Welcome"; then
  echo "✅ Frontend routing: PASSED"
else
  echo "❌ Frontend routing: FAILED"
fi

# Test API routing
if curl -s -H "Host: api.company.com" http://$INGRESS_IP/v1/health | grep -q "healthy"; then
  echo "✅ API routing: PASSED"
else
  echo "❌ API routing: FAILED"
fi

# Test 2: Network Policy Enforcement
echo "=== Test 2: Network Policy Enforcement ==="

# Test allowed connection (frontend to API)
kubectl exec -it deployment/frontend -- curl -s api-service/health
if [ $? -eq 0 ]; then
  echo "✅ Allowed connection (frontend → API): PASSED"
else
  echo "❌ Allowed connection (frontend → API): FAILED"
fi

# Test blocked connection (frontend to database)
kubectl exec -it deployment/frontend -- curl -s postgres:5432 --connect-timeout 5
if [ $? -ne 0 ]; then
  echo "✅ Blocked connection (frontend → database): PASSED"
else
  echo "❌ Blocked connection (frontend → database): FAILED"
fi

# Test 3: SSL/TLS Configuration
echo "=== Test 3: SSL/TLS Configuration ==="
if curl -s -k https://$INGRESS_IP/ -H "Host: shop.company.com" | grep -q "Welcome"; then
  echo "✅ HTTPS routing: PASSED"
else
  echo "❌ HTTPS routing: FAILED"
fi

# Test 4: Rate Limiting
echo "=== Test 4: Rate Limiting ==="
for i in {1..70}; do
  curl -s -H "Host: api.company.com" http://$INGRESS_IP/v1/test > /dev/null
done

# 61st request should be rate limited
RESPONSE=$(curl -s -w "%{http_code}" -H "Host: api.company.com" http://$INGRESS_IP/v1/test -o /dev/null)
if [ "$RESPONSE" = "429" ]; then
  echo "✅ Rate limiting: PASSED"
else
  echo "❌ Rate limiting: FAILED (got $RESPONSE, expected 429)"
fi

echo ""
echo "🎯 NETWORKING TESTING COMPLETE"
echo "All critical networking features verified!"
```

## 💡 Production Best Practices

### ✅ Enterprise Do's
- **Single ingress controller** per cluster for cost efficiency
- **Wildcard SSL certificates** for subdomain flexibility
- **Rate limiting** to protect against abuse
- **Network policies** for zero-trust security
- **Health checks** on all ingress backends
- **Monitoring** ingress controller metrics
- **Canary deployments** through ingress weights
- **Geographic routing** for multi-region setups

### ❌ Production Never Do's
- **Multiple ingress controllers** without coordination
- **No network policies** in production
- **Hardcoded IPs** in network policies
- **Overly permissive** egress rules
- **No SSL termination** at ingress
- **Missing health checks** causing traffic to unhealthy pods
- **No rate limiting** exposing services to DDoS
- **Default allow-all** network policies

---

## 📚 Key Takeaways

### What You Learned
- **Ingress Controllers:** Smart gateways replacing expensive LoadBalancers
- **Network Policies:** Zero-trust microsegmentation for compliance
- **Service Mesh:** Advanced traffic management for complex architectures
- **Production Patterns:** SSL termination, rate limiting, canary deployments
- **Security:** Multi-tenant isolation, PCI compliance, audit trails

### Production Checklist
- ✅ Ingress controller with SSL termination
- ✅ Network policies enforcing zero-trust
- ✅ Rate limiting and DDoS protection
- ✅ Health checks and circuit breakers
- ✅ Monitoring and alerting on network metrics
- ✅ Canary deployment capabilities
- ✅ Multi-tenant isolation policies

---

## 🎯 Next Lesson

Go to [Lesson 8: Monitoring](../08-monitoring/) to learn about observability and performance monitoring!