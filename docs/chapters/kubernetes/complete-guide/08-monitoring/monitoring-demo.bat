@echo off
echo 📊 MONITORING AND OBSERVABILITY DEMO
echo ====================================
echo.

echo 📝 Step 1: Deploying Monitored Application
echo -------------------------------------------
kubectl apply -f health-check-example.yaml

echo Waiting for deployment to be ready...
kubectl wait --for=condition=Available deployment/monitored-app --timeout=60s

echo.
echo 📝 Step 2: Health Check Status
echo ------------------------------
echo Checking pod health:
kubectl get pods -l app=monitored-app

echo Detailed health check info:
kubectl describe pods -l app=monitored-app | findstr /C:"Liveness: Readiness: Startup:"

echo.
echo 📝 Step 3: Resource Monitoring
echo ------------------------------
echo Current resource usage:
kubectl top pods -l app=monitored-app 2>nul || echo "Metrics server not available (normal in Docker Desktop)"

echo Resource requests and limits:
kubectl describe pods -l app=monitored-app | findstr /C:"Requests: Limits:"

echo.
echo 📝 Step 4: Log Collection
echo -------------------------
echo Application logs:
kubectl logs -l app=monitored-app --tail=10

echo.
echo 📝 Step 5: Events Monitoring
echo ----------------------------
echo Recent events:
kubectl get events --sort-by=.metadata.creationTimestamp --field-selector involvedObject.kind=Pod | findstr monitored-app

echo.
echo 📝 Step 6: Service Health
echo -------------------------
echo Service endpoints:
kubectl get endpoints monitored-app-service

echo Testing service health:
kubectl get service monitored-app-service
start /B kubectl port-forward service/monitored-app-service 8080:80
timeout /t 3 /nobreak >nul
curl -s http://localhost:8080 | findstr /C:"Welcome"
taskkill /F /IM kubectl.exe >nul 2>&1

echo.
echo 📝 Step 7: Troubleshooting Simulation
echo -------------------------------------
echo Simulating pod failure (scaling to 0 and back):
kubectl scale deployment monitored-app --replicas=0
timeout /t 5 /nobreak >nul
kubectl scale deployment monitored-app --replicas=2

echo Watching recovery:
kubectl get pods -l app=monitored-app -w --timeout=30s

echo.
echo 📝 Step 8: Monitoring Summary
echo -----------------------------
echo Deployment status:
kubectl get deployment monitored-app

echo Pod status:
kubectl get pods -l app=monitored-app

echo Service status:
kubectl get service monitored-app-service

echo.
echo 🧹 Cleanup
echo ----------
kubectl delete -f health-check-example.yaml

echo.
echo ✅ MONITORING DEMO COMPLETED!
echo You learned how to monitor and troubleshoot Kubernetes applications!
echo.
pause