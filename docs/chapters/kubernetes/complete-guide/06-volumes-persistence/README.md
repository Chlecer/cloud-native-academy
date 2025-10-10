# 💾 Lesson 6: Volumes - Persistence

## 🎯 Objective
Master data persistence in Kubernetes with real-world scenarios, backup strategies, and production-grade storage solutions.

## 🤔 The Real Problem

**Netflix's Challenge:** Lost 2TB of user viewing data when pods restarted during peak hours
**Spotify's Issue:** Playlist recommendations reset daily due to ephemeral storage
**Your Challenge:** How do you keep databases, logs, and user uploads alive?

## 🏢 Real-World Storage Scenarios

### Database Persistence
- **PostgreSQL clusters** need consistent data across restarts
- **MongoDB replica sets** require persistent storage for each member
- **Redis caches** need persistence for session data

### Application Data
- **User uploads** (images, documents, videos)
- **Log aggregation** (ELK stack, Fluentd)
- **Configuration files** that change at runtime
- **SSL certificates** and secrets

### Backup and Recovery
- **Database snapshots** before deployments
- **Cross-region replication** for disaster recovery
- **Point-in-time recovery** for critical data

## 📊 Volume Types (Production Reality)

### EmptyDir - Temporary Shared Storage
**Use Case:** Sidecar containers sharing logs or cache
**Example:** Nginx + Log shipper sharing access logs
**Limitation:** Dies with pod - never use for important data

### HostPath - Node Storage (Dangerous)
**Use Case:** Development only, accessing Docker socket
**Production Risk:** Ties pods to specific nodes, security vulnerability
**Alternative:** Use CSI drivers instead

### PersistentVolume - Production Storage
**Use Case:** Databases, file storage, anything that must survive
**Providers:** AWS EBS, GCP Persistent Disk, Azure Disk
**Features:** Snapshots, encryption, cross-AZ replication

## 🧪 Real-World Example 1: Web App with File Uploads

**Scenario:** E-commerce site where users upload product images

```yaml
# web-app-storage.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: user-uploads-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: fast-ssd
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: app
        image: nginx:alpine
        volumeMounts:
        - name: uploads
          mountPath: /var/www/uploads
      volumes:
      - name: uploads
        persistentVolumeClaim:
          claimName: user-uploads-pvc
```

**Test the upload persistence:**
```bash
# Upload a file
kubectl exec -it web-app-xxx -- touch /var/www/uploads/user-photo.jpg

# Delete the pod
kubectl delete pod web-app-xxx

# Check if file survived in new pod
kubectl exec -it web-app-yyy -- ls /var/www/uploads/
```

## 🧪 Real-World Example 2: PostgreSQL with Backup Strategy

**Scenario:** Production database that needs daily backups and point-in-time recovery

```yaml
# postgres-production.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Gi
  storageClassName: gp3-encrypted  # AWS EBS with encryption
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-backup-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Ti
  storageClassName: standard  # Cheaper storage for backups
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: POSTGRES_DB
          value: "production"
        - name: POSTGRES_USER
          value: "admin"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
        - name: backups
          mountPath: /backups
      - name: backup-sidecar
        image: postgres:15
        command:
        - /bin/bash
        - -c
        - |
          while true; do
            echo "Starting backup at $(date)"
            pg_dump -h localhost -U admin production > /backups/backup-$(date +%Y%m%d-%H%M%S).sql
            # Keep only last 7 days of backups
            find /backups -name "backup-*.sql" -mtime +7 -delete
            sleep 86400  # 24 hours
          done
        env:
        - name: PGPASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        volumeMounts:
        - name: backups
          mountPath: /backups
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: postgres-data-pvc
      - name: backups
        persistentVolumeClaim:
          claimName: postgres-backup-pvc
```

## 🧪 Real-World Example 3: Log Aggregation with ELK Stack

**Scenario:** Collecting application logs from multiple services

```yaml
# log-aggregation.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: elasticsearch-data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 200Gi
  storageClassName: fast-ssd
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-logging
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-service
  template:
    metadata:
      labels:
        app: web-service
    spec:
      containers:
      - name: app
        image: nginx:alpine
        volumeMounts:
        - name: logs
          mountPath: /var/log/nginx
      - name: filebeat
        image: elastic/filebeat:8.8.0
        volumeMounts:
        - name: logs
          mountPath: /var/log/nginx
          readOnly: true
        - name: filebeat-config
          mountPath: /usr/share/filebeat/filebeat.yml
          subPath: filebeat.yml
      volumes:
      - name: logs
        emptyDir: {}  # Shared between app and log shipper
      - name: filebeat-config
        configMap:
          name: filebeat-config
```

## 🔄 Enterprise Backup and Recovery Strategies

### The 3-2-1 Backup Rule in Kubernetes

**What Fortune 500 Companies Do:**
- **3 copies** of critical data (1 primary + 2 backups)
- **2 different storage types** (local PVC + cloud storage)
- **1 offsite backup** (different region/provider)

**Real Example - Airbnb's Backup Strategy:**
```yaml
# airbnb-style-backup-strategy.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backup-strategy-config
data:
  strategy.json: |
    {
      "primary": "kubernetes-pvc",
      "local_backup": "daily-snapshots",
      "remote_backup": "s3-cross-region",
      "retention": {
        "daily": "30 days",
        "weekly": "12 weeks", 
        "monthly": "12 months",
        "yearly": "7 years"
      }
    }
```

### Cross-Region Disaster Recovery

**Scenario:** Your primary AWS region (us-east-1) goes down. How do you recover in us-west-2?

```yaml
# disaster-recovery-setup.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cross-region-backup
spec:
  schedule: "0 4 * * *"  # Daily at 4 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cross-region-backup
            image: amazon/aws-cli:latest
            command:
            - /bin/bash
            - -c
            - |
              # 1. Create snapshot in primary region
              SNAPSHOT_ID=$(aws ec2 create-snapshot \
                --volume-id vol-1234567890abcdef0 \
                --description "Daily backup $(date +%Y%m%d)" \
                --region us-east-1 \
                --query 'SnapshotId' --output text)
              
              # 2. Wait for snapshot completion
              aws ec2 wait snapshot-completed \
                --snapshot-ids $SNAPSHOT_ID \
                --region us-east-1
              
              # 3. Copy snapshot to backup region
              aws ec2 copy-snapshot \
                --source-region us-east-1 \
                --source-snapshot-id $SNAPSHOT_ID \
                --destination-region us-west-2 \
                --description "Cross-region backup $(date +%Y%m%d)"
              
              # 4. Upload database dump to S3 with cross-region replication
              kubectl exec postgres-0 -- pg_dump production | \
                aws s3 cp - s3://company-backups/postgres/$(date +%Y%m%d)/dump.sql
              
              echo "Cross-region backup completed: $SNAPSHOT_ID"
            env:
            - name: AWS_ACCESS_KEY_ID
              valueFrom:
                secretKeyRef:
                  name: aws-credentials
                  key: access-key-id
            - name: AWS_SECRET_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: aws-credentials
                  key: secret-access-key
          restartPolicy: OnFailure
```

### Multi-Cloud Backup Strategy

**Netflix's Approach:** Never trust a single cloud provider

```yaml
# multi-cloud-backup.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: multi-cloud-backup
spec:
  schedule: "0 6 * * *"  # Daily at 6 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: multi-cloud-backup
            image: rclone/rclone:latest
            command:
            - /bin/bash
            - -c
            - |
              # Backup to multiple cloud providers
              
              # 1. Create local backup
              kubectl exec postgres-0 -- pg_dump production > /tmp/backup.sql
              
              # 2. Upload to AWS S3
              rclone copy /tmp/backup.sql aws-s3:company-backups/postgres/$(date +%Y%m%d)/
              
              # 3. Upload to Google Cloud Storage
              rclone copy /tmp/backup.sql gcs:company-backups-gcp/postgres/$(date +%Y%m%d)/
              
              # 4. Upload to Azure Blob Storage
              rclone copy /tmp/backup.sql azure:company-backups-azure/postgres/$(date +%Y%m%d)/
              
              # 5. Verify all uploads
              for provider in aws-s3 gcs azure; do
                if rclone check /tmp/backup.sql $provider:company-backups*/postgres/$(date +%Y%m%d)/backup.sql; then
                  echo "✅ Backup verified on $provider"
                else
                  echo "❌ Backup failed on $provider" >&2
                  exit 1
                fi
              done
              
              rm /tmp/backup.sql
            volumeMounts:
            - name: rclone-config
              mountPath: /config/rclone
          volumes:
          - name: rclone-config
            secret:
              secretName: rclone-config
          restartPolicy: OnFailure
```

### Automated Backup CronJob

```yaml
# backup-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:15
            command:
            - /bin/bash
            - -c
            - |
              # Create backup
              pg_dump -h postgres -U admin production > /backup/backup-$(date +%Y%m%d).sql
              
              # Upload to S3 (or your cloud storage)
              aws s3 cp /backup/backup-$(date +%Y%m%d).sql s3://company-backups/postgres/
              
              # Clean local backup
              rm /backup/backup-$(date +%Y%m%d).sql
            env:
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: password
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: backup-storage
            emptyDir: {}
          restartPolicy: OnFailure
```

### Volume Snapshots - The Game Changer

**What are Volume Snapshots?**
Point-in-time copies of your persistent volumes that live at the cloud provider level (AWS EBS, GCP Persistent Disk, Azure Disk). Think of them as "save points" in a video game.

**Why Volume Snapshots vs Regular Backups?**
- **Speed:** Snapshots are instant (copy-on-write), backups take hours
- **Storage efficient:** Only stores changed blocks, not full copies
- **Crash consistent:** Captures exact state at snapshot time
- **Cross-AZ restore:** Can restore to different availability zones

**Real-World Use Cases:**
- **Pre-deployment snapshots:** Before risky database migrations
- **Development cloning:** Create dev environments from production data
- **Disaster recovery:** Restore entire volumes in minutes, not hours
- **Testing rollbacks:** Quickly revert failed deployments

#### Step 1: Create VolumeSnapshotClass

```yaml
# snapshot-class.yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: csi-aws-vsc
driver: ebs.csi.aws.com  # AWS EBS CSI driver
deletionPolicy: Delete   # or Retain for long-term storage
parameters:
  encrypted: "true"       # Encrypt snapshots
```

#### Step 2: Create the Snapshot

```yaml
# volume-snapshot.yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: postgres-pre-migration-snapshot
  namespace: production
spec:
  volumeSnapshotClassName: csi-aws-vsc
  source:
    persistentVolumeClaimName: postgres-data-pvc
```

#### Step 3: Restore from Snapshot

```yaml
# restore-from-snapshot.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-restored-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp3-encrypted
  resources:
    requests:
      storage: 500Gi
  dataSource:
    name: postgres-pre-migration-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```

#### Automated Pre-Deployment Snapshots

```yaml
# pre-deployment-snapshot.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pre-deployment-snapshot
spec:
  template:
    spec:
      serviceAccountName: snapshot-creator
      containers:
      - name: snapshot-creator
        image: bitnami/kubectl:latest
        command:
        - /bin/bash
        - -c
        - |
          # Create snapshot with timestamp
          SNAPSHOT_NAME="postgres-pre-deploy-$(date +%Y%m%d-%H%M%S)"
          
          cat <<EOF | kubectl apply -f -
          apiVersion: snapshot.storage.k8s.io/v1
          kind: VolumeSnapshot
          metadata:
            name: $SNAPSHOT_NAME
            namespace: production
            labels:
              type: pre-deployment
              date: $(date +%Y%m%d)
          spec:
            volumeSnapshotClassName: csi-aws-vsc
            source:
              persistentVolumeClaimName: postgres-data-pvc
          EOF
          
          # Wait for snapshot to be ready
          kubectl wait --for=condition=ReadyToUse volumesnapshot/$SNAPSHOT_NAME --timeout=300s
          
          echo "Snapshot $SNAPSHOT_NAME created successfully"
      restartPolicy: Never
```

#### Monitoring Snapshots

```bash
# Check snapshot status
kubectl get volumesnapshots

# Get snapshot details
kubectl describe volumesnapshot postgres-pre-migration-snapshot

# List all snapshots with labels
kubectl get volumesnapshots -l type=pre-deployment

# Check snapshot size and creation time
kubectl get volumesnapshots -o custom-columns=NAME:.metadata.name,SIZE:.status.restoreSize,CREATED:.metadata.creationTimestamp
```

#### Snapshot Cleanup Strategy

```yaml
# snapshot-cleanup-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: snapshot-cleanup
spec:
  schedule: "0 3 * * 0"  # Weekly on Sunday at 3 AM
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: snapshot-manager
          containers:
          - name: cleanup
            image: bitnami/kubectl:latest
            command:
            - /bin/bash
            - -c
            - |
              # Delete snapshots older than 30 days
              CUTOFF_DATE=$(date -d '30 days ago' +%Y%m%d)
              
              kubectl get volumesnapshots -o json | jq -r \
                ".items[] | select(.metadata.creationTimestamp < \"$CUTOFF_DATE\") | .metadata.name" | \
              while read snapshot; do
                echo "Deleting old snapshot: $snapshot"
                kubectl delete volumesnapshot $snapshot
              done
              
              # Keep only last 5 pre-deployment snapshots
              kubectl get volumesnapshots -l type=pre-deployment --sort-by=.metadata.creationTimestamp -o name | \
                head -n -5 | xargs -r kubectl delete
          restartPolicy: OnFailure
```

#### Cross-Cloud Provider Snapshots

**AWS EBS:**
```yaml
driver: ebs.csi.aws.com
parameters:
  encrypted: "true"
  kmsKeyId: "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
```

**Google Cloud Persistent Disk:**
```yaml
driver: pd.csi.storage.gke.io
parameters:
  storage-locations: "us-central1-a,us-central1-b"  # Multi-zone
```

**Azure Disk:**
```yaml
driver: disk.csi.azure.com
parameters:
  incremental: "true"  # Incremental snapshots for cost savings
```

## 🚨 Production Gotchas

### Storage Class Selection
```yaml
# Different performance tiers
storageClassName: gp3          # General purpose (AWS)
storageClassName: io2          # High IOPS (AWS)
storageClassName: standard-rwo # Regional persistent disk (GCP)
storageClassName: premium-lrs  # Premium SSD (Azure)
```

### Access Modes Reality Check
- **ReadWriteOnce (RWO):** One node only - most common
- **ReadOnlyMany (ROX):** Multiple nodes read - rare
- **ReadWriteMany (RWX):** Multiple nodes write - expensive, use NFS/EFS

### Resource Limits
```yaml
resources:
  requests:
    storage: 100Gi    # Minimum guaranteed
  limits:
    storage: 500Gi    # Maximum allowed (if supported)
```

### Backup Verification and Testing

**The Problem:** 90% of companies never test their backups until disaster strikes

```yaml
# backup-verification.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-verification
spec:
  schedule: "0 8 * * 1"  # Weekly on Monday at 8 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup-tester
            image: postgres:15
            command:
            - /bin/bash
            - -c
            - |
              # Test backup restoration
              
              # 1. Download latest backup
              aws s3 cp s3://company-backups/postgres/$(date -d '1 day ago' +%Y%m%d)/backup.sql /tmp/
              
              # 2. Create test database
              createdb test_restore
              
              # 3. Restore backup
              psql test_restore < /tmp/backup.sql
              
              # 4. Verify data integrity
              RECORD_COUNT=$(psql -t test_restore -c "SELECT COUNT(*) FROM users;")
              
              if [ $RECORD_COUNT -gt 1000 ]; then
                echo "✅ Backup verification successful: $RECORD_COUNT records"
                
                # Send success notification
                curl -X POST https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK \
                  -H 'Content-type: application/json' \
                  --data '{"text":"✅ Weekly backup verification passed: '$RECORD_COUNT' records restored successfully"}'
              else
                echo "❌ Backup verification failed: only $RECORD_COUNT records"
                
                # Send failure alert
                curl -X POST https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK \
                  -H 'Content-type: application/json' \
                  --data '{"text":"🚨 BACKUP VERIFICATION FAILED: Only '$RECORD_COUNT' records found in backup!"}'
                
                exit 1
              fi
              
              # 5. Cleanup
              dropdb test_restore
              rm /tmp/backup.sql
            env:
            - name: PGHOST
              value: "postgres-test"
            - name: PGUSER
              value: "admin"
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: password
          restartPolicy: OnFailure
```

## 💡 Production Best Practices

### ✅ Enterprise Do's
- **3-2-1 Backup Rule:** 3 copies, 2 media types, 1 offsite
- **Encrypt everything:** At rest, in transit, and in backups
- **Test restores monthly:** Automate backup verification
- **Multi-cloud strategy:** Never depend on single provider
- **PITR capability:** Continuous WAL shipping for databases
- **Monitoring & alerting:** Disk usage, backup failures, restore times
- **Immutable backups:** Use S3 Object Lock or similar
- **Compliance logging:** Track all backup/restore operations

### ❌ Production Never Do's
- **Single point of failure:** One backup location only
- **Untested backups:** "Backup exists" ≠ "Backup works"
- **No encryption:** Sensitive data in plain text backups
- **Manual processes:** Human error will happen
- **Infinite retention:** Storage costs will explode
- **Cross-region assumptions:** Snapshots don't auto-replicate
- **Shared credentials:** Use IAM roles and service accounts
- **No monitoring:** Silent backup failures are the worst

## 🛠️ Real-World Troubleshooting

### Disaster Recovery Scenarios

#### Scenario 1: Complete Region Failure
**What Happened:** AWS us-east-1 went down for 6 hours

```bash
# Emergency recovery procedure
#!/bin/bash
# disaster-recovery.sh

echo "🚨 DISASTER RECOVERY INITIATED"
echo "Primary region: us-east-1 (DOWN)"
echo "Failover region: us-west-2"

# 1. Switch kubectl context to backup region
kubectl config use-context backup-cluster-us-west-2

# 2. Restore from latest cross-region snapshot
SNAPSHOT_ID=$(aws ec2 describe-snapshots \
  --region us-west-2 \
  --owner-ids self \
  --filters "Name=description,Values=Cross-region backup*" \
  --query 'Snapshots | sort_by(@, &StartTime) | [-1].SnapshotId' \
  --output text)

echo "Latest snapshot: $SNAPSHOT_ID"

# 3. Create volume from snapshot
VOLUME_ID=$(aws ec2 create-volume \
  --region us-west-2 \
  --availability-zone us-west-2a \
  --snapshot-id $SNAPSHOT_ID \
  --volume-type gp3 \
  --query 'VolumeId' --output text)

echo "Created volume: $VOLUME_ID"

# 4. Deploy emergency database
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: emergency-postgres-pv
spec:
  capacity:
    storage: 500Gi
  accessModes:
    - ReadWriteOnce
  awsElasticBlockStore:
    volumeID: $VOLUME_ID
    fsType: ext4
EOF

# 5. Start services
kubectl apply -f emergency-postgres.yaml
kubectl apply -f web-app-emergency.yaml

# 6. Update DNS to point to backup region
aws route53 change-resource-record-sets \
  --hosted-zone-id Z123456789 \
  --change-batch file://dns-failover.json

echo "✅ DISASTER RECOVERY COMPLETE"
echo "Services running in us-west-2"
echo "RTO: $(date)" # Recovery Time Objective
```

#### Scenario 2: Data Corruption Detection
**What Happened:** Application bug corrupted 50% of user data

```bash
# corruption-recovery.sh
#!/bin/bash

echo "🔍 CORRUPTION DETECTED - Starting recovery"

# 1. Immediately stop write operations
kubectl scale deployment web-app --replicas=0
echo "✅ Stopped all write operations"

# 2. Find last known good backup
LAST_GOOD_BACKUP=$(aws s3 ls s3://company-backups/postgres/ \
  --recursive | grep "backup-" | tail -5 | head -1 | awk '{print $4}')

echo "Last good backup: $LAST_GOOD_BACKUP"

# 3. Create recovery database
kubectl exec postgres-0 -- createdb recovery_db

# 4. Restore to recovery database
aws s3 cp s3://company-backups/$LAST_GOOD_BACKUP - | \
  kubectl exec -i postgres-0 -- psql recovery_db

# 5. Compare data integrity
CORRUPT_COUNT=$(kubectl exec postgres-0 -- psql production -t -c \
  "SELECT COUNT(*) FROM users WHERE created_at > '2024-01-15 10:00:00' AND email IS NULL;")

GOOD_COUNT=$(kubectl exec postgres-0 -- psql recovery_db -t -c \
  "SELECT COUNT(*) FROM users WHERE created_at > '2024-01-15 10:00:00';")

echo "Corrupted records: $CORRUPT_COUNT"
echo "Good records: $GOOD_COUNT"

# 6. Selective data recovery
kubectl exec postgres-0 -- psql production -c "
  -- Fix corrupted data
  UPDATE users SET 
    email = recovery.email,
    name = recovery.name
  FROM recovery_db.users recovery
  WHERE users.id = recovery.id 
    AND users.email IS NULL;
"

echo "✅ Data corruption fixed"
echo "Restored $GOOD_COUNT records"

# 7. Resume operations
kubectl scale deployment web-app --replicas=3
echo "✅ Services resumed"
```

### Performance Troubleshooting

#### High IOPS Usage Investigation
```bash
# performance-investigation.sh
#!/bin/bash

echo "📊 PERFORMANCE INVESTIGATION"

# 1. Check current IOPS usage
echo "=== Current IOPS Usage ==="
kubectl top pods --sort-by=cpu

# 2. Identify heavy I/O processes
echo "=== Heavy I/O Processes ==="
kubectl exec postgres-0 -- iostat -x 1 3

# 3. Check for long-running queries
echo "=== Long Running Queries ==="
kubectl exec postgres-0 -- psql production -c "
  SELECT pid, now() - pg_stat_activity.query_start AS duration, query 
  FROM pg_stat_activity 
  WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';
"

# 4. Analyze storage performance
echo "=== Storage Performance ==="
VOLUME_ID=$(kubectl get pv postgres-pv -o jsonpath='{.spec.awsElasticBlockStore.volumeID}')
aws cloudwatch get-metric-statistics \
  --namespace AWS/EBS \
  --metric-name VolumeReadOps \
  --dimensions Name=VolumeId,Value=$VOLUME_ID \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# 5. Recommend optimizations
echo "=== Recommendations ==="
echo "💡 Consider upgrading to io2 for high IOPS workloads"
echo "💡 Enable Multi-Attach for read replicas"
echo "💡 Use gp3 with provisioned IOPS for predictable performance"
```

## 🚀 Complete Production Demo

```bash
# production-storage-demo.sh
#!/bin/bash

echo "🚀 DEPLOYING PRODUCTION STORAGE STACK"

# 1. Deploy storage infrastructure
echo "📦 Deploying storage classes and snapshot classes..."
kubectl apply -f storage-classes.yaml
kubectl apply -f snapshot-classes.yaml

# 2. Deploy applications with persistence
echo "🗄️ Deploying PostgreSQL with backup strategy..."
kubectl apply -f postgres-production.yaml
kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s

# 3. Deploy web application with file uploads
echo "🌐 Deploying web app with persistent uploads..."
kubectl apply -f web-app-storage.yaml
kubectl wait --for=condition=ready pod -l app=web-app --timeout=300s

# 4. Setup backup automation
echo "⏰ Setting up automated backups..."
kubectl apply -f backup-cronjob.yaml
kubectl apply -f cross-region-backup.yaml
kubectl apply -f backup-verification.yaml

# 5. Test persistence
echo "🧪 Testing data persistence..."
./test-persistence.sh

# 6. Create initial snapshots
echo "📸 Creating initial snapshots..."
kubectl apply -f volume-snapshot.yaml
kubectl wait --for=condition=ReadyToUse volumesnapshot postgres-pre-migration-snapshot --timeout=300s

# 7. Display status
echo "✅ DEPLOYMENT COMPLETE"
echo ""
echo "=== Storage Status ==="
kubectl get pvc,pv,volumesnapshots
echo ""
echo "=== Backup Jobs ==="
kubectl get cronjobs
echo ""
echo "=== Next Steps ==="
echo "1. Test disaster recovery: ./disaster-recovery-test.sh"
echo "2. Monitor storage usage: watch kubectl get pvc"
echo "3. Check backup status: kubectl logs -l job-name=database-backup"
```

### Comprehensive Testing Suite

```bash
# test-persistence.sh
#!/bin/bash

echo "🧪 COMPREHENSIVE PERSISTENCE TESTING"

# Test 1: File Upload Persistence
echo "=== Test 1: File Upload Persistence ==="
POD1=$(kubectl get pods -l app=web-app -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD1 -- touch /var/www/uploads/test-file-$(date +%s).jpg
kubectl delete pod $POD1
sleep 30
POD2=$(kubectl get pods -l app=web-app -o jsonpath='{.items[0].metadata.name}')
FILE_COUNT=$(kubectl exec $POD2 -- ls /var/www/uploads/ | wc -l)
if [ $FILE_COUNT -gt 0 ]; then
  echo "✅ File persistence: PASSED ($FILE_COUNT files)"
else
  echo "❌ File persistence: FAILED"
fi

# Test 2: Database Persistence
echo "=== Test 2: Database Persistence ==="
kubectl exec postgres-0 -- psql production -c "CREATE TABLE test_persistence (id SERIAL, data TEXT, created_at TIMESTAMP DEFAULT NOW());"
kubectl exec postgres-0 -- psql production -c "INSERT INTO test_persistence (data) VALUES ('persistence test data');"
kubectl delete pod postgres-0
sleep 60
kubectl wait --for=condition=ready pod postgres-0 --timeout=300s
ROW_COUNT=$(kubectl exec postgres-0 -- psql production -t -c "SELECT COUNT(*) FROM test_persistence;")
if [ $ROW_COUNT -gt 0 ]; then
  echo "✅ Database persistence: PASSED ($ROW_COUNT rows)"
else
  echo "❌ Database persistence: FAILED"
fi

# Test 3: Snapshot Restore
echo "=== Test 3: Snapshot Restore ==="
kubectl apply -f restore-from-snapshot.yaml
kubectl wait --for=condition=Bound pvc postgres-restored-pvc --timeout=300s
echo "✅ Snapshot restore: PASSED"

# Test 4: Cross-Region Backup
echo "=== Test 4: Cross-Region Backup ==="
LATEST_BACKUP=$(aws s3 ls s3://company-backups/postgres/ --recursive | tail -1 | awk '{print $4}')
if [ ! -z "$LATEST_BACKUP" ]; then
  echo "✅ Cross-region backup: PASSED ($LATEST_BACKUP)"
else
  echo "❌ Cross-region backup: FAILED"
fi

echo ""
echo "🎯 PERSISTENCE TESTING COMPLETE"
echo "All critical data persistence mechanisms verified!"
```

---

## 📚 Key Takeaways

### What You Learned
- **Volume Types:** EmptyDir, HostPath, PersistentVolumes with real use cases
- **Backup Strategies:** 3-2-1 rule, cross-region, multi-cloud approaches
- **Volume Snapshots:** Instant backups, disaster recovery, dev cloning
- **Production Patterns:** Enterprise backup verification, monitoring, troubleshooting
- **Disaster Recovery:** Complete region failover, data corruption recovery

### Production Checklist
- ✅ Encrypted storage classes configured
- ✅ Automated daily backups with retention policy
- ✅ Cross-region disaster recovery tested
- ✅ Volume snapshots for instant recovery
- ✅ Backup verification automation
- ✅ Storage monitoring and alerting
- ✅ Disaster recovery runbooks documented

---

## 🎯 Next Lesson

Go to [Lesson 7: Advanced Networking](../07-advanced-networking/) to learn about Ingress and network policies!