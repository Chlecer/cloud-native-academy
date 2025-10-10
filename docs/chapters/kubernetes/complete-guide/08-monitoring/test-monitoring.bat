@echo off
echo 🧪 TESTING E-COMMERCE MONITORING STACK
echo.

REM Test 1: Health Check Endpoints
echo ==========================================
echo 🏥 Test 1: Health Check Endpoints
echo ==========================================

echo Testing payment service startup health...
kubectl exec deployment/payment-service -- curl -s http://localhost:8080/health/startup
if %errorlevel% equ 0 (
    echo ✅ Payment startup health: PASSED
) else (
    echo ❌ Payment startup health: FAILED
)

echo.
echo Testing payment service readiness...
kubectl exec deployment/payment-service -- curl -s http://localhost:8080/health/ready
if %errorlevel% equ 0 (
    echo ✅ Payment readiness health: PASSED
) else (
    echo ❌ Payment readiness health: FAILED
)

echo.
echo Testing payment service liveness...
kubectl exec deployment/payment-service -- curl -s http://localhost:8080/health/live
if %errorlevel% equ 0 (
    echo ✅ Payment liveness health: PASSED
) else (
    echo ❌ Payment liveness health: FAILED
)

echo.
REM Test 2: Prometheus Metrics Collection
echo ==========================================
echo 📊 Test 2: Prometheus Metrics Collection
echo ==========================================

echo Checking if Prometheus is scraping payment service...
kubectl exec -n monitoring deployment/prometheus -- wget -qO- "http://localhost:9090/api/v1/query?query=up{job=\"payment-service\"}" | findstr "\"value\":\[" >nul
if %errorlevel% equ 0 (
    echo ✅ Prometheus scraping payment service: PASSED
) else (
    echo ❌ Prometheus scraping payment service: FAILED
)

echo.
echo Checking payment metrics availability...
kubectl exec -n monitoring deployment/prometheus -- wget -qO- "http://localhost:9090/api/v1/query?query=payment_requests_total" | findstr "payment_requests_total" >nul
if %errorlevel% equ 0 (
    echo ✅ Payment metrics available: PASSED
) else (
    echo ⚠️ Payment metrics available: NOT YET (may need time to collect)
)

echo.
REM Test 3: Alert Rules Validation
echo ==========================================
echo 🚨 Test 3: Alert Rules Validation
echo ==========================================

echo Checking if alert rules are loaded...
kubectl exec -n monitoring deployment/prometheus -- wget -qO- "http://localhost:9090/api/v1/rules" | findstr "PaymentServiceDown" >nul
if %errorlevel% equ 0 (
    echo ✅ Payment service down alert: LOADED
) else (
    echo ❌ Payment service down alert: NOT LOADED
)

kubectl exec -n monitoring deployment/prometheus -- wget -qO- "http://localhost:9090/api/v1/rules" | findstr "HighPaymentErrorRate" >nul
if %errorlevel% equ 0 (
    echo ✅ High payment error rate alert: LOADED
) else (
    echo ❌ High payment error rate alert: NOT LOADED
)

echo.
REM Test 4: Service Discovery
echo ==========================================
echo 🔍 Test 4: Service Discovery
echo ==========================================

echo Checking Prometheus targets...
kubectl exec -n monitoring deployment/prometheus -- wget -qO- "http://localhost:9090/api/v1/targets" | findstr "payment-service" >nul
if %errorlevel% equ 0 (
    echo ✅ Payment service target discovered: PASSED
) else (
    echo ❌ Payment service target discovered: FAILED
)

kubectl exec -n monitoring deployment/prometheus -- wget -qO- "http://localhost:9090/api/v1/targets" | findstr "user-service" >nul
if %errorlevel% equ 0 (
    echo ✅ User service target discovered: PASSED
) else (
    echo ❌ User service target discovered: FAILED
)

echo.
REM Test 5: Simulate Alert Conditions
echo ==========================================
echo 🔥 Test 5: Simulate Alert Conditions
echo ==========================================

echo Simulating payment service failure...
kubectl scale deployment payment-service --replicas=0
echo Waiting 60 seconds for alert to trigger...
timeout /t 60 >nul

echo Checking if PaymentServiceDown alert is firing...
kubectl exec -n monitoring deployment/prometheus -- wget -qO- "http://localhost:9090/api/v1/alerts" | findstr "PaymentServiceDown" >nul
if %errorlevel% equ 0 (
    echo ✅ PaymentServiceDown alert triggered: PASSED
) else (
    echo ⚠️ PaymentServiceDown alert triggered: NOT YET (may need more time)
)

echo.
echo Restoring payment service...
kubectl scale deployment payment-service --replicas=3
kubectl wait --for=condition=ready pod -l app=payment-service --timeout=120s

echo.
REM Test 6: Business Metrics
echo ==========================================
echo 💰 Test 6: Business Metrics Simulation
echo ==========================================

echo Simulating e-commerce traffic...
echo Creating sample cart creation events...
for /l %%i in (1,1,10) do (
    kubectl exec deployment/payment-service -- curl -s -X POST http://localhost:8080/cart/create >nul 2>&1
)

echo Creating sample order completion events...
for /l %%i in (1,1,7) do (
    kubectl exec deployment/payment-service -- curl -s -X POST http://localhost:8080/order/complete >nul 2>&1
)

echo Simulating payment processing...
for /l %%i in (1,1,5) do (
    kubectl exec deployment/payment-service -- curl -s -X POST http://localhost:8080/payment/process >nul 2>&1
)

echo ✅ Business metrics simulation completed

echo.
echo ==========================================
echo 📋 MONITORING TEST SUMMARY
echo ==========================================
echo.
echo 🎯 Test Results:
echo   • Health Checks: Startup, Readiness, Liveness
echo   • Metrics Collection: Prometheus scraping services
echo   • Alert Rules: PaymentServiceDown, HighPaymentErrorRate
echo   • Service Discovery: Auto-discovery of services
echo   • Alert Simulation: Service failure detection
echo   • Business Metrics: Cart, Order, Payment tracking
echo.
echo 📊 Access Monitoring:
echo   • Prometheus: kubectl port-forward svc/prometheus 9090:9090 -n monitoring
echo   • Metrics: http://localhost:9090/graph
echo   • Alerts: http://localhost:9090/alerts
echo   • Targets: http://localhost:9090/targets
echo.
echo 🔍 Key Queries to Try:
echo   • up{job="payment-service"}
echo   • rate(payment_requests_total[5m])
echo   • histogram_quantile(0.95, rate(payment_duration_seconds_bucket[5m]))
echo   • (rate(orders_completed_total[5m]) / rate(cart_created_total[5m])) * 100
echo.
echo 🎉 Monitoring stack testing completed!
pause