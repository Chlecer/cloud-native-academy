@echo off
echo 🔐 RBAC AND SECURITY DEMO
echo =========================
echo.

echo 📝 Step 1: Creating Service Account and RBAC
echo ---------------------------------------------
kubectl apply -f rbac-example.yaml

echo Waiting for pod to be ready...
kubectl wait --for=condition=Ready pod/rbac-test-pod --timeout=60s

echo.
echo 📝 Step 2: Testing RBAC Permissions
echo -----------------------------------
echo Testing allowed operations (should work):
kubectl exec rbac-test-pod -- kubectl get pods
kubectl exec rbac-test-pod -- kubectl get nodes

echo.
echo Testing forbidden operations (should fail):
kubectl exec rbac-test-pod -- kubectl get secrets 2>nul || echo "✅ Access denied as expected"
kubectl exec rbac-test-pod -- kubectl delete pods --all --dry-run=client 2>nul || echo "✅ Access denied as expected"

echo.
echo 📝 Step 3: Security Context Demo
echo --------------------------------
kubectl apply -f security-context-example.yaml

echo Waiting for security pod...
kubectl wait --for=condition=Ready pod/security-demo --timeout=60s

echo Testing security context:
kubectl exec security-demo -- id
kubectl exec security-demo -- ls -la /tmp

echo.
echo 📝 Step 4: RBAC Information
echo ---------------------------
echo Service accounts:
kubectl get serviceaccounts

echo Roles:
kubectl get roles

echo RoleBindings:
kubectl get rolebindings

echo ClusterRoles (system):
kubectl get clusterroles | findstr /C:"system:"

echo.
echo 🧹 Cleanup
echo ----------
kubectl delete -f rbac-example.yaml
kubectl delete -f security-context-example.yaml

echo.
echo ✅ SECURITY DEMO COMPLETED!
echo You learned RBAC, Service Accounts, and Security Contexts!
echo.
pause