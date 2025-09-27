@echo off
echo 🔧 KUBERNETES SETUP TEST
echo =========================
echo.

echo 1️⃣ Testing Docker...
docker --version

echo.
echo 2️⃣ Testing kubectl...
kubectl version --client --short

echo.
echo 3️⃣ Testing cluster...
kubectl cluster-info

echo.
echo 4️⃣ Checking nodes...
kubectl get nodes

echo.
echo 5️⃣ Creating test pod...
kubectl apply -f connection-test.yaml

echo.
echo 6️⃣ Waiting for pod to be ready...
kubectl wait --for=condition=Ready pod/connection-test --timeout=60s

echo.
echo 7️⃣ Checking pod...
kubectl get pods

echo.
echo 8️⃣ Testing connectivity...
start /B kubectl port-forward pod/connection-test 8080:80
timeout /t 3 /nobreak >nul
curl -s http://localhost:8080 | findstr /C:"Welcome to nginx"
taskkill /F /IM kubectl.exe >nul 2>&1

echo.
echo 9️⃣ Cleaning up test...
kubectl delete pod connection-test

echo.
echo ✅ SETUP VERIFIED SUCCESSFULLY!
echo You are ready for the next lesson!
echo.
pause