@echo off
echo 💾 VOLUMES AND PERSISTENCE DEMO
echo ===============================
echo.

echo 📝 Step 1: EmptyDir Volume Demo
echo -------------------------------
kubectl apply -f emptydir-example.yaml

echo Waiting for pod to be ready...
kubectl wait --for=condition=Ready pod/volume-demo --timeout=60s

echo Testing shared storage between containers:
timeout /t 5 /nobreak >nul
kubectl exec volume-demo -c writer -- sh -c "echo 'Hello from writer container' > /shared/message.txt"
kubectl exec volume-demo -c reader -- cat /shared/message.txt

echo.
echo Checking logs from both containers:
kubectl logs volume-demo -c writer --tail=3
kubectl logs volume-demo -c reader --tail=3

echo.
echo 📝 Step 2: Persistent Volume Demo
echo ---------------------------------
kubectl apply -f persistent-volume-example.yaml

echo Checking PV and PVC status:
kubectl get pv,pvc

echo Waiting for persistent pod to be ready...
kubectl wait --for=condition=Ready pod/persistent-pod --timeout=60s

echo Testing persistent storage:
start /B kubectl port-forward pod/persistent-pod 8080:80
timeout /t 3 /nobreak >nul
curl -s http://localhost:8080
taskkill /F /IM kubectl.exe >nul 2>&1

echo.
echo 📝 Step 3: Testing Persistence
echo ------------------------------
echo Deleting pod (data should persist)...
kubectl delete pod persistent-pod

echo Recreating pod with same PVC...
kubectl apply -f persistent-volume-example.yaml

echo Waiting for pod to be ready...
kubectl wait --for=condition=Ready pod/persistent-pod --timeout=60s

echo Testing if data persisted:
start /B kubectl port-forward pod/persistent-pod 8081:80
timeout /t 3 /nobreak >nul
curl -s http://localhost:8081 | findstr /C:"Persistent Storage"
taskkill /F /IM kubectl.exe >nul 2>&1

echo.
echo 🔍 Step 4: Storage Information
echo ------------------------------
echo Storage classes available:
kubectl get storageclass

echo Persistent volumes:
kubectl describe pv local-pv

echo Persistent volume claims:
kubectl describe pvc local-pvc

echo.
echo 🧹 Cleanup
echo ----------
kubectl delete pod volume-demo persistent-pod
kubectl delete pvc local-pvc
kubectl delete pv local-pv

echo.
echo ✅ VOLUMES DEMO COMPLETED!
echo You learned how to persist data in Kubernetes!
echo.
pause