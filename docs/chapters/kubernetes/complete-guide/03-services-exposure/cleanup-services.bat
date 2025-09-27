@echo off
echo [CLEANUP] CLEANING UP SERVICES LESSON
echo ==============================
echo.

echo Deleting pods...
kubectl delete pods web1 web2 web3 --ignore-not-found=true

echo.
echo Deleting services...
kubectl delete service web-service web-nodeport web-loadbalancer webapp-service --ignore-not-found=true

echo.
echo Deleting deployments...
kubectl delete deployment webapp-deployment --ignore-not-found=true

echo.
echo Deleting configmaps...
kubectl delete configmap webapp-html --ignore-not-found=true

echo.
echo [SUCCESS] CLEANUP COMPLETED!
echo All resources from Services lesson have been removed.
echo.
pause