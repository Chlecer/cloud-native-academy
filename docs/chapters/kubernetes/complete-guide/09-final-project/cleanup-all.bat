@echo off
echo 🧹 CLEANING UP COMPLETE APPLICATION
echo ===================================
echo.

echo Removing complete application...
kubectl delete -f complete-application.yaml

echo.
echo Waiting for cleanup to complete...
timeout /t 10 /nobreak >nul

echo.
echo Checking remaining resources:
kubectl get all

echo.
echo Checking persistent volumes:
kubectl get pvc

echo.
echo ✅ CLEANUP COMPLETED!
echo Your cluster is now clean and ready for new deployments.
echo.
pause