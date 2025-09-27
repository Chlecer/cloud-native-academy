@echo off
echo [*] TESTING KUBERNETES SERVICES
echo ===============================
echo.

echo [CLEANUP] Cleanup any existing resources first
echo -------------------------------------
kubectl delete pods web1 web2 web3 --ignore-not-found=true
kubectl delete service web-service web-nodeport web-loadbalancer webapp-service --ignore-not-found=true
kubectl delete deployment webapp-deployment --ignore-not-found=true

echo.
echo [SETUP] Preparation: Creating test pods
echo -----------------------------------
kubectl run web1 --image=nginx:alpine --labels="app=web"
kubectl run web2 --image=nginx:alpine --labels="app=web"
kubectl run web3 --image=nginx:alpine --labels="app=web"

echo Waiting for pods to be ready...
kubectl wait --for=condition=Ready pod -l app=web --timeout=60s

echo Created pods:
kubectl get pods -l app=web -o wide

echo.
echo [TEST 1] ClusterIP Service
echo ----------------------------
kubectl apply -f service-clusterip.yaml

echo Service created:
kubectl get service web-service

echo Testing internal access:
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://web-service

echo.
echo [TEST 2] NodePort Service
echo ---------------------------
kubectl apply -f service-nodeport.yaml

echo NodePort service created:
kubectl get service web-nodeport

echo Testing external access:
echo Access http://localhost:30081 in your browser!

REM Automated test
echo Automated test:
curl -s http://localhost:30081

echo.
echo [TEST 3] LoadBalancer Service
echo -------------------------------
kubectl apply -f service-loadbalancer.yaml

echo LoadBalancer service created:
kubectl get service web-loadbalancer

echo.
echo [TEST 4] Complete Application
echo ------------------------------
kubectl apply -f complete-app.yaml

echo Waiting for deployment to be ready...
kubectl wait --for=condition=Available deployment/webapp-deployment --timeout=60s

echo Deployment pods:
kubectl get pods -l app=webapp

echo Application service:
kubectl get service webapp-service

echo.
echo [LOAD BALANCING] Testing Load Balancing
echo -------------------------
echo Making 5 requests to see different pods responding:
for /L %%i in (1,1,5) do (
    echo Request %%i:
    curl -s http://localhost:30090 | findstr "Pod Name:"
    echo ---
    timeout /t 1 /nobreak >nul
)

echo.
echo [INFO] Service Information
echo ---------------------
echo All services:
kubectl get services

echo.
echo Details of main service:
kubectl describe service webapp-service

echo.
echo [CLEANUP] Cleanup
echo --------------------
echo Run cleanup-services.bat to remove all resources from this lesson

echo.
echo [SUCCESS] SERVICES TESTS COMPLETED!
echo Access http://localhost:30090 to see the application working!
echo.
pause