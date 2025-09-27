@echo off
echo ⏰ JOBS AND CRONJOBS DEMO
echo =========================
echo.

echo 📝 Step 1: Simple Job Demo
echo ---------------------------
kubectl apply -f simple-job.yaml

echo Waiting for simple job to complete...
kubectl wait --for=condition=complete job/simple-job --timeout=60s

echo Job status:
kubectl get jobs

echo Job logs:
kubectl logs job/simple-job

echo.
echo 📝 Step 2: Parallel Job Demo
echo ----------------------------
echo Parallel job status:
kubectl get job parallel-job

echo Watching parallel job progress:
kubectl get pods -l job-name=parallel-job

echo Waiting for parallel job to complete...
kubectl wait --for=condition=complete job/parallel-job --timeout=120s

echo.
echo 📝 Step 3: CronJob Demo
echo -----------------------
echo CronJob status:
kubectl get cronjobs

echo Waiting for first scheduled execution...
timeout /t 130 /nobreak >nul

echo CronJob history:
kubectl get jobs -l job-name=scheduled-job

echo Recent job logs:
for /f "tokens=1" %%i in ('kubectl get jobs -l job-name^=scheduled-job -o name --sort-by^=.metadata.creationTimestamp ^| findstr /E job') do (
    kubectl logs %%i
)

echo.
echo 📝 Step 4: Job Management
echo -------------------------
echo All jobs:
kubectl get jobs

echo Job details:
kubectl describe job simple-job

echo CronJob details:
kubectl describe cronjob scheduled-job

echo.
echo 📝 Step 5: Job Cleanup Patterns
echo -------------------------------
echo Manual job cleanup:
kubectl delete job simple-job parallel-job

echo CronJob automatic cleanup (configured):
kubectl get jobs -l job-name=scheduled-job

echo.
echo 🧹 Final Cleanup
echo ----------------
kubectl delete cronjob scheduled-job
kubectl delete jobs --all

echo.
echo ✅ JOBS AND CRONJOBS DEMO COMPLETED!
echo You learned batch processing and scheduled tasks!
echo.
pause