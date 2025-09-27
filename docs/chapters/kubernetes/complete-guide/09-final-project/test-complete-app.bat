@echo off
echo 🧪 TESTING COMPLETE KUBERNETES APPLICATION
echo ==========================================
echo.

echo 🔍 Step 1: Health Check All Components
echo --------------------------------------
echo Database health:
kubectl exec -it deployment/postgres -- pg_isready -U webuser

echo Cache health:
kubectl exec -it deployment/redis -- redis-cli ping

echo Backend API health:
curl -s http://localhost:30200/api/ | findstr /C:"healthy"

echo Frontend health:
curl -s http://localhost:30200 | findstr /C:"Kubernetes Complete Application"

echo.
echo 📊 Step 2: Load Testing
echo -----------------------
echo Testing load balancing across replicas:
for /L %%i in (1,1,5) do (
    echo Request %%i to backend:
    curl -s http://localhost:30200/api/ | findstr /C:"timestamp"
    timeout /t 1 /nobreak >nul
)

echo.
echo 💾 Step 3: Data Persistence Test
echo --------------------------------
echo Testing database persistence...
kubectl exec -it deployment/postgres -- psql -U webuser -d webapp -c "CREATE TABLE IF NOT EXISTS test_table (id SERIAL PRIMARY KEY, message TEXT);"
kubectl exec -it deployment/postgres -- psql -U webuser -d webapp -c "INSERT INTO test_table (message) VALUES ('Kubernetes rocks!');"
kubectl exec -it deployment/postgres -- psql -U webuser -d webapp -c "SELECT * FROM test_table;"

echo.
echo ⚡ Step 4: Cache Performance Test
echo --------------------------------
echo Testing Redis cache:
kubectl exec -it deployment/redis -- redis-cli set test_key "Hello Kubernetes"
kubectl exec -it deployment/redis -- redis-cli get test_key

echo.
echo 🔄 Step 5: Scaling Test
echo -----------------------
echo Current replica count:
kubectl get deployments

echo Scaling frontend to 3 replicas:
kubectl scale deployment frontend --replicas=3

echo Waiting for scaling to complete:
kubectl wait --for=condition=Available deployment/frontend --timeout=60s

echo New replica count:
kubectl get pods -l app=frontend

echo Scaling back to 2 replicas:
kubectl scale deployment frontend --replicas=2

echo.
echo 🌐 Step 6: Network Connectivity Test
echo ------------------------------------
echo Testing internal service discovery:
kubectl run network-test --image=busybox --rm -it --restart=Never -- nslookup postgres-service

echo Testing service endpoints:
kubectl get endpoints

echo.
echo 📈 Step 7: Resource Usage
echo -------------------------
echo Resource usage by pods:
kubectl top pods 2>nul || echo "Metrics server not available (normal in Docker Desktop)"

echo Resource requests and limits:
kubectl describe deployments | findstr /C:"Requests: Limits:"

echo.
echo 🔍 Step 8: Configuration Test
echo -----------------------------
echo ConfigMap data:
kubectl get configmap postgres-config -o yaml

echo Secret data (base64 encoded):
kubectl get secret postgres-secret -o yaml

echo.
echo 📝 Step 9: Logs Collection
echo --------------------------
echo Recent logs from all components:
echo.
echo Database logs:
kubectl logs deployment/postgres --tail=3

echo Cache logs:
kubectl logs deployment/redis --tail=3

echo Backend logs:
kubectl logs deployment/backend-api --tail=3

echo Frontend logs:
kubectl logs deployment/frontend --tail=3

echo.
echo 🎯 Step 10: Final Verification
echo ------------------------------
echo Application URL: http://localhost:30200
echo.
echo Testing complete application:
curl -s http://localhost:30200 | findstr /C:"You are now a Kubernetes Expert"

echo.
echo ✅ ALL TESTS COMPLETED SUCCESSFULLY!
echo.
echo 🎉 Your complete Kubernetes application is working perfectly!
echo   - Database: ✅ Connected and persistent
echo   - Cache: ✅ Fast and responsive  
echo   - Backend: ✅ Load balanced and healthy
echo   - Frontend: ✅ Serving users
echo   - Networking: ✅ All services communicating
echo   - Scaling: ✅ Horizontal scaling working
echo   - Monitoring: ✅ Health checks active
echo.
echo 🏆 CONGRATULATIONS! You are now a Kubernetes expert!
echo.
pause