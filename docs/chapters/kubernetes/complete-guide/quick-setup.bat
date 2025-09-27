@echo off
echo 🚀 QUICK SETUP - KUBERNETES TUTORIAL
echo =====================================
echo.

echo 🔍 Checking prerequisites...

REM Check Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker not found. Please install Docker Desktop first.
    pause
    exit /b 1
)

REM Check kubectl
kubectl version --client >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ kubectl not found. Please enable Kubernetes in Docker Desktop.
    pause
    exit /b 1
)

REM Check cluster
kubectl cluster-info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Kubernetes cluster is not running. Check Docker Desktop.
    pause
    exit /b 1
)

echo ✅ Docker Desktop: OK
echo ✅ kubectl: OK
echo ✅ Kubernetes Cluster: OK
echo.

echo 🎯 Running quick test...
kubectl run test-setup --image=nginx:alpine --restart=Never --rm -it --timeout=60s -- echo "Kubernetes working!" >nul 2>&1

if %errorlevel% equ 0 (
    echo ✅ Basic test: OK
) else (
    echo ⚠️  Basic test failed, but this might be normal
)

echo.
echo 📚 TUTORIAL READY TO USE!
echo.
echo 🎓 How to use:
echo 1. Start with Lesson 1: cd 01-setup-verification
echo 2. Read the README.md of each lesson
echo 3. Execute the practical commands
echo 4. Test everything in your local environment
echo.
echo 📖 Tutorial structure:
echo ├── 01-setup-verification/     # Verify environment
echo ├── 02-first-pod/              # Pod concepts
echo ├── 03-services-exposure/      # Expose applications
echo ├── 04-deployments-scalability/ # Scale and update
echo ├── 05-configmaps-secrets/     # Configurations
echo ├── 06-volumes-persistence/    # Storage
echo ├── 07-advanced-networking/    # Advanced networking
echo ├── 08-monitoring/             # Observability
echo └── 09-final-project/          # Complete project
echo.
echo 🚀 Start now: cd 01-setup-verification ^&^& type README.md
echo.
echo 💡 Tip: Use 'kubectl get all' to see all resources
echo 💡 Tip: Use 'kubectl delete all --all' to clean everything
echo.
pause