@echo off
echo 📊 DEPLOYING PRODUCTION E-COMMERCE MONITORING STACK
echo.

REM Check if kubectl is available
kubectl version --client >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ kubectl not found. Please install kubectl first.
    exit /b 1
)

echo 📦 Step 1: Creating monitoring namespace...
kubectl create namespace monitoring 2>nul
if %errorlevel% equ 0 (
    echo ✅ Monitoring namespace created
) else (
    echo ℹ️ Monitoring namespace already exists
)

echo.
echo 🚀 Step 2: Deploying e-commerce services with health checks...
kubectl apply -f ecommerce-health-checks.yaml
if %errorlevel% equ 0 (
    echo ✅ E-commerce services deployed
) else (
    echo ❌ Failed to deploy e-commerce services
    exit /b 1
)

echo.
echo 📊 Step 3: Deploying Prometheus monitoring stack...
kubectl apply -f prometheus-stack.yaml
if %errorlevel% equ 0 (
    echo ✅ Prometheus stack deployed
) else (
    echo ❌ Failed to deploy Prometheus stack
    exit /b 1
)

echo.
echo 🔔 Step 4: Configuring alert rules...
kubectl apply -f prometheus-alerts.yaml
if %errorlevel% equ 0 (
    echo ✅ Alert rules configured
) else (
    echo ❌ Failed to configure alert rules
    exit /b 1
)

echo.
echo ⏳ Step 5: Waiting for services to be ready...
echo Waiting for payment service...
kubectl wait --for=condition=ready pod -l app=payment-service --timeout=300s
if %errorlevel% equ 0 (
    echo ✅ Payment service ready
) else (
    echo ⚠️ Payment service not ready within timeout
)

echo Waiting for Prometheus...
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=300s
if %errorlevel% equ 0 (
    echo ✅ Prometheus ready
) else (
    echo ⚠️ Prometheus not ready within timeout
)

echo.
echo 🧪 Step 6: Testing monitoring endpoints...
echo Testing payment service health...
kubectl port-forward svc/payment-service 8080:80 >nul 2>&1 &
timeout /t 3 >nul
curl -s http://localhost:8080/health/ready >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Payment service health check working
) else (
    echo ⚠️ Payment service health check not responding
)

echo.
echo 📈 Step 7: Getting access information...
echo.
echo ==========================================
echo 🎯 MONITORING DEPLOYMENT COMPLETE!
echo ==========================================
echo.

REM Get Prometheus URL
for /f "tokens=*" %%i in ('kubectl get svc prometheus -n monitoring -o jsonpath="{.status.loadBalancer.ingress[0].ip}" 2^>nul') do set PROMETHEUS_IP=%%i
if "%PROMETHEUS_IP%"=="" (
    echo 📊 Prometheus: http://localhost:9090 (use: kubectl port-forward svc/prometheus 9090:9090 -n monitoring)
) else (
    echo 📊 Prometheus: http://%PROMETHEUS_IP%:9090
)

echo.
echo 🔍 Key Metrics to Monitor:
echo   • Payment Success Rate: payment_requests_total{status="success"}
echo   • Payment Latency: payment_duration_seconds
echo   • User Login Rate: login_attempts_total
echo   • Conversion Rate: orders_completed_total / cart_created_total
echo   • Error Rates: http_requests_total{status=~"5.."}
echo.

echo 🚨 Critical Alerts Configured:
echo   • Payment Service Down (30s threshold)
echo   • High Payment Error Rate (>5%)
echo   • High Payment Latency (>3s)
echo   • Database Connection Pool Exhaustion (>90%)
echo   • Low Conversion Rate (<2.5%)
echo.

echo 📋 Next Steps:
echo   1. Access Prometheus: kubectl port-forward svc/prometheus 9090:9090 -n monitoring
echo   2. Check service health: kubectl get pods -l app=payment-service
echo   3. View logs: kubectl logs -l app=payment-service -f
echo   4. Test alerts: kubectl exec -it deployment/payment-service -- curl localhost:8080/health/ready
echo.

echo 🎉 E-commerce monitoring stack is ready for production!
pause