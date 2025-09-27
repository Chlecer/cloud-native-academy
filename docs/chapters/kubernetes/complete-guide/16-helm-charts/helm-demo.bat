@echo off
echo 📦 HELM CHARTS DEMO
echo ==================
echo.

echo 📝 Step 1: Check Helm Installation
echo ----------------------------------
helm version || (
    echo ❌ Helm not installed. Please install from https://helm.sh/docs/intro/install/
    pause
    exit /b 1
)

echo.
echo 📝 Step 2: Add Public Repository
echo --------------------------------
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

echo Available nginx charts:
helm search repo nginx

echo.
echo 📝 Step 3: Install Public Chart
echo -------------------------------
helm install demo-nginx bitnami/nginx --set service.type=NodePort

echo Waiting for deployment...
kubectl wait --for=condition=Available deployment/demo-nginx --timeout=60s

echo Helm releases:
helm list

echo.
echo 📝 Step 4: Custom Chart Demo
echo ----------------------------
echo Validating custom chart:
helm lint webapp-chart

echo Dry run (template rendering):
helm install webapp-test webapp-chart --dry-run --debug

echo.
echo 📝 Step 5: Install Custom Chart
echo -------------------------------
helm install webapp webapp-chart

echo Waiting for custom app...
kubectl wait --for=condition=Available deployment/webapp-webapp-chart --timeout=60s

echo.
echo 📝 Step 6: Chart Management
echo ---------------------------
echo All releases:
helm list

echo Release status:
helm status webapp

echo Release history:
helm history webapp

echo.
echo 📝 Step 7: Upgrade Demo
echo ----------------------
echo Upgrading with new values:
helm upgrade webapp webapp-chart --set replicaCount=3

echo Checking upgrade:
kubectl get pods -l app.kubernetes.io/instance=webapp

echo.
echo 📝 Step 8: Rollback Demo
echo -----------------------
echo Rolling back to previous version:
helm rollback webapp 1

echo Checking rollback:
kubectl get pods -l app.kubernetes.io/instance=webapp

echo.
echo 📝 Step 9: Chart Information
echo ----------------------------
echo Chart values:
helm get values webapp

echo Chart manifest:
helm get manifest webapp

echo.
echo 🧹 Cleanup
echo ----------
helm uninstall demo-nginx
helm uninstall webapp

echo.
echo ✅ HELM DEMO COMPLETED!
echo You learned Helm package management!
echo.
pause