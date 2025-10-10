@echo off
echo 📊 OPENING MONITORING DASHBOARD
echo.

REM Check if kubectl is available
kubectl version --client >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ kubectl not found. Please install kubectl first.
    exit /b 1
)

echo 🔍 Checking monitoring services...
kubectl get pods -n monitoring >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Monitoring namespace not found. Deploy the platform first.
    echo Run: deploy-ecommerce-platform.bat
    exit /b 1
)

echo ✅ Monitoring services found

echo.
echo 📊 Setting up port forwarding for monitoring services...

REM Check if Prometheus is running
kubectl get pod -n monitoring -l app=prometheus --no-headers | findstr "Running" >nul
if %errorlevel% equ 0 (
    echo ✅ Prometheus is running
    echo 🚀 Starting Prometheus port-forward on http://localhost:9090
    start "Prometheus Dashboard" cmd /c "kubectl port-forward svc/prometheus 9090:9090 -n monitoring"
    timeout /t 3 >nul
) else (
    echo ⚠️ Prometheus not running
)

REM Check if Grafana is running
kubectl get pod -n monitoring -l app=grafana --no-headers | findstr "Running" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Grafana is running
    echo 🚀 Starting Grafana port-forward on http://localhost:3001
    start "Grafana Dashboard" cmd /c "kubectl port-forward svc/grafana 3001:3000 -n monitoring"
    timeout /t 3 >nul
) else (
    echo ℹ️ Grafana not available (optional component)
)

REM Check if AlertManager is running
kubectl get pod -n monitoring -l app=alertmanager --no-headers | findstr "Running" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ AlertManager is running
    echo 🚀 Starting AlertManager port-forward on http://localhost:9093
    start "AlertManager" cmd /c "kubectl port-forward svc/alertmanager 9093:9093 -n monitoring"
    timeout /t 3 >nul
) else (
    echo ℹ️ AlertManager not available (optional component)
)

echo.
echo 🌐 Opening monitoring dashboards in browser...
timeout /t 5 >nul

REM Open Prometheus in default browser
start http://localhost:9090

REM Try to open Grafana if available
curl -s http://localhost:3001 >nul 2>&1
if %errorlevel% equ 0 (
    timeout /t 2 >nul
    start http://localhost:3001
)

echo.
echo ==========================================
echo 📊 MONITORING DASHBOARD ACCESS
echo ==========================================
echo.
echo 🎯 Available Dashboards:
echo   📈 Prometheus: http://localhost:9090
echo   📊 Grafana: http://localhost:3001 (if available)
echo   🚨 AlertManager: http://localhost:9093 (if available)
echo.
echo 🔍 Key Metrics to Explore:
echo.
echo 📊 Prometheus Queries:
echo   • up{job="backend-api"} - Service availability
echo   • rate(http_requests_total[5m]) - Request rate
echo   • histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) - 95th percentile latency
echo   • container_memory_usage_bytes{pod=~"backend-api.*"} - Memory usage
echo   • rate(postgres_connections_total[5m]) - Database connections
echo.
echo 🎯 Business Metrics:
echo   • rate(user_registrations_total[5m]) - New user signups
echo   • rate(orders_created_total[5m]) - Order creation rate
echo   • rate(payment_processed_total[5m]) - Payment processing
echo   • avg(shopping_cart_items) - Average cart size
echo.
echo 🚨 Alert Conditions:
echo   • Backend API down for >30 seconds
echo   • Error rate >5% for >2 minutes
echo   • Response time >3 seconds for >5 minutes
echo   • Database connections >90% of limit
echo   • Memory usage >80% for >5 minutes
echo.
echo 📋 Useful Prometheus Features:
echo   • Graph tab: Visualize metrics over time
echo   • Alerts tab: View active alerts
echo   • Targets tab: Check service discovery
echo   • Status → Configuration: View Prometheus config
echo.
echo 💡 Pro Tips:
echo   • Use rate() for counters, avg() for gauges
echo   • Add [5m] for 5-minute rate calculations
echo   • Use histogram_quantile() for percentiles
echo   • Combine metrics with operators (+, -, *, /)
echo.
echo ⚠️ Note: Keep these terminal windows open to maintain port-forwarding
echo Press Ctrl+C in the port-forward windows to stop access
echo.
pause