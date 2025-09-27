@echo off
echo 🎯 DEPLOYING COMPLETE KUBERNETES APPLICATION
echo ============================================
echo.

echo 🚀 Step 1: Deploying Database Layer
echo -----------------------------------
echo Deploying PostgreSQL with persistent storage...
kubectl apply -f complete-application.yaml

echo Waiting for PostgreSQL to be ready...
kubectl wait --for=condition=Available deployment/postgres --timeout=120s

echo Database status:
kubectl get pods -l app=postgres

echo.
echo ⚡ Step 2: Deploying Cache Layer
echo -------------------------------
echo Redis cache status:
kubectl wait --for=condition=Available deployment/redis --timeout=60s
kubectl get pods -l app=redis

echo.
echo 🔧 Step 3: Deploying Backend API
echo --------------------------------
echo Waiting for backend API to be ready...
kubectl wait --for=condition=Available deployment/backend-api --timeout=60s

echo Backend API status:
kubectl get pods -l app=backend-api

echo Testing backend API health:
kubectl get service backend-service

echo.
echo 🌐 Step 4: Deploying Frontend
echo -----------------------------
echo Waiting for frontend to be ready...
kubectl wait --for=condition=Available deployment/frontend --timeout=60s

echo Frontend status:
kubectl get pods -l app=frontend

echo.
echo 📊 Step 5: Application Overview
echo -------------------------------
echo All deployments:
kubectl get deployments

echo All services:
kubectl get services

echo All pods:
kubectl get pods

echo.
echo 🔍 Step 6: Storage and Configuration
echo ------------------------------------
echo Persistent volumes:
kubectl get pvc

echo ConfigMaps:
kubectl get configmaps

echo Secrets:
kubectl get secrets

echo.
echo 🎉 Step 7: Application Ready!
echo -----------------------------
echo.
echo ✅ COMPLETE APPLICATION DEPLOYED SUCCESSFULLY!
echo.
echo 🌐 Access your application at: http://localhost:30200
echo.
echo 📊 Application Components:
echo   - PostgreSQL Database (with persistence)
echo   - Redis Cache
echo   - Backend API (2 replicas)
echo   - Frontend Web App (2 replicas)
echo.
echo 💡 Next steps:
echo   1. Open http://localhost:30200 in your browser
echo   2. Test the Backend API button
echo   3. Run test-complete-app.bat for comprehensive testing
echo   4. Run monitor-app.bat to see monitoring in action
echo.
pause