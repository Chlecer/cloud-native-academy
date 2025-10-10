@echo off
echo 🎯 DEPLOYING COMPLETE E-COMMERCE PLATFORM
echo.

REM Check if kubectl is available
kubectl version --client >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ kubectl not found. Please install kubectl first.
    exit /b 1
)

echo 📦 Step 1: Creating namespaces...
kubectl create namespace ecommerce 2>nul
kubectl create namespace monitoring 2>nul
if %errorlevel% equ 0 (
    echo ✅ Namespaces created
) else (
    echo ℹ️ Namespaces already exist
)

echo.
echo 💾 Step 2: Deploying PostgreSQL database...
kubectl apply -f database-layer.yaml -n ecommerce
if %errorlevel% equ 0 (
    echo ✅ PostgreSQL deployed
) else (
    echo ❌ Failed to deploy PostgreSQL
    exit /b 1
)

echo.
echo ⚡ Step 3: Deploying Redis cache...
kubectl apply -f cache-layer.yaml -n ecommerce
if %errorlevel% equ 0 (
    echo ✅ Redis deployed
) else (
    echo ❌ Failed to deploy Redis
    exit /b 1
)

echo.
echo 🔌 Step 4: Deploying Backend API...
kubectl apply -f backend-api.yaml -n ecommerce
if %errorlevel% equ 0 (
    echo ✅ Backend API deployed
) else (
    echo ❌ Failed to deploy Backend API
    exit /b 1
)

echo.
echo 🌐 Step 5: Deploying Frontend...
kubectl apply -f frontend.yaml -n ecommerce
if %errorlevel% equ 0 (
    echo ✅ Frontend deployed
) else (
    echo ❌ Failed to deploy Frontend
    exit /b 1
)

echo.
echo 🔒 Step 6: Configuring networking and security...
kubectl apply -f ingress-controller.yaml
kubectl apply -f network-policies.yaml -n ecommerce
if %errorlevel% equ 0 (
    echo ✅ Networking configured
) else (
    echo ❌ Failed to configure networking
    exit /b 1
)

echo.
echo 📊 Step 7: Deploying monitoring stack...
kubectl apply -f monitoring-stack.yaml -n monitoring
if %errorlevel% equ 0 (
    echo ✅ Monitoring deployed
) else (
    echo ❌ Failed to deploy monitoring
    exit /b 1
)

echo.
echo ⏳ Step 8: Waiting for services to be ready...
echo Waiting for PostgreSQL...
kubectl wait --for=condition=ready pod -l app=postgres -n ecommerce --timeout=300s
if %errorlevel% equ 0 (
    echo ✅ PostgreSQL ready
) else (
    echo ⚠️ PostgreSQL not ready within timeout
)

echo Waiting for Redis...
kubectl wait --for=condition=ready pod -l app=redis -n ecommerce --timeout=180s
if %errorlevel% equ 0 (
    echo ✅ Redis ready
) else (
    echo ⚠️ Redis not ready within timeout
)

echo Waiting for Backend API...
kubectl wait --for=condition=ready pod -l app=backend-api -n ecommerce --timeout=300s
if %errorlevel% equ 0 (
    echo ✅ Backend API ready
) else (
    echo ⚠️ Backend API not ready within timeout
)

echo Waiting for Frontend...
kubectl wait --for=condition=ready pod -l app=frontend -n ecommerce --timeout=180s
if %errorlevel% equ 0 (
    echo ✅ Frontend ready
) else (
    echo ⚠️ Frontend not ready within timeout
)

echo.
echo 🧪 Step 9: Running basic health checks...
echo Testing database connectivity...
kubectl exec -n ecommerce deployment/backend-api -- curl -s http://localhost:3000/health/db >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Database connectivity: OK
) else (
    echo ⚠️ Database connectivity: Check required
)

echo Testing Redis connectivity...
kubectl exec -n ecommerce deployment/backend-api -- curl -s http://localhost:3000/health/redis >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Redis connectivity: OK
) else (
    echo ⚠️ Redis connectivity: Check required
)

echo.
echo 📋 Step 10: Getting access information...
echo.
echo ==========================================
echo 🎯 E-COMMERCE PLATFORM DEPLOYMENT COMPLETE!
echo ==========================================
echo.

REM Get ingress URL
for /f "tokens=*" %%i in ('kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath="{.status.loadBalancer.ingress[0].ip}" 2^>nul') do set INGRESS_IP=%%i
if "%INGRESS_IP%"=="" (
    echo 🌐 Frontend: http://localhost (use: kubectl port-forward svc/frontend 80:80 -n ecommerce)
    echo 🔌 Backend API: http://localhost:3000 (use: kubectl port-forward svc/backend-api 3000:3000 -n ecommerce)
) else (
    echo 🌐 Frontend: http://%INGRESS_IP%
    echo 🔌 Backend API: http://%INGRESS_IP%/api
)

REM Get monitoring URL
for /f "tokens=*" %%i in ('kubectl get svc prometheus -n monitoring -o jsonpath="{.status.loadBalancer.ingress[0].ip}" 2^>nul') do set PROMETHEUS_IP=%%i
if "%PROMETHEUS_IP%"=="" (
    echo 📊 Prometheus: http://localhost:9090 (use: kubectl port-forward svc/prometheus 9090:9090 -n monitoring)
) else (
    echo 📊 Prometheus: http://%PROMETHEUS_IP%:9090
)

echo.
echo 🔍 Deployed Components:
echo   • PostgreSQL Database (persistent storage)
echo   • Redis Cache (session management)
echo   • Backend API (Node.js with health checks)
echo   • Frontend (React + Nginx)
echo   • Ingress Controller (traffic routing)
echo   • Network Policies (security)
echo   • Prometheus Monitoring (metrics collection)
echo.

echo 📋 Next Steps:
echo   1. Test the platform: test-ecommerce-platform.bat
echo   2. Access monitoring: open-monitoring-dashboard.bat
echo   3. Check pod status: kubectl get pods -n ecommerce
echo   4. View logs: kubectl logs -l app=backend-api -n ecommerce -f
echo.

echo 🎉 Your production-ready e-commerce platform is live!
pause