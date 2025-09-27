@echo off
echo 🎓 COMPLETE KUBERNETES TUTORIAL - MASTER SCRIPT
echo ===============================================
echo.
echo Welcome to the comprehensive Kubernetes tutorial!
echo This script covers 15 essential lessons.
echo.
echo 📚 Tutorial Structure:
echo   1-9: Core Kubernetes (Pods to Complete App)
echo  10-15: Advanced Topics (Security to Network Policies)
echo.

:menu
echo.
echo 🎯 Choose your lesson:
echo.
echo [1] Lesson 1: Setup and Verification
echo [2] Lesson 2: First Pod
echo [3] Lesson 3: Services
echo [4] Lesson 4: Deployments
echo [5] Lesson 5: ConfigMaps and Secrets
echo [6] Lesson 6: Volumes
echo [7] Lesson 7: Advanced Networking
echo [8] Lesson 8: Monitoring
echo [9] Lesson 9: Final Project
echo [10] Lesson 10: RBAC & Security
echo [12] Lesson 12: Jobs & CronJobs
echo [13] Lesson 13: DaemonSets & StatefulSets
echo [14] Lesson 14: Autoscaling & HPA
echo [15] Lesson 15: Network Policies
echo [16] Lesson 16: Helm Charts
echo [A] Run ALL lessons automatically
echo [Q] Quit
echo.
set /p choice="Enter your choice: "

if /i "%choice%"=="1" (
    echo.
    echo 🔧 Running Lesson 1: Setup and Verification
    cd 01-setup-verification
    call test-commands.bat
    cd ..
    goto menu
)

if /i "%choice%"=="2" (
    echo.
    echo 🐳 Running Lesson 2: First Pod
    cd 02-first-pod
    call practical-exercises.bat
    cd ..
    goto menu
)

if /i "%choice%"=="3" (
    echo.
    echo 🌐 Running Lesson 3: Services
    cd 03-services-exposure
    call test-services.bat
    cd ..
    goto menu
)

if /i "%choice%"=="4" (
    echo.
    echo 📈 Running Lesson 4: Deployments
    cd 04-deployments-scalability
    call complete-demo.bat
    cd ..
    goto menu
)

if /i "%choice%"=="5" (
    echo.
    echo 🔐 Running Lesson 5: ConfigMaps and Secrets
    cd 05-configmaps-secrets
    call config-demo.bat
    cd ..
    goto menu
)

if /i "%choice%"=="6" (
    echo.
    echo 💾 Running Lesson 6: Volumes
    cd 06-volumes-persistence
    call volumes-demo.bat
    cd ..
    goto menu
)

if /i "%choice%"=="7" (
    echo.
    echo 🌍 Running Lesson 7: Advanced Networking
    cd 07-advanced-networking
    call networking-demo.bat
    cd ..
    goto menu
)

if /i "%choice%"=="8" (
    echo.
    echo 📊 Running Lesson 8: Monitoring
    cd 08-monitoring
    call monitoring-demo.bat
    cd ..
    goto menu
)

if /i "%choice%"=="9" (
    echo.
    echo 🎯 Running Lesson 9: Final Project
    cd 09-final-project
    call deploy-complete-app.bat
    echo.
    echo Would you like to run comprehensive tests? (Y/N)
    set /p test_choice=""
    if /i "%test_choice%"=="Y" call test-complete-app.bat
    cd ..
    goto menu
)

if /i "%choice%"=="10" (
    echo.
    echo 🔐 Running Lesson 10: RBAC & Security
    cd 10-rbac-security
    call security-demo.bat
    cd ..
    goto menu
)

if /i "%choice%"=="12" (
    echo.
    echo ⏰ Running Lesson 12: Jobs & CronJobs
    cd 12-jobs-cronjobs
    call jobs-demo.bat
    cd ..
    goto menu
)

if /i "%choice%"=="13" (
    echo.
    echo 🔄 Running Lesson 13: DaemonSets & StatefulSets
    cd 13-daemonsets-statefulsets
    call workloads-demo.bat
    cd ..
    goto menu
)

if /i "%choice%"=="14" (
    echo.
    echo 📊 Running Lesson 14: Autoscaling & HPA
    cd 14-autoscaling-hpa
    call autoscaling-demo.bat
    cd ..
    goto menu
)

if /i "%choice%"=="15" (
    echo.
    echo 🛡️ Running Lesson 15: Network Policies
    cd 15-network-policies
    call network-policies-demo.bat
    cd ..
    goto menu
)

if /i "%choice%"=="16" (
    echo.
    echo 📦 Running Lesson 16: Helm Charts
    cd 16-helm-charts
    call helm-demo.bat
    cd ..
    goto menu
)

if /i "%choice%"=="A" (
    echo.
    echo 🚀 Running ALL lessons automatically...
    echo This will take several minutes. Press Ctrl+C to cancel.
    timeout /t 5 /nobreak
    
    echo.
    echo === CORE LESSONS ===
    cd 01-setup-verification && call test-commands.bat && cd ..
    cd 02-first-pod && call practical-exercises.bat && cd ..
    cd 03-services-exposure && call test-services.bat && cd ..
    cd 04-deployments-scalability && call complete-demo.bat && cd ..
    cd 05-configmaps-secrets && call config-demo.bat && cd ..
    cd 06-volumes-persistence && call volumes-demo.bat && cd ..
    cd 07-advanced-networking && call networking-demo.bat && cd ..
    cd 08-monitoring && call monitoring-demo.bat && cd ..
    cd 09-final-project && call deploy-complete-app.bat && cd ..
    
    echo.
    echo === ADVANCED LESSONS ===
    cd 10-rbac-security && call security-demo.bat && cd ..
    cd 12-jobs-cronjobs && call jobs-demo.bat && cd ..
    cd 13-daemonsets-statefulsets && call workloads-demo.bat && cd ..
    cd 14-autoscaling-hpa && call autoscaling-demo.bat && cd ..
    cd 15-network-policies && call network-policies-demo.bat && cd ..
    
    echo.
    echo 🎉 ALL LESSONS COMPLETED!
    echo You are now a Kubernetes expert!
    goto menu
)

if /i "%choice%"=="Q" (
    echo.
    echo 👋 Thank you for completing the Kubernetes tutorial!
    echo You are now ready for production deployments!
    echo.
    echo 🏆 Congratulations on becoming a Kubernetes expert!
    exit /b 0
)

echo Invalid choice. Please try again.
goto menu