@echo off
echo 🐳 PRACTICAL EXERCISES - PODS
echo =============================
echo.

echo 📝 Exercise 1: Simple Pod
echo --------------------------
echo Creating pod via command...
kubectl run exercise1 --image=httpd:alpine --port=80

echo Waiting for pod to be ready...
kubectl wait --for=condition=Ready pod/exercise1 --timeout=60s

echo Checking status...
kubectl get pods exercise1

echo Testing connectivity...
start /B kubectl port-forward pod/exercise1 8081:80
timeout /t 3 /nobreak >nul
echo Server response:
curl -s http://localhost:8081 | findstr /C:"It works"
taskkill /F /IM kubectl.exe >nul 2>&1

echo.
echo 📝 Exercise 2: Detailed Pod
echo ---------------------------
echo Applying detailed-pod.yaml...
kubectl apply -f detailed-pod.yaml

echo Waiting for pod to be ready...
kubectl wait --for=condition=Ready pod/webapp-example --timeout=60s

echo Checking environment variables...
kubectl exec webapp-example -- env | findstr /C:"ENVIRONMENT VERSION"

echo Checking resources...
kubectl describe pod webapp-example | findstr /C:"Limits:"

echo.
echo 📝 Exercise 3: Logs and Debug
echo -----------------------------
echo Logs from simple pod:
kubectl logs exercise1

echo.
echo Logs from detailed pod:
kubectl logs webapp-example

echo.
echo 📝 Exercise 4: Multi-container
echo ------------------------------
echo Applying multi-container pod...
kubectl apply -f multi-container-pod.yaml

echo Waiting for pod to be ready...
kubectl wait --for=condition=Ready pod/app-with-sidecar --timeout=60s

echo Checking containers in pod:
kubectl get pod app-with-sidecar -o jsonpath="{.spec.containers[*].name}"

echo.
echo Logs from main container:
kubectl logs app-with-sidecar -c web-app

echo.
echo Logs from sidecar:
kubectl logs app-with-sidecar -c log-collector

echo.
echo 🧹 Cleanup
echo ----------
echo Removing all created pods...
kubectl delete pod exercise1 webapp-example app-with-sidecar

echo.
echo ✅ EXERCISES COMPLETED!
echo You mastered the basic concepts of Pods!
echo.
pause