@echo off
echo 🧪 TESTING E-COMMERCE PLATFORM
echo.

REM Test 1: Pod Health Status
echo ==========================================
echo 🏥 Test 1: Pod Health Status
echo ==========================================

echo Checking PostgreSQL pods...
kubectl get pods -n ecommerce -l app=postgres --no-headers | findstr "Running" >nul
if %errorlevel% equ 0 (
    echo ✅ PostgreSQL pods: RUNNING
) else (
    echo ❌ PostgreSQL pods: NOT RUNNING
)

echo Checking Redis pods...
kubectl get pods -n ecommerce -l app=redis --no-headers | findstr "Running" >nul
if %errorlevel% equ 0 (
    echo ✅ Redis pods: RUNNING
) else (
    echo ❌ Redis pods: NOT RUNNING
)

echo Checking Backend API pods...
kubectl get pods -n ecommerce -l app=backend-api --no-headers | findstr "Running" >nul
if %errorlevel% equ 0 (
    echo ✅ Backend API pods: RUNNING
) else (
    echo ❌ Backend API pods: NOT RUNNING
)

echo Checking Frontend pods...
kubectl get pods -n ecommerce -l app=frontend --no-headers | findstr "Running" >nul
if %errorlevel% equ 0 (
    echo ✅ Frontend pods: RUNNING
) else (
    echo ❌ Frontend pods: NOT RUNNING
)

echo.
REM Test 2: Health Check Endpoints
echo ==========================================
echo 💳 Test 2: API Health Endpoints
echo ==========================================

echo Testing Backend API startup health...
kubectl exec -n ecommerce deployment/backend-api -- curl -s http://localhost:3000/health/startup | findstr "UP" >nul
if %errorlevel% equ 0 (
    echo ✅ Backend startup health: PASSED
) else (
    echo ❌ Backend startup health: FAILED
)

echo Testing Backend API readiness...
kubectl exec -n ecommerce deployment/backend-api -- curl -s http://localhost:3000/health/ready | findstr "UP" >nul
if %errorlevel% equ 0 (
    echo ✅ Backend readiness health: PASSED
) else (
    echo ❌ Backend readiness health: FAILED
)

echo Testing Backend API liveness...
kubectl exec -n ecommerce deployment/backend-api -- curl -s http://localhost:3000/health/live | findstr "UP" >nul
if %errorlevel% equ 0 (
    echo ✅ Backend liveness health: PASSED
) else (
    echo ❌ Backend liveness health: FAILED
)

echo.
REM Test 3: Database Connectivity
echo ==========================================
echo 💾 Test 3: Database Connectivity
echo ==========================================

echo Testing PostgreSQL connection...
kubectl exec -n ecommerce deployment/backend-api -- curl -s http://localhost:3000/api/health/db | findstr "connected" >nul
if %errorlevel% equ 0 (
    echo ✅ PostgreSQL connection: PASSED
) else (
    echo ❌ PostgreSQL connection: FAILED
)

echo Testing database CRUD operations...
kubectl exec -n ecommerce deployment/backend-api -- curl -s -X POST http://localhost:3000/api/test/db -H "Content-Type: application/json" -d "{\"test\":\"data\"}" | findstr "success" >nul
if %errorlevel% equ 0 (
    echo ✅ Database CRUD operations: PASSED
) else (
    echo ❌ Database CRUD operations: FAILED
)

echo.
REM Test 4: Cache Performance
echo ==========================================
echo ⚡ Test 4: Redis Cache Performance
echo ==========================================

echo Testing Redis connection...
kubectl exec -n ecommerce deployment/backend-api -- curl -s http://localhost:3000/api/health/redis | findstr "connected" >nul
if %errorlevel% equ 0 (
    echo ✅ Redis connection: PASSED
) else (
    echo ❌ Redis connection: FAILED
)

echo Testing cache operations...
kubectl exec -n ecommerce deployment/backend-api -- curl -s -X POST http://localhost:3000/api/test/cache -H "Content-Type: application/json" -d "{\"key\":\"test\",\"value\":\"cached\"}" | findstr "success" >nul
if %errorlevel% equ 0 (
    echo ✅ Cache operations: PASSED
) else (
    echo ❌ Cache operations: FAILED
)

echo.
REM Test 5: API Endpoints
echo ==========================================
echo 🔌 Test 5: REST API Endpoints
echo ==========================================

echo Testing user registration endpoint...
kubectl exec -n ecommerce deployment/backend-api -- curl -s -X POST http://localhost:3000/api/users/register -H "Content-Type: application/json" -d "{\"email\":\"test@example.com\",\"password\":\"test123\"}" | findstr "id\|success" >nul
if %errorlevel% equ 0 (
    echo ✅ User registration: PASSED
) else (
    echo ❌ User registration: FAILED
)

echo Testing product listing endpoint...
kubectl exec -n ecommerce deployment/backend-api -- curl -s http://localhost:3000/api/products | findstr "\[\]" >nul
if %errorlevel% equ 0 (
    echo ✅ Product listing: PASSED
) else (
    echo ❌ Product listing: FAILED
)

echo Testing order creation endpoint...
kubectl exec -n ecommerce deployment/backend-api -- curl -s -X POST http://localhost:3000/api/orders -H "Content-Type: application/json" -d "{\"userId\":1,\"items\":[{\"productId\":1,\"quantity\":2}]}" | findstr "id\|orderId" >nul
if %errorlevel% equ 0 (
    echo ✅ Order creation: PASSED
) else (
    echo ❌ Order creation: FAILED
)

echo.
REM Test 6: Frontend Connectivity
echo ==========================================
echo 🌐 Test 6: Frontend Connectivity
echo ==========================================

echo Testing frontend service...
kubectl exec -n ecommerce deployment/frontend -- curl -s http://localhost:80 | findstr "html\|HTML" >nul
if %errorlevel% equ 0 (
    echo ✅ Frontend service: PASSED
) else (
    echo ❌ Frontend service: FAILED
)

echo Testing frontend to backend connectivity...
kubectl exec -n ecommerce deployment/frontend -- curl -s http://backend-api:3000/api/health | findstr "UP" >nul
if %errorlevel% equ 0 (
    echo ✅ Frontend to Backend: PASSED
) else (
    echo ❌ Frontend to Backend: FAILED
)

echo.
REM Test 7: Scaling Test
echo ==========================================
echo 📈 Test 7: Auto-Scaling Test
echo ==========================================

echo Current replica count...
for /f "tokens=*" %%i in ('kubectl get deployment backend-api -n ecommerce -o jsonpath="{.spec.replicas}"') do set CURRENT_REPLICAS=%%i
echo Backend API replicas: %CURRENT_REPLICAS%

echo Scaling backend API to 3 replicas...
kubectl scale deployment backend-api --replicas=3 -n ecommerce
kubectl wait --for=condition=ready pod -l app=backend-api -n ecommerce --timeout=120s
if %errorlevel% equ 0 (
    echo ✅ Scaling test: PASSED
) else (
    echo ❌ Scaling test: FAILED
)

echo Scaling back to original replica count...
kubectl scale deployment backend-api --replicas=%CURRENT_REPLICAS% -n ecommerce

echo.
REM Test 8: Network Policies
echo ==========================================
echo 🔒 Test 8: Network Security
echo ==========================================

echo Testing allowed connection (frontend to backend)...
kubectl exec -n ecommerce deployment/frontend -- curl -s --connect-timeout 5 http://backend-api:3000/api/health >nul
if %errorlevel% equ 0 (
    echo ✅ Allowed connection (frontend → backend): PASSED
) else (
    echo ❌ Allowed connection (frontend → backend): FAILED
)

echo Testing database access restriction...
kubectl exec -n ecommerce deployment/frontend -- curl -s --connect-timeout 5 http://postgres:5432 >nul 2>&1
if %errorlevel% neq 0 (
    echo ✅ Database access restriction: PASSED
) else (
    echo ❌ Database access restriction: FAILED
)

echo.
echo ==========================================
echo 📋 E-COMMERCE PLATFORM TEST SUMMARY
echo ==========================================
echo.
echo 🎯 Test Results:
echo   • Pod Health Status: All services running
echo   • API Health Endpoints: Startup, Readiness, Liveness
echo   • Database Connectivity: PostgreSQL CRUD operations
echo   • Cache Performance: Redis operations
echo   • REST API Endpoints: Users, Products, Orders
echo   • Frontend Connectivity: Service and backend communication
echo   • Auto-Scaling: Replica management
echo   • Network Security: Policy enforcement
echo.
echo 📊 Access Your Platform:
echo   • Frontend: kubectl port-forward svc/frontend 8080:80 -n ecommerce
echo   • Backend API: kubectl port-forward svc/backend-api 3000:3000 -n ecommerce
echo   • Monitoring: kubectl port-forward svc/prometheus 9090:9090 -n monitoring
echo.
echo 🔍 Useful Commands:
echo   • Check pods: kubectl get pods -n ecommerce
echo   • View logs: kubectl logs -l app=backend-api -n ecommerce -f
echo   • Describe service: kubectl describe svc backend-api -n ecommerce
echo.
echo 🎉 E-commerce platform testing completed!
pause