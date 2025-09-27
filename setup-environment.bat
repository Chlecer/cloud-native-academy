@echo off
echo 🚀 DEVSECFINOPS - ENVIRONMENT SETUP
echo ==================================
echo.

echo 🔍 Checking prerequisites...

REM Check Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker not found. Please install Docker Desktop.
) else (
    echo ✅ Docker: OK
)

REM Check kubectl
kubectl version --client >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ kubectl not found. Please enable Kubernetes in Docker Desktop.
) else (
    echo ✅ kubectl: OK
)



echo.
echo 📚 DEVSECFINOPS CHAPTERS AVAILABLE:
echo.
echo 🔧 Development     - docs\chapters\development\
echo 🔐 Security        - docs\chapters\security\
echo ☸️  Kubernetes      - docs\chapters\kubernetes\
echo 💰 Finance         - docs\chapters\finance\
echo 🛠️  Operations      - docs\chapters\operations\
echo.

echo 🎯 QUICK START:
echo   For Kubernetes: cd docs\chapters\kubernetes\complete-guide
echo   Then run: quick-setup.bat
echo.

echo ✅ ENVIRONMENT SETUP COMPLETED!
echo Choose a chapter and start learning!
echo.
pause