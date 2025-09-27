@echo off
echo 🔄 DAEMONSETS AND STATEFULSETS DEMO
echo ===================================
echo.

echo 📝 Step 1: DaemonSet Demo
echo --------------------------
kubectl apply -f daemonset-example.yaml

echo Waiting for DaemonSet to be ready...
kubectl rollout status daemonset/node-monitor --timeout=60s

echo DaemonSet status:
kubectl get daemonset node-monitor

echo DaemonSet pods (one per node):
kubectl get pods -l app=node-monitor -o wide

echo DaemonSet logs:
kubectl logs -l app=node-monitor --tail=5

echo.
echo 📝 Step 2: StatefulSet Demo
echo ---------------------------
kubectl apply -f statefulset-example.yaml

echo Waiting for StatefulSet to be ready...
kubectl rollout status statefulset/web-stateful --timeout=120s

echo StatefulSet status:
kubectl get statefulset web-stateful

echo StatefulSet pods (ordered names):
kubectl get pods -l app=web-stateful

echo.
echo 📝 Step 3: StatefulSet Features
echo -------------------------------
echo Headless service:
kubectl get service web-stateful-service

echo Persistent volumes:
kubectl get pvc

echo Testing stable network identity:
for /L %%i in (0,1,2) do (
    echo Testing web-stateful-%%i:
    kubectl exec web-stateful-%%i -- hostname
)

echo.
echo 📝 Step 4: StatefulSet Scaling
echo ------------------------------
echo Current replicas:
kubectl get statefulset web-stateful

echo Scaling up to 4 replicas:
kubectl scale statefulset web-stateful --replicas=4

echo Watching ordered scaling:
kubectl get pods -l app=web-stateful -w --timeout=60s

echo Scaling back to 3:
kubectl scale statefulset web-stateful --replicas=3

echo.
echo 📝 Step 5: Testing Applications
echo -------------------------------
echo Testing StatefulSet web application:
curl -s http://localhost:30300 | findstr /C:"StatefulSet Pod"

echo.
echo DaemonSet monitoring output:
kubectl logs -l app=node-monitor --tail=10

echo.
echo 📝 Step 6: Workload Comparison
echo ------------------------------
echo All workload types:
kubectl get deployments,statefulsets,daemonsets

echo Pod distribution:
kubectl get pods -o wide

echo.
echo 🧹 Cleanup
echo ----------
kubectl delete -f daemonset-example.yaml
kubectl delete -f statefulset-example.yaml

echo Cleaning up PVCs:
kubectl delete pvc -l app=web-stateful

echo.
echo ✅ WORKLOADS DEMO COMPLETED!
echo You learned DaemonSets and StatefulSets!
echo.
pause