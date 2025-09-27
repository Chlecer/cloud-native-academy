# 📦 Container Security - Defend the Supply Chain

## 🎯 Objective
Secure containers like Docker and Kubernetes do - prevent the next supply chain attack.

> **"Containers are not VMs. They share the kernel. One bad container can compromise the entire host."** - Liz Rice, Isovalent CTO

## 🌟 Why This Matters - The $62 Billion Container Market

### Companies Mastering Container Security

**🐳 Docker Inc** - Secures 13 billion container downloads monthly
- **Challenge:** Prevent malicious images in Docker Hub
- **Strategy:** Automated vulnerability scanning + content trust + signed images
- **Result:** 99.9% of malicious images blocked before download¹
- **Learning:** Security must be built into the registry, not bolted on

**☁️ Google (Kubernetes)** - Runs 2+ billion containers weekly
- **Scale:** Manages containers across 1M+ servers globally
- **Security:** gVisor sandboxing + Binary Authorization + Pod Security Standards
- **Impact:** Zero container escapes in production since 2019²
- **Secret:** Defense in depth - multiple security layers

**🏦 Capital One** - Migrated 100+ apps to containers securely
- **Transformation:** From VMs to containers while meeting banking regulations
- **Strategy:** Immutable infrastructure + runtime security + compliance automation
- **Result:** 50% faster deployments with improved security posture³
- **Lesson:** Containers can be more secure than traditional infrastructure

### The Cost of Container Security Failures
- **💸 Average container breach:** $4.1M per incident⁴
- **😱 Vulnerable images:** 51% of container images have high/critical vulnerabilities⁵
- **⏰ Detection time:** 206 days average to find container compromise⁶
- **📈 Growth rate:** 300% increase in container attacks (2022-2023)⁷
- **🎯 Supply chain:** 88% of organizations experienced supply chain attack⁸

*¹Docker Security Report | ²Google SRE Book | ³Capital One Tech Blog | ⁴Sysdig Container Security Report | ⁵Snyk State of Open Source | ⁶Aqua Security Report | ⁷Palo Alto Unit 42 | ⁸Sonatype Supply Chain Report*

## 😱 The Codecov Supply Chain Attack (2021)

### What Happened
- **🎯 Target:** Codecov bash uploader script (used by 29,000+ companies)
- **💥 Impact:** Twilio, HashiCorp, Rapid7, Mercari compromised
- **🕳️ Attack vector:** Modified Docker container in CI/CD pipeline
- **💰 Damage:** $10M+ in incident response across victims⁹
- **⏰ Duration:** Attackers had access for 2+ months

### How Container Security Would Have Prevented This
```
❌ What Happened:
- Unsigned container images
- No image vulnerability scanning
- No runtime monitoring
- Trusted third-party containers blindly

✅ What Should Have Been Done:
- Image signing and verification
- Automated vulnerability scanning
- Runtime security monitoring
- Zero-trust container policies
```

*⁹Codecov Security Incident Report*

## 🔒 Secure Dockerfile - The Google Distroless Way

### Why Secure Dockerfiles Matter
- **📉 Attack surface:** Average container has 500+ packages, 90% unnecessary¹⁰
- **🐛 Vulnerabilities:** Each package adds potential security holes
- **📊 Size impact:** Secure images are 10-100x smaller
- **🚀 Performance:** Smaller images = faster deployments

### Production Dockerfile (Banking Grade)
```dockerfile
# Multi-stage build for security and size
# Build stage - Use full image for building
FROM node:18-alpine AS builder

# Security: Create build user (don't use root)
RUN addgroup -g 1001 -S builduser && \
    adduser -S builduser -u 1001 -G builduser

# Security: Set working directory with proper ownership
WORKDIR /build
RUN chown builduser:builduser /build
USER builduser

# Security: Copy only package files first (layer caching + security)
COPY --chown=builduser:builduser package*.json ./

# Security: Use npm ci for reproducible builds
RUN npm ci --only=production --no-audit --no-fund && \
    npm cache clean --force

# Copy source code
COPY --chown=builduser:builduser . .

# Build application
RUN npm run build

# Production stage - Use minimal distroless image
FROM gcr.io/distroless/nodejs18-debian11:nonroot AS production

# Security: Distroless images have:
# - No shell (can't execute commands if compromised)
# - No package manager (can't install malware)
# - Only runtime dependencies
# - Non-root user by default

# Set working directory
WORKDIR /app

# Copy only production files from builder
COPY --from=builder --chown=nonroot:nonroot /build/node_modules ./node_modules
COPY --from=builder --chown=nonroot:nonroot /build/dist ./dist
COPY --from=builder --chown=nonroot:nonroot /build/package.json ./

# Security: Already running as nonroot user (uid 65532)
# Security: No shell available (distroless)
# Security: Minimal attack surface

# Expose port (documentation only)
EXPOSE 3000

# Security: Use exec form to avoid shell
CMD ["node", "dist/index.js"]

# Security labels for compliance
LABEL maintainer="security@company.com" \
      version="1.0.0" \
      security.scan="required" \
      compliance.level="high"
```

### Alternative: Alpine-based Secure Dockerfile
```dockerfile
# If you can't use distroless, secure Alpine approach
FROM node:18-alpine AS production

# Security: Install only security updates
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Security: Remove package manager after updates
RUN apk del apk-tools

# Security: Create non-root user with specific UID/GID
RUN addgroup -g 1001 -S appuser && \
    adduser -S appuser -u 1001 -G appuser -h /app -s /sbin/nologin

# Security: Set secure permissions on app directory
WORKDIR /app
RUN chown appuser:appuser /app

# Copy application files
COPY --from=builder --chown=appuser:appuser /build/node_modules ./node_modules
COPY --from=builder --chown=appuser:appuser /build/dist ./dist
COPY --from=builder --chown=appuser:appuser /build/package.json ./

# Security: Switch to non-root user
USER appuser

# Security: Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
```

### Dockerfile Security Checklist
```dockerfile
# ✅ Security Best Practices Checklist:

# 1. Use specific image tags (not 'latest')
FROM node:18.17.0-alpine3.18  # ✅ Specific version
# FROM node:latest             # ❌ Unpredictable

# 2. Use multi-stage builds
FROM node:18-alpine AS builder  # ✅ Build stage
FROM gcr.io/distroless/nodejs18 # ✅ Minimal runtime

# 3. Run as non-root user
USER nonroot                    # ✅ Non-root
# USER root                     # ❌ Root user

# 4. Use COPY instead of ADD
COPY package.json ./            # ✅ Explicit copy
# ADD package.json ./           # ❌ Can extract archives

# 5. Minimize layers and clean up
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*  # ✅ Clean
# RUN apk update                # ❌ Leaves cache
# RUN apk upgrade               # ❌ Multiple layers

# 6. Use .dockerignore
# Create .dockerignore file with:
# node_modules
# .git
# .env
# *.log

# 7. Don't store secrets in image
# Use environment variables or secret management
# ENV API_KEY=secret123         # ❌ Hardcoded secret
# Use Kubernetes secrets instead # ✅ External secrets
```

*¹⁰Google Distroless Documentation*

## 🔍 Image Scanning

### Trivy Integration
```yaml
# .github/workflows/security.yml
name: Container Security

on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'myapp:${{ github.sha }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```

## 🛡️ Runtime Security

### Pod Security Standards
```yaml
# pod-security-policy.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: secure-namespace
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: secure-namespace
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 1001
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: app
        image: myapp:latest
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1001
          capabilities:
            drop:
            - ALL
        resources:
          limits:
            memory: "128Mi"
            cpu: "100m"
          requests:
            memory: "64Mi"
            cpu: "50m"
```

## 🎓 What You Learned

- ✅ Secure Dockerfile practices
- ✅ Container image scanning
- ✅ Runtime security policies
- ✅ Pod security standards

---

**Next:** [Compliance](../05-compliance/)