@echo off
echo 📊 AUTOSCALING AND HPA DEMO
echo ===========================
echo.

echo 📝 Step 1: Deploying HPA Application
echo -------------------------------------
kubectl apply -f hpa-cpu-example.yaml

echo Waiting for deployment to be ready...
kubectl wait --for=condition=Available deployment/hpa-demo-app --timeout=60s

echo Initial state:
kubectl get deployment hpa-demo-app
kubectl get hpa hpa-demo-app-hpa

echo.
echo 📝 Step 2: HPA Status
echo ---------------------
echo HPA details:
kubectl describe hpa hpa-demo-app-hpa

echo Current metrics:
kubectl top pods -l app=hpa-demo-app 2>nul || echo "Metrics server not available (normal in Docker Desktop)"

echo.
echo 📝 Step 3: Load Testing Setup
echo -----------------------------
kubectl apply -f load-generator.yaml

echo Waiting for load generator...
kubectl wait --for=condition=Ready pod/load-generator --timeout=60s

echo.
echo 📝 Step 4: Generating Load
echo --------------------------
echo Starting load test...
kubectl exec load-generator -- sh -c "for i in \$(seq 1 1000); do wget -q -O- http://hpa-demo-service/cpu-load; done" &

echo Monitoring HPA scaling (this may take a few minutes):
for /L %%i in (1,1,10) do (
    echo.
    echo "Check %%i - $(date /t) $(time /t)"
    kubectl get hpa hpa-demo-app-hpa
    kubectl get pods -l app=hpa-demo-app
    timeout /t 30 /nobreak >nul
)

echo.
echo 📝 Step 5: Scaling Events
echo -------------------------
echo Recent HPA events:
kubectl get events --field-selector involvedObject.name=hpa-demo-app-hpa --sort-by=.metadata.creationTimestamp

echo.
echo 📝 Step 6: Manual Scaling Test
echo ------------------------------
echo Current replicas:
kubectl get deployment hpa-demo-app

echo Manual scale (HPA will override):
kubectl scale deployment hpa-demo-app --replicas=5

echo Waiting for HPA to adjust:
timeout /t 60 /nobreak >nul
kubectl get hpa hpa-demo-app-hpa

echo.
echo 📝 Step 7: Scale Down Test
echo --------------------------
echo Stopping load generation...
kubectl delete pod load-generator

echo Monitoring scale down (takes longer due to stabilization):
for /L %%i in (1,1,5) do (
    echo.
    echo "Scale down check %%i:"
    kubectl get hpa hpa-demo-app-hpa
    kubectl get pods -l app=hpa-demo-app
    timeout /t 60 /nobreak >nul
)

echo.
echo 📝 Step 8: HPA Analysis
echo -----------------------
echo Final HPA status:
kubectl describe hpa hpa-demo-app-hpa

echo Deployment final state:
kubectl get deployment hpa-demo-app

echo.
echo 🧹 Cleanup
echo ----------
kubectl delete -f hpa-cpu-example.yaml
kubectl delete -f load-generator.yaml

echo.
echo ✅ AUTOSCALING DEMO COMPLETED!
echo You learned Horizontal Pod Autoscaling!
echo.
pause