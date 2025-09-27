@echo off
echo 🌍 ADVANCED NETWORKING DEMO
echo ===========================
echo.

echo 📝 Step 1: Installing Ingress Controller
echo ----------------------------------------
echo Installing NGINX Ingress Controller...
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

echo Waiting for Ingress Controller to be ready...
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s

echo.
echo 📝 Step 2: Deploying Application with Ingress
echo ---------------------------------------------
kubectl apply -f ingress-example.yaml

echo Waiting for deployment to be ready...
kubectl wait --for=condition=Available deployment/web-app --timeout=60s

echo.
echo 📝 Step 3: Testing Ingress
echo --------------------------
echo Checking Ingress status:
kubectl get ingress

echo Testing application via Ingress:
timeout /t 10 /nobreak >nul
curl -s http://localhost | findstr /C:"Web Application"

echo.
echo 📝 Step 4: DNS Resolution Test
echo ------------------------------
echo Testing internal DNS:
kubectl run dns-test --image=busybox --rm -it --restart=Never -- nslookup web-app-service

echo.
echo 📝 Step 5: Network Information
echo ------------------------------
echo Services:
kubectl get services

echo Endpoints:
kubectl get endpoints

echo Ingress details:
kubectl describe ingress web-app-ingress

echo.
echo 🧹 Cleanup
echo ----------
kubectl delete -f ingress-example.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

echo.
echo ✅ NETWORKING DEMO COMPLETED!
echo You learned about Ingress and advanced networking!
echo.
pause