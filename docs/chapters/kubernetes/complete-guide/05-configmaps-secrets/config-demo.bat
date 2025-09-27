@echo off
echo 🔐 CONFIGMAPS AND SECRETS DEMO
echo ==============================
echo.

echo 📝 Step 1: Creating ConfigMap from literals
echo -------------------------------------------
kubectl create configmap app-config --from-literal=DATABASE_URL=postgresql://localhost:5432/mydb --from-literal=DEBUG=true

echo ConfigMap created:
kubectl get configmap app-config
kubectl describe configmap app-config

echo.
echo 📝 Step 2: Creating ConfigMap from file
echo ---------------------------------------
kubectl create configmap nginx-config --from-file=nginx.conf

echo File-based ConfigMap:
kubectl describe configmap nginx-config

echo.
echo 🔒 Step 3: Creating Secrets
echo ---------------------------
kubectl create secret generic app-secrets --from-literal=db-password=supersecret --from-literal=api-key=abc123xyz

echo Secret created (data is base64 encoded):
kubectl get secret app-secrets
kubectl describe secret app-secrets

echo.
echo 🚀 Step 4: Complete Example
echo ---------------------------
kubectl apply -f complete-config-example.yaml

echo Waiting for pod to be ready...
kubectl wait --for=condition=Ready pod/config-demo --timeout=60s

echo.
echo 🔍 Step 5: Testing Configuration
echo --------------------------------
echo Environment variables from ConfigMap and Secret:
kubectl exec config-demo -- env | findstr /C:"DATABASE_URL DEBUG DB_PASSWORD API_KEY"

echo.
echo Files mounted from ConfigMap:
kubectl exec config-demo -- ls -la /etc/config/

echo.
echo Files mounted from Secret:
kubectl exec config-demo -- ls -la /etc/secrets/

echo.
echo Content of config file:
kubectl exec config-demo -- cat /etc/config/app.properties

echo.
echo 🧹 Cleanup
echo ----------
kubectl delete pod config-demo
kubectl delete configmap app-config nginx-config
kubectl delete secret app-secrets

echo.
echo ✅ CONFIGMAPS AND SECRETS DEMO COMPLETED!
echo You learned how to manage configuration and sensitive data!
echo.
pause