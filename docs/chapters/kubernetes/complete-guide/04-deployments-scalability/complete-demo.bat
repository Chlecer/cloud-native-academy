@echo off
echo 📈 COMPLETE DEMO - DEPLOYMENTS
echo ==============================
echo.

echo 🚀 Step 1: Creating Initial Deployment
echo --------------------------------------
kubectl apply -f basic-deployment.yaml

echo Waiting for deployment to be ready...
kubectl wait --for=condition=Available deployment/webapp-deployment --timeout=120s

echo Deployment status:
kubectl get deployment webapp-deployment

echo Created pods:
kubectl get pods -l app=webapp

echo.
echo 🌐 Step 2: Creating Service
echo ---------------------------
kubectl apply -f deployment-service.yaml

echo Service created:
kubectl get service webapp-service

echo Testing application:
echo Access http://localhost:30100
curl -s http://localhost:30100

echo.
echo 📊 Step 3: Scaling Application
echo ------------------------------
echo Scaling to 5 replicas...
kubectl scale deployment webapp-deployment --replicas=5

echo Waiting for scaling...
kubectl wait --for=condition=Available deployment/webapp-deployment --timeout=60s

echo Pods after scaling:
kubectl get pods -l app=webapp

echo Testing load balancing with 5 pods:
for /L %%i in (1,1,5) do (
    echo Request %%i:
    curl -s http://localhost:30100 | findstr /C:"Pod: Timestamp:"
    echo ---
    timeout /t 1 /nobreak >nul
)

echo.
echo 🔄 Step 4: Rolling Update
echo -------------------------
echo Starting update to v2...
kubectl apply -f deployment-v2.yaml

echo Following the rollout:
kubectl rollout status deployment/webapp-deployment

echo Pods after update:
kubectl get pods -l app=webapp

echo Testing new version:
curl -s http://localhost:30100

echo.
echo 📜 Step 5: Rollout History
echo --------------------------
echo Deployment history:
kubectl rollout history deployment/webapp-deployment

echo.
echo ⏪ Step 6: Rollback (Demonstration)
echo ----------------------------------
echo Rolling back to previous version...
kubectl rollout undo deployment/webapp-deployment

echo Waiting for rollback...
kubectl rollout status deployment/webapp-deployment

echo Testing after rollback:
curl -s http://localhost:30100

echo.
echo 🔍 Step 7: Detailed Information
echo -------------------------------
echo Deployment details:
kubectl describe deployment webapp-deployment

echo.
echo Managed ReplicaSet:
kubectl get replicaset -l app=webapp

echo.
echo 📊 Step 8: Monitoring
echo ---------------------
echo Resource usage:
kubectl top pods -l app=webapp 2>nul || echo "Metrics server not available (normal in Docker Desktop)"

echo.
echo Recent events:
kubectl get events --sort-by=.metadata.creationTimestamp

echo.
echo 🧹 Cleanup (optional)
echo --------------------
echo To clean everything:
echo kubectl delete deployment webapp-deployment
echo kubectl delete service webapp-service

echo.
echo ✅ DEMO COMPLETED!
echo Application running at: http://localhost:30100
echo Use 'kubectl get pods -w' to monitor changes in real time
echo.
pause