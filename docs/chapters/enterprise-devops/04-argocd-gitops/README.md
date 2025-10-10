# 🚀 ArgoCD GitOps Excellence - Enterprise Continuous Deployment

## 🎯 Objective
Master ArgoCD for enterprise GitOps workflows with multi-cluster management, RBAC, disaster recovery, and production-grade automation.

> **"GitOps is not just about Git - it's about declarative, observable, and auditable infrastructure."**

## 🌟 Why ArgoCD Dominates Enterprise GitOps

### Companies Using ArgoCD at Scale
- **Netflix** - 2,500+ microservices across 150+ clusters
- **Intuit** - 10,000+ applications deployed via ArgoCD
- **Adobe** - Multi-cloud GitOps for Creative Cloud
- **Red Hat** - OpenShift GitOps foundation

### Enterprise Requirements
- **Multi-cluster management** (dev/staging/prod clusters)
- **RBAC integration** (LDAP/SAML/OIDC)
- **Disaster recovery** and backup strategies
- **Compliance** and audit trails
- **High availability** and scalability

## 🏗️ Enterprise ArgoCD Architecture

### High Availability Setup
```yaml
# argocd-ha-install.yaml - Production-ready ArgoCD
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
---
apiVersion: argoproj.io/v1alpha1
kind: ArgoCD
metadata:
  name: argocd-server
  namespace: argocd
spec:
  # High Availability Configuration
  ha:
    enabled: true
    redisProxyImage: haproxy:2.6
    
  # Server Configuration
  server:
    replicas: 3
    autoscale:
      enabled: true
      minReplicas: 3
      maxReplicas: 10
      targetCPUUtilizationPercentage: 70
    
    # Ingress Configuration
    ingress:
      enabled: true
      ingressClassName: nginx
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-prod
        nginx.ingress.kubernetes.io/ssl-redirect: "true"
        nginx.ingress.kubernetes.io/backend-protocol: "GRPC"
      hosts:
        - argocd.enterprise.com
      tls:
        - secretName: argocd-server-tls
          hosts:
            - argocd.enterprise.com
    
    # Resource Management
    resources:
      requests:
        cpu: 500m
        memory: 512Mi
      limits:
        cpu: 2000m
        memory: 2Gi
        
  # Repository Server Configuration
  repo:
    replicas: 3
    resources:
      requests:
        cpu: 250m
        memory: 256Mi
      limits:
        cpu: 1000m
        memory: 1Gi
    
    # Volume mounts for custom tools
    volumeMounts:
      - name: custom-tools
        mountPath: /usr/local/bin/helm
        subPath: helm
      - name: custom-tools
        mountPath: /usr/local/bin/kustomize
        subPath: kustomize
    
    volumes:
      - name: custom-tools
        emptyDir: {}
    
    initContainers:
      - name: download-tools
        image: alpine:latest
        command: [sh, -c]
        args:
          - |
            # Download Helm
            wget -O- https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar -xzO linux-amd64/helm > /custom-tools/helm
            # Download Kustomize
            wget -O /custom-tools/kustomize https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.0.0/kustomize_v5.0.0_linux_amd64
            chmod +x /custom-tools/*
        volumeMounts:
          - mountPath: /custom-tools
            name: custom-tools
  
  # Application Controller Configuration
  controller:
    replicas: 3
    resources:
      requests:
        cpu: 1000m
        memory: 1Gi
      limits:
        cpu: 4000m
        memory: 4Gi
    
    # Metrics and monitoring
    metrics:
      enabled: true
      serviceMonitor:
        enabled: true
        namespace: monitoring
  
  # Redis Configuration for HA
  redis:
    resources:
      requests:
        cpu: 250m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 512Mi
  
  # RBAC Configuration
  rbac:
    defaultPolicy: 'role:readonly'
    policy: |
      # Admin policy
      p, role:admin, applications, *, */*, allow
      p, role:admin, clusters, *, *, allow
      p, role:admin, repositories, *, *, allow
      
      # Developer policy
      p, role:developer, applications, get, */*, allow
      p, role:developer, applications, sync, */*, allow
      p, role:developer, applications, action/*, */*, allow
      
      # DevOps policy
      p, role:devops, applications, *, */*, allow
      p, role:devops, clusters, get, *, allow
      p, role:devops, repositories, get, *, allow
      
      # Group mappings
      g, argocd-admins, role:admin
      g, developers, role:developer
      g, devops-team, role:devops
    
    scopes: '[groups, email]'
  
  # SSO Configuration (OIDC)
  sso:
    provider: oidc
    issuer: https://auth.enterprise.com
    clientId: argocd
    clientSecret:
      name: argocd-secret
      key: oidc.clientSecret
    requestedScopes: ["openid", "profile", "email", "groups"]
    requestedIDTokenClaims:
      groups:
        essential: true
  
  # Monitoring and Observability
  monitoring:
    enabled: true
    
  # Backup Configuration
  backup:
    enabled: true
    schedule: "0 2 * * *"  # Daily at 2 AM
    retention: "30d"
```

### Multi-Cluster Management
```yaml
# cluster-management.yaml - Multi-cluster setup
apiVersion: v1
kind: Secret
metadata:
  name: dev-cluster
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: dev-cluster
  server: https://dev-k8s.enterprise.com
  config: |
    {
      "bearerToken": "<dev-cluster-token>",
      "tlsClientConfig": {
        "insecure": false,
        "caData": "<base64-encoded-ca-cert>"
      }
    }
---
apiVersion: v1
kind: Secret
metadata:
  name: staging-cluster
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: staging-cluster
  server: https://staging-k8s.enterprise.com
  config: |
    {
      "bearerToken": "<staging-cluster-token>",
      "tlsClientConfig": {
        "insecure": false,
        "caData": "<base64-encoded-ca-cert>"
      }
    }
---
apiVersion: v1
kind: Secret
metadata:
  name: prod-cluster
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: prod-cluster
  server: https://prod-k8s.enterprise.com
  config: |
    {
      "bearerToken": "<prod-cluster-token>",
      "tlsClientConfig": {
        "insecure": false,
        "caData": "<base64-encoded-ca-cert>"
      }
    }
```

## 🔄 GitOps Application Patterns

### Application of Applications Pattern
```yaml
# app-of-apps.yaml - Root application managing all others
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-apps
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/enterprise/gitops-apps
    targetRevision: HEAD
    path: applications
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
```

### Environment-Specific Applications
```yaml
# applications/microservice-a-dev.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: microservice-a-dev
  namespace: argocd
spec:
  project: development
  source:
    repoURL: https://github.com/enterprise/microservice-a
    targetRevision: develop
    path: k8s/overlays/dev
  destination:
    server: https://dev-k8s.enterprise.com
    namespace: microservice-a-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
  
  # Health checks
  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers:
        - /spec/replicas
  
  # Sync waves for ordered deployment
  syncPolicy:
    syncOptions:
      - ApplyOutOfSyncOnly=true
---
# applications/microservice-a-staging.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: microservice-a-staging
  namespace: argocd
spec:
  project: staging
  source:
    repoURL: https://github.com/enterprise/microservice-a
    targetRevision: main
    path: k8s/overlays/staging
  destination:
    server: https://staging-k8s.enterprise.com
    namespace: microservice-a-staging
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
    # Manual sync for staging
    automated: null
---
# applications/microservice-a-prod.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: microservice-a-prod
  namespace: argocd
spec:
  project: production
  source:
    repoURL: https://github.com/enterprise/microservice-a
    targetRevision: v1.2.3  # Specific version for prod
    path: k8s/overlays/prod
  destination:
    server: https://prod-k8s.enterprise.com
    namespace: microservice-a-prod
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
    # Manual sync only for production
    automated: null
```

## 🛡️ Enterprise Security & RBAC

### AppProject Configuration
```yaml
# projects/development.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: development
  namespace: argocd
spec:
  description: Development environment applications
  
  # Source repositories
  sourceRepos:
    - 'https://github.com/enterprise/*'
    - 'https://helm.enterprise.com/*'
  
  # Destination clusters and namespaces
  destinations:
    - namespace: '*-dev'
      server: https://dev-k8s.enterprise.com
    - namespace: 'monitoring'
      server: https://dev-k8s.enterprise.com
  
  # Cluster resource whitelist
  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
    - group: rbac.authorization.k8s.io
      kind: ClusterRole
    - group: rbac.authorization.k8s.io
      kind: ClusterRoleBinding
  
  # Namespace resource whitelist
  namespaceResourceWhitelist:
    - group: ''
      kind: ConfigMap
    - group: ''
      kind: Secret
    - group: ''
      kind: Service
    - group: apps
      kind: Deployment
    - group: apps
      kind: StatefulSet
    - group: networking.k8s.io
      kind: Ingress
  
  # RBAC roles
  roles:
    - name: developer
      description: Developer access to development applications
      policies:
        - p, proj:development:developer, applications, get, development/*, allow
        - p, proj:development:developer, applications, sync, development/*, allow
        - p, proj:development:developer, applications, action/*, development/*, allow
        - p, proj:development:developer, logs, get, development/*, allow
      groups:
        - developers
        - qa-team
    
    - name: lead-developer
      description: Lead developer with additional permissions
      policies:
        - p, proj:development:lead-developer, applications, *, development/*, allow
        - p, proj:development:lead-developer, repositories, get, *, allow
      groups:
        - lead-developers
---
# projects/production.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: production
  namespace: argocd
spec:
  description: Production environment applications
  
  sourceRepos:
    - 'https://github.com/enterprise/*'
  
  destinations:
    - namespace: '*-prod'
      server: https://prod-k8s.enterprise.com
  
  # Strict resource control for production
  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
  
  namespaceResourceWhitelist:
    - group: ''
      kind: ConfigMap
    - group: ''
      kind: Secret
    - group: ''
      kind: Service
    - group: apps
      kind: Deployment
    - group: apps
      kind: StatefulSet
    - group: networking.k8s.io
      kind: Ingress
  
  # Production-specific policies
  syncWindows:
    - kind: allow
      schedule: '0 9-17 * * 1-5'  # Business hours only
      duration: 8h
      applications:
        - '*'
      manualSync: true
    - kind: deny
      schedule: '0 18-8 * * *'    # Block after hours
      duration: 14h
      applications:
        - '*'
  
  roles:
    - name: production-deployer
      description: Production deployment access
      policies:
        - p, proj:production:production-deployer, applications, get, production/*, allow
        - p, proj:production:production-deployer, applications, sync, production/*, allow
      groups:
        - devops-team
        - sre-team
```

### LDAP Integration
```yaml
# argocd-cm.yaml - LDAP configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  # LDAP configuration
  url: ldaps://ldap.enterprise.com:636
  dex.config: |
    connectors:
      - type: ldap
        name: Enterprise LDAP
        id: ldap
        config:
          host: ldap.enterprise.com:636
          insecureNoSSL: false
          insecureSkipVerify: false
          
          # Bind credentials
          bindDN: cn=argocd,ou=service-accounts,dc=enterprise,dc=com
          bindPW: $ldap-bind-password
          
          # User search
          userSearch:
            baseDN: ou=users,dc=enterprise,dc=com
            filter: "(objectClass=person)"
            username: sAMAccountName
            idAttr: sAMAccountName
            emailAttr: mail
            nameAttr: displayName
          
          # Group search
          groupSearch:
            baseDN: ou=groups,dc=enterprise,dc=com
            filter: "(objectClass=group)"
            userMatchers:
              - userAttr: DN
                groupAttr: member
            nameAttr: cn
  
  # OIDC configuration (alternative to LDAP)
  oidc.config: |
    name: Enterprise SSO
    issuer: https://auth.enterprise.com
    clientId: argocd
    clientSecret: $oidc.clientSecret
    requestedScopes: ["openid", "profile", "email", "groups"]
    requestedIDTokenClaims: {"groups": {"essential": true}}
  
  # Application instance label key
  application.instanceLabelKey: argocd.argoproj.io/instance
  
  # Server configuration
  server.insecure: "false"
  server.grpc.web: "true"
  
  # Repository credentials
  repositories: |
    - url: https://github.com/enterprise
      passwordSecret:
        name: github-secret
        key: password
      usernameSecret:
        name: github-secret
        key: username
    - url: https://helm.enterprise.com
      type: helm
      passwordSecret:
        name: helm-secret
        key: password
      usernameSecret:
        name: helm-secret
        key: username
```

## 🔄 Advanced GitOps Patterns

### Progressive Delivery with Argo Rollouts
```yaml
# rollout-canary.yaml - Canary deployment strategy
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: microservice-a
  namespace: microservice-a-prod
spec:
  replicas: 10
  strategy:
    canary:
      # Canary service for testing
      canaryService: microservice-a-canary
      stableService: microservice-a-stable
      
      # Traffic routing
      trafficRouting:
        nginx:
          stableIngress: microservice-a-stable
          annotationPrefix: nginx.ingress.kubernetes.io
          additionalIngressAnnotations:
            canary-by-header: X-Canary
      
      # Analysis and promotion
      analysis:
        templates:
          - templateName: success-rate
        startingStep: 2
        args:
          - name: service-name
            value: microservice-a-canary
      
      # Deployment steps
      steps:
        - setWeight: 5
        - pause: {duration: 2m}
        - setWeight: 20
        - pause: {duration: 5m}
        - analysis:
            templates:
              - templateName: success-rate
            args:
              - name: service-name
                value: microservice-a-canary
        - setWeight: 50
        - pause: {duration: 10m}
        - setWeight: 100
        - pause: {duration: 2m}
  
  selector:
    matchLabels:
      app: microservice-a
  
  template:
    metadata:
      labels:
        app: microservice-a
    spec:
      containers:
        - name: microservice-a
          image: registry.enterprise.com/microservice-a:v1.2.3
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
---
# analysis-template.yaml - Success rate analysis
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
  namespace: microservice-a-prod
spec:
  args:
    - name: service-name
  metrics:
    - name: success-rate
      interval: 2m
      count: 5
      successCondition: result[0] >= 0.95
      failureLimit: 3
      provider:
        prometheus:
          address: http://prometheus.monitoring.svc.cluster.local:9090
          query: |
            sum(rate(http_requests_total{service="{{args.service-name}}",status!~"5.."}[2m])) /
            sum(rate(http_requests_total{service="{{args.service-name}}"}[2m]))
    
    - name: avg-response-time
      interval: 2m
      count: 5
      successCondition: result[0] <= 0.5
      failureLimit: 3
      provider:
        prometheus:
          address: http://prometheus.monitoring.svc.cluster.local:9090
          query: |
            histogram_quantile(0.95,
              sum(rate(http_request_duration_seconds_bucket{service="{{args.service-name}}"}[2m])) by (le)
            )
```

### Blue-Green Deployment
```yaml
# rollout-bluegreen.yaml - Blue-Green deployment
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: microservice-b
  namespace: microservice-b-prod
spec:
  replicas: 5
  strategy:
    blueGreen:
      # Services
      activeService: microservice-b-active
      previewService: microservice-b-preview
      
      # Promotion strategy
      autoPromotionEnabled: false
      scaleDownDelaySeconds: 30
      prePromotionAnalysis:
        templates:
          - templateName: success-rate
        args:
          - name: service-name
            value: microservice-b-preview
      
      # Post-promotion analysis
      postPromotionAnalysis:
        templates:
          - templateName: success-rate
        args:
          - name: service-name
            value: microservice-b-active
  
  selector:
    matchLabels:
      app: microservice-b
  
  template:
    metadata:
      labels:
        app: microservice-b
    spec:
      containers:
        - name: microservice-b
          image: registry.enterprise.com/microservice-b:v2.1.0
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: 200m
              memory: 256Mi
            limits:
              cpu: 1000m
              memory: 1Gi
```

## 📊 Monitoring & Observability

### ArgoCD Metrics Dashboard
```yaml
# monitoring/servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: argocd-metrics
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-metrics
  endpoints:
    - port: metrics
      interval: 30s
      path: /metrics
---
# monitoring/grafana-dashboard.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-dashboard
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  argocd-dashboard.json: |
    {
      "dashboard": {
        "title": "ArgoCD Enterprise Dashboard",
        "panels": [
          {
            "title": "Application Sync Status",
            "type": "stat",
            "targets": [
              {
                "expr": "sum by (sync_status) (argocd_app_info)",
                "legendFormat": "{{sync_status}}"
              }
            ]
          },
          {
            "title": "Application Health Status",
            "type": "stat",
            "targets": [
              {
                "expr": "sum by (health_status) (argocd_app_info)",
                "legendFormat": "{{health_status}}"
              }
            ]
          },
          {
            "title": "Sync Operations Over Time",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(argocd_app_sync_total[5m])",
                "legendFormat": "Sync Rate"
              }
            ]
          },
          {
            "title": "Repository Connection Status",
            "type": "table",
            "targets": [
              {
                "expr": "argocd_repo_connection_status",
                "format": "table"
              }
            ]
          }
        ]
      }
    }
```

### Alerting Rules
```yaml
# monitoring/alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: argocd-alerts
  namespace: monitoring
spec:
  groups:
    - name: argocd
      rules:
        - alert: ArgoCDAppNotSynced
          expr: argocd_app_info{sync_status!="Synced"} == 1
          for: 15m
          labels:
            severity: warning
          annotations:
            summary: "ArgoCD application {{ $labels.name }} is not synced"
            description: "Application {{ $labels.name }} in project {{ $labels.project }} has been out of sync for more than 15 minutes."
        
        - alert: ArgoCDAppUnhealthy
          expr: argocd_app_info{health_status!="Healthy"} == 1
          for: 10m
          labels:
            severity: critical
          annotations:
            summary: "ArgoCD application {{ $labels.name }} is unhealthy"
            description: "Application {{ $labels.name }} in project {{ $labels.project }} has been unhealthy for more than 10 minutes."
        
        - alert: ArgoCDRepoConnectionFailed
          expr: argocd_repo_connection_status == 0
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "ArgoCD repository connection failed"
            description: "Repository {{ $labels.repo }} connection has been failing for more than 5 minutes."
        
        - alert: ArgoCDSyncOperationFailed
          expr: increase(argocd_app_sync_total{phase="Failed"}[5m]) > 0
          labels:
            severity: warning
          annotations:
            summary: "ArgoCD sync operation failed"
            description: "Sync operation for application {{ $labels.name }} has failed."
```

## 🔧 PowerShell Automation Scripts

### ArgoCD Setup Script
```powershell
# setup-argocd.ps1 - Complete ArgoCD enterprise setup
param(
    [Parameter(Mandatory=$true)]
    [string]$KubeContext,
    
    [Parameter(Mandatory=$true)]
    [string]$Domain,
    
    [string]$Namespace = "argocd",
    [string]$Version = "v2.8.4"
)

Write-Host "🚀 Setting up ArgoCD Enterprise..." -ForegroundColor Green

# Set kubectl context
kubectl config use-context $KubeContext

# Create namespace
kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
Write-Host "📦 Installing ArgoCD $Version..." -ForegroundColor Yellow
kubectl apply -n $Namespace -f "https://raw.githubusercontent.com/argoproj/argo-cd/$Version/manifests/install.yaml"

# Wait for ArgoCD to be ready
Write-Host "⏳ Waiting for ArgoCD to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n $Namespace

# Get initial admin password
$adminPassword = kubectl -n $Namespace get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }

Write-Host "✅ ArgoCD installed successfully!" -ForegroundColor Green
Write-Host "Admin password: $adminPassword" -ForegroundColor Yellow

# Create ingress
$ingressYaml = @"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: $Namespace
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "GRPC"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - argocd.$Domain
      secretName: argocd-server-tls
  rules:
    - host: argocd.$Domain
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  number: 80
"@

$ingressYaml | kubectl apply -f -

Write-Host "🌐 ArgoCD will be available at: https://argocd.$Domain" -ForegroundColor Green
Write-Host "🔑 Login with admin / $adminPassword" -ForegroundColor Yellow
```

### Application Deployment Script
```powershell
# deploy-application.ps1 - Deploy application via ArgoCD
param(
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [Parameter(Mandatory=$true)]
    [string]$RepoUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [Parameter(Mandatory=$true)]
    [string]$Environment,
    
    [string]$Namespace = "argocd",
    [string]$Project = "default",
    [string]$Branch = "main"
)

$clusterMap = @{
    "dev" = "https://dev-k8s.enterprise.com"
    "staging" = "https://staging-k8s.enterprise.com"
    "prod" = "https://prod-k8s.enterprise.com"
}

$targetCluster = $clusterMap[$Environment]
if (-not $targetCluster) {
    Write-Host "❌ Invalid environment: $Environment" -ForegroundColor Red
    exit 1
}

$appYaml = @"
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $AppName-$Environment
  namespace: $Namespace
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: $Project
  source:
    repoURL: $RepoUrl
    targetRevision: $Branch
    path: $Path
  destination:
    server: $targetCluster
    namespace: $AppName-$Environment
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
"@

Write-Host "🚀 Deploying $AppName to $Environment..." -ForegroundColor Green
$appYaml | kubectl apply -f -

Write-Host "✅ Application $AppName-$Environment created successfully!" -ForegroundColor Green
Write-Host "🔍 Check status: kubectl get application $AppName-$Environment -n $Namespace" -ForegroundColor Yellow
```

## 🏆 Enterprise Success Stories

### Netflix - 2,500 Microservices
**Challenge**: Managing deployments across 150+ Kubernetes clusters
**Solution**:
- ArgoCD with custom controllers
- Multi-region GitOps workflows
- Automated canary deployments
- Disaster recovery automation

**Results**:
- 99.99% deployment success rate
- 50% reduction in deployment time
- Zero-downtime deployments
- $10M+ savings in operational costs

### Intuit - 10,000 Applications
**Challenge**: Scaling GitOps for massive application portfolio
**Solution**:
- Application of Applications pattern
- Automated RBAC management
- Multi-tenant cluster architecture
- Progressive delivery pipelines

**Results**:
- 95% developer self-service adoption
- 80% reduction in deployment tickets
- 99.9% application availability
- 40% faster time-to-market

---

**Master ArgoCD GitOps and become the continuous deployment expert every enterprise needs!** 🎯