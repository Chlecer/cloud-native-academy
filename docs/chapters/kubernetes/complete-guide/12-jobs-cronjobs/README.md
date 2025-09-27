# ⏰ Lesson 12: Jobs & CronJobs

## 🎯 Objective
Learn how to run batch workloads, scheduled tasks, and one-time jobs in Kubernetes.

## 🤔 Jobs vs Deployments

**Deployments** - Long-running services (web servers, APIs)
**Jobs** - Run-to-completion tasks (data processing, backups)
**CronJobs** - Scheduled recurring tasks (daily reports, cleanup)

## 🧪 Experiment 1: Simple Job

```cmd
kubectl apply -f simple-job.yaml
```

## 🧪 Experiment 2: Parallel Jobs

```cmd
kubectl apply -f parallel-job.yaml
```

## 🧪 Experiment 3: CronJob

```cmd
kubectl apply -f cronjob-example.yaml
```

## 🧪 Experiment 4: Job Patterns

```cmd
kubectl apply -f job-patterns.yaml
```

## 🚀 Complete Demo

```cmd
jobs-demo.bat
```

## 💡 Job Patterns

- **One-shot** - Single task completion
- **Parallel** - Multiple pods working together
- **Work Queue** - Processing items from queue
- **Scheduled** - Time-based execution

---

## 🎯 Next Lesson

Go to [Lesson 13: DaemonSets & StatefulSets](../13-daemonsets-statefulsets/)!