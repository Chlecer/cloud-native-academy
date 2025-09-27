@echo off
echo 🛡️ NETWORK POLICIES DEMO
echo ========================
echo.

echo ⚠️  Note: Network Policies require a CNI that supports them
echo Docker Desktop uses a basic CNI, so policies may not be enforced
echo This demo shows the concepts and YAML structure
echo.

echo 📝 Step 1: Deploying Multi-tier Application
echo --------------------------------------------
kubectl apply -f multi-tier-policies.yaml

echo Waiting for deployments to be ready...
kubectl wait --for=condition=Available deployment/frontend --timeout=60s
kubectl wait --for=condition=Available deployment/backend --timeout=60s
kubectl wait --for=condition=Available deployment/database --timeout=60s

echo.
echo 📝 Step 2: Testing Without Network Policies
echo --------------------------------------------
echo All pods (before network policies):
kubectl get pods -l tier --show-labels

echo Testing connectivity (should work):
kubectl exec -it deployment/frontend -- wget -qO- --timeout=5 backend-service || echo "Connection failed"
kubectl exec -it deployment/backend -- wget -qO- --timeout=5 database-service:5432 || echo "Connection failed"

echo.
echo 📝 Step 3: Network Policies Status
echo ----------------------------------
echo Network policies created:
kubectl get networkpolicies

echo Network policy details:
kubectl describe networkpolicy allow-frontend-to-backend

echo.
echo 📝 Step 4: Policy Analysis
echo --------------------------
echo Frontend policy (allows external traffic):
kubectl get networkpolicy allow-external-to-frontend -o yaml

echo Backend policy (allows only from frontend):
kubectl get networkpolicy allow-frontend-to-backend -o yaml

echo Database policy (allows only from backend):
kubectl get networkpolicy allow-backend-to-database -o yaml

echo.
echo 📝 Step 5: Testing Network Policies
echo -----------------------------------
echo Note: In Docker Desktop, these tests show the concept
echo In production with proper CNI, policies would be enforced

echo Testing allowed connections:
kubectl exec -it deployment/frontend -- wget -qO- --timeout=5 backend-service || echo "Connection blocked (expected in production)"

echo Testing blocked connections (should fail in production):
kubectl exec -it deployment/frontend -- wget -qO- --timeout=5 database-service:5432 || echo "Connection blocked (good!)"

echo.
echo 📝 Step 6: Network Policy Best Practices
echo ----------------------------------------
echo.
echo ✅ Best Practices:
echo   1. Start with default deny
echo   2. Allow only necessary traffic
echo   3. Use labels for selection
echo   4. Test policies thoroughly
echo   5. Monitor network traffic
echo.

echo 📝 Step 7: Production CNI Examples
echo -----------------------------------
echo For production, use CNIs that support Network Policies:
echo   - Calico
echo   - Cilium
echo   - Weave Net
echo   - Azure CNI
echo   - AWS VPC CNI
echo.

echo.
echo 🧹 Cleanup
echo ----------
kubectl delete -f multi-tier-policies.yaml

echo.
echo ✅ NETWORK POLICIES DEMO COMPLETED!
echo You learned network security and micro-segmentation!
echo.
pause