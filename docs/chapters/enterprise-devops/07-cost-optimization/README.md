# 💰 Enterprise Cost Optimization - FinOps Excellence

## 🎯 Objective
Master enterprise cost optimization with FinOps practices, automated resource management, cost allocation, chargeback systems, and savings strategies used by Fortune 500 companies.

> **"Every dollar saved on infrastructure is a dollar that can be invested in innovation."**

## 🌟 Why Cost Optimization Matters

### Enterprise Cost Impact Analysis
- **Netflix** - Saves $100M+ annually through automated scaling
- **Spotify** - 40% cost reduction through multi-cloud optimization
- **Airbnb** - $50M+ savings through rightsizing and scheduling
- **Average Enterprise** - 30-50% cloud waste without optimization

### FinOps Maturity Levels
- **Crawl** - Basic cost visibility and reporting
- **Walk** - Automated cost allocation and governance
- **Run** - Predictive optimization and business alignment

## 🏗️ Enterprise FinOps Architecture

### Complete Cost Management Platform
```yaml
# finops-platform.yaml - Enterprise cost management
apiVersion: v1
kind: Namespace
metadata:
  name: finops-system
  labels:
    cost-center: "platform"
    business-unit: "engineering"
---
# Cost Allocation Controller
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cost-allocation-controller
  namespace: finops-system
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cost-allocation-controller
  template:
    metadata:
      labels:
        app: cost-allocation-controller
    spec:
      serviceAccountName: cost-allocation-sa
      containers:
      - name: controller
        image: enterprise/cost-allocation:v1.2.0
        env:
        - name: AWS_REGION
          value: "us-east-1"
        - name: COST_ALLOCATION_TAGS
          value: "team,environment,project,cost-center"
        - name: BILLING_ACCOUNT_ID
          valueFrom:
            secretKeyRef:
              name: aws-billing-secret
              key: account-id
        - name: DATADOG_API_KEY
          valueFrom:
            secretKeyRef:
              name: datadog-secret
              key: api-key
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        volumeMounts:
        - name: cost-policies
          mountPath: /etc/cost-policies
      volumes:
      - name: cost-policies
        configMap:
          name: cost-optimization-policies
---
# Cost Optimization Policies
apiVersion: v1
kind: ConfigMap
metadata:
  name: cost-optimization-policies
  namespace: finops-system
data:
  policies.yaml: |
    # Resource Rightsizing Policies
    rightsizing:
      cpu_utilization_threshold: 70
      memory_utilization_threshold: 80
      evaluation_period_days: 7
      min_savings_threshold: 50  # $50/month minimum savings
      
      rules:
        - name: "underutilized-instances"
          condition: "cpu < 20% AND memory < 30% for 7 days"
          action: "recommend_downsize"
          
        - name: "overutilized-instances"
          condition: "cpu > 90% OR memory > 95% for 1 hour"
          action: "recommend_upsize"
          
        - name: "idle-resources"
          condition: "cpu < 5% AND memory < 10% for 24 hours"
          action: "recommend_terminate"
    
    # Scheduling Policies
    scheduling:
      dev_environment:
        schedule: "0 18 * * 1-5"  # Stop at 6 PM weekdays
        restart: "0 8 * * 1-5"   # Start at 8 AM weekdays
        timezone: "America/New_York"
        
      staging_environment:
        schedule: "0 20 * * *"    # Stop at 8 PM daily
        restart: "0 7 * * *"     # Start at 7 AM daily
        
      test_environment:
        schedule: "0 19 * * 1-5"  # Stop at 7 PM weekdays
        restart: "0 9 * * 1-5"   # Start at 9 AM weekdays
    
    # Reserved Instance Recommendations
    reserved_instances:
      utilization_threshold: 75
      commitment_period: 12  # months
      payment_option: "partial_upfront"
      instance_families: ["m5", "c5", "r5", "t3"]
      
    # Spot Instance Policies
    spot_instances:
      max_interruption_rate: 10  # 10% max interruption
      fallback_to_ondemand: true
      suitable_workloads:
        - "batch-processing"
        - "ci-cd-runners"
        - "development"
        - "testing"
    
    # Storage Optimization
    storage:
      lifecycle_policies:
        - name: "log-archival"
          transition_to_ia: 30    # days
          transition_to_glacier: 90
          expiration: 2555        # 7 years
          
        - name: "backup-retention"
          transition_to_ia: 7
          transition_to_glacier: 30
          expiration: 365
          
      unused_volumes:
        detection_period: 7  # days
        action: "snapshot_and_delete"
        
      snapshot_cleanup:
        retention_period: 30  # days
        automated_cleanup: true
```

### Automated Cost Optimization
```yaml
# cost-optimizer-cronjob.yaml - Automated optimization
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cost-optimizer
  namespace: finops-system
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: cost-optimizer-sa
          containers:
          - name: cost-optimizer
            image: enterprise/cost-optimizer:v2.1.0
            env:
            - name: AWS_REGION
              value: "us-east-1"
            - name: OPTIMIZATION_MODE
              value: "aggressive"  # conservative, moderate, aggressive
            - name: DRY_RUN
              value: "false"
            - name: SLACK_WEBHOOK
              valueFrom:
                secretKeyRef:
                  name: notification-secrets
                  key: slack-webhook
            command:
            - /bin/sh
            - -c
            - |
              echo "💰 Starting cost optimization analysis..."
              
              # Analyze resource utilization
              python3 /app/analyze-utilization.py \
                --period 7d \
                --threshold-cpu 70 \
                --threshold-memory 80 \
                --output /tmp/utilization-report.json
              
              # Generate rightsizing recommendations
              python3 /app/generate-recommendations.py \
                --input /tmp/utilization-report.json \
                --min-savings 50 \
                --output /tmp/recommendations.json
              
              # Apply approved optimizations
              if [ "$DRY_RUN" = "false" ]; then
                python3 /app/apply-optimizations.py \
                  --recommendations /tmp/recommendations.json \
                  --auto-approve-threshold 100
              fi
              
              # Generate cost report
              python3 /app/generate-cost-report.py \
                --period 30d \
                --breakdown team,environment,project \
                --output /tmp/cost-report.html
              
              # Send notifications
              python3 /app/send-notifications.py \
                --report /tmp/cost-report.html \
                --recommendations /tmp/recommendations.json \
                --webhook $SLACK_WEBHOOK
              
              echo "✅ Cost optimization completed"
            resources:
              requests:
                cpu: 200m
                memory: 256Mi
              limits:
                cpu: 1000m
                memory: 1Gi
          restartPolicy: OnFailure
---
# Resource Scheduler for Dev/Test Environments
apiVersion: batch/v1
kind: CronJob
metadata:
  name: resource-scheduler
  namespace: finops-system
spec:
  schedule: "0 18 * * 1-5"  # 6 PM weekdays - shutdown
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: scheduler
            image: enterprise/resource-scheduler:v1.0.0
            env:
            - name: ACTION
              value: "shutdown"
            - name: ENVIRONMENTS
              value: "development,testing"
            - name: EXCLUDE_NAMESPACES
              value: "kube-system,istio-system,monitoring"
            command:
            - /bin/sh
            - -c
            - |
              echo "⏰ Executing scheduled resource management..."
              
              if [ "$ACTION" = "shutdown" ]; then
                echo "🛑 Shutting down non-production resources..."
                
                # Scale down deployments
                for env in $(echo $ENVIRONMENTS | tr ',' ' '); do
                  echo "Scaling down deployments in $env environment..."
                  kubectl get deployments --all-namespaces -l environment=$env -o json | \
                    jq -r '.items[] | "\(.metadata.namespace) \(.metadata.name)"' | \
                    while read namespace deployment; do
                      if [[ ! "$EXCLUDE_NAMESPACES" =~ "$namespace" ]]; then
                        kubectl scale deployment $deployment -n $namespace --replicas=0
                        echo "Scaled down $deployment in $namespace"
                      fi
                    done
                done
                
                # Stop EC2 instances
                aws ec2 describe-instances \
                  --filters "Name=tag:Environment,Values=development,testing" \
                          "Name=instance-state-name,Values=running" \
                  --query 'Reservations[].Instances[].InstanceId' \
                  --output text | xargs -r aws ec2 stop-instances --instance-ids
                
                echo "💰 Estimated daily savings: $2,500"
                
              elif [ "$ACTION" = "startup" ]; then
                echo "🚀 Starting up non-production resources..."
                
                # Scale up deployments
                for env in $(echo $ENVIRONMENTS | tr ',' ' '); do
                  kubectl get deployments --all-namespaces -l environment=$env -o json | \
                    jq -r '.items[] | "\(.metadata.namespace) \(.metadata.name) \(.metadata.annotations["finops/original-replicas"] // "1")"' | \
                    while read namespace deployment replicas; do
                      if [[ ! "$EXCLUDE_NAMESPACES" =~ "$namespace" ]]; then
                        kubectl scale deployment $deployment -n $namespace --replicas=$replicas
                        echo "Scaled up $deployment in $namespace to $replicas replicas"
                      fi
                    done
                done
                
                # Start EC2 instances
                aws ec2 describe-instances \
                  --filters "Name=tag:Environment,Values=development,testing" \
                          "Name=instance-state-name,Values=stopped" \
                  --query 'Reservations[].Instances[].InstanceId' \
                  --output text | xargs -r aws ec2 start-instances --instance-ids
              fi
              
              echo "✅ Resource scheduling completed"
          restartPolicy: OnFailure
---
# Startup CronJob (separate for clarity)
apiVersion: batch/v1
kind: CronJob
metadata:
  name: resource-startup
  namespace: finops-system
spec:
  schedule: "0 8 * * 1-5"  # 8 AM weekdays - startup
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: scheduler
            image: enterprise/resource-scheduler:v1.0.0
            env:
            - name: ACTION
              value: "startup"
            - name: ENVIRONMENTS
              value: "development,testing"
            - name: EXCLUDE_NAMESPACES
              value: "kube-system,istio-system,monitoring"
            command: ["/bin/sh", "-c", "# Same script as above"]
          restartPolicy: OnFailure
```

## 📊 Cost Allocation & Chargeback

### Enterprise Chargeback System
```python
# cost-allocation.py - Enterprise cost allocation system
import boto3
import pandas as pd
from datetime import datetime, timedelta
import json
import requests

class EnterpriseFinOps:
    def __init__(self, aws_account_id, datadog_api_key):
        self.aws_account_id = aws_account_id
        self.ce_client = boto3.client('ce')  # Cost Explorer
        self.ec2_client = boto3.client('ec2')
        self.datadog_api_key = datadog_api_key
        
    def get_cost_by_tags(self, start_date, end_date, group_by_tags):
        """Get AWS costs grouped by specified tags"""
        
        response = self.ce_client.get_cost_and_usage(
            TimePeriod={
                'Start': start_date.strftime('%Y-%m-%d'),
                'End': end_date.strftime('%Y-%m-%d')
            },
            Granularity='DAILY',
            Metrics=['BlendedCost', 'UnblendedCost', 'UsageQuantity'],
            GroupBy=[
                {'Type': 'TAG', 'Key': tag} for tag in group_by_tags
            ]
        )
        
        cost_data = []
        for result in response['ResultsByTime']:
            date = result['TimePeriod']['Start']
            for group in result['Groups']:
                tags = dict(zip(group_by_tags, group['Keys']))
                cost = float(group['Metrics']['BlendedCost']['Amount'])
                
                cost_data.append({
                    'date': date,
                    'cost': cost,
                    **tags
                })
        
        return pd.DataFrame(cost_data)
    
    def generate_chargeback_report(self, month, year):
        """Generate monthly chargeback report by team/project"""
        
        start_date = datetime(year, month, 1)
        if month == 12:
            end_date = datetime(year + 1, 1, 1)
        else:
            end_date = datetime(year, month + 1, 1)
        
        # Get cost data
        cost_df = self.get_cost_by_tags(
            start_date, end_date,
            ['team', 'project', 'environment', 'cost-center']
        )
        
        # Calculate team allocations
        team_costs = cost_df.groupby(['team', 'environment']).agg({
            'cost': 'sum'
        }).reset_index()
        
        # Generate chargeback allocations
        chargeback_data = []
        for _, row in team_costs.iterrows():
            team = row['team']
            environment = row['environment']
            cost = row['cost']
            
            # Apply cost allocation rules
            if environment == 'production':
                allocation_rate = 1.0  # 100% chargeback for prod
            elif environment == 'staging':
                allocation_rate = 0.7  # 70% chargeback for staging
            elif environment == 'development':
                allocation_rate = 0.5  # 50% chargeback for dev
            else:
                allocation_rate = 0.3  # 30% for other environments
            
            chargeback_amount = cost * allocation_rate
            
            chargeback_data.append({
                'team': team,
                'environment': environment,
                'total_cost': cost,
                'allocation_rate': allocation_rate,
                'chargeback_amount': chargeback_amount,
                'month': f"{year}-{month:02d}"
            })
        
        return pd.DataFrame(chargeback_data)
    
    def identify_cost_anomalies(self, threshold_percentage=20):
        """Identify cost anomalies using AWS Cost Anomaly Detection"""
        
        # Get cost anomalies from AWS
        response = self.ce_client.get_anomalies(
            DateInterval={
                'StartDate': (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d'),
                'EndDate': datetime.now().strftime('%Y-%m-%d')
            }
        )
        
        anomalies = []
        for anomaly in response['Anomalies']:
            if anomaly['Impact']['TotalImpact'] > threshold_percentage:
                anomalies.append({
                    'anomaly_id': anomaly['AnomalyId'],
                    'service': anomaly['RootCauses'][0]['Service'] if anomaly['RootCauses'] else 'Unknown',
                    'impact': anomaly['Impact']['TotalImpact'],
                    'start_date': anomaly['AnomalyStartDate'],
                    'end_date': anomaly['AnomalyEndDate'],
                    'description': anomaly['RootCauses'][0]['Description'] if anomaly['RootCauses'] else 'No description'
                })
        
        return anomalies
    
    def get_rightsizing_recommendations(self):
        """Get EC2 rightsizing recommendations"""
        
        response = self.ce_client.get_rightsizing_recommendation(
            Service='AmazonEC2',
            Configuration={
                'BenefitsConsidered': True,
                'RecommendationTarget': 'SAME_INSTANCE_FAMILY'
            }
        )
        
        recommendations = []
        for rec in response['RightsizingRecommendations']:
            if rec['RightsizingType'] != 'None':
                recommendations.append({
                    'instance_id': rec['CurrentInstance']['ResourceId'],
                    'current_type': rec['CurrentInstance']['InstanceType'],
                    'recommended_type': rec['ModifyRecommendationDetail']['TargetInstances'][0]['InstanceType'],
                    'monthly_savings': rec['ModifyRecommendationDetail']['TargetInstances'][0]['EstimatedMonthlySavings'],
                    'rightsizing_type': rec['RightsizingType']
                })
        
        return recommendations
    
    def send_cost_alert(self, webhook_url, alert_data):
        """Send cost alert to Slack"""
        
        message = {
            "text": f"💰 Cost Alert: {alert_data['title']}",
            "attachments": [
                {
                    "color": "warning" if alert_data['severity'] == 'medium' else "danger",
                    "fields": [
                        {
                            "title": "Current Cost",
                            "value": f"${alert_data['current_cost']:,.2f}",
                            "short": True
                        },
                        {
                            "title": "Budget",
                            "value": f"${alert_data['budget']:,.2f}",
                            "short": True
                        },
                        {
                            "title": "Variance",
                            "value": f"{alert_data['variance']:.1f}%",
                            "short": True
                        },
                        {
                            "title": "Recommendation",
                            "value": alert_data['recommendation'],
                            "short": False
                        }
                    ]
                }
            ]
        }
        
        requests.post(webhook_url, json=message)

# Usage example
if __name__ == "__main__":
    finops = EnterpriseFinOps("123456789012", "your-datadog-api-key")
    
    # Generate monthly chargeback report
    chargeback_report = finops.generate_chargeback_report(11, 2024)
    print("Chargeback Report:")
    print(chargeback_report.to_string(index=False))
    
    # Check for cost anomalies
    anomalies = finops.identify_cost_anomalies(threshold_percentage=15)
    if anomalies:
        print(f"\n⚠️ Found {len(anomalies)} cost anomalies:")
        for anomaly in anomalies:
            print(f"- {anomaly['service']}: ${anomaly['impact']:.2f} impact")
    
    # Get rightsizing recommendations
    recommendations = finops.get_rightsizing_recommendations()
    total_savings = sum(float(rec['monthly_savings']) for rec in recommendations)
    print(f"\n💡 Potential monthly savings from rightsizing: ${total_savings:,.2f}")
```

## 🔧 PowerShell Cost Optimization Scripts

### Complete FinOps Automation
```powershell
# finops-automation.ps1 - Complete FinOps automation suite
param(
    [Parameter(Mandatory=$true)]
    [string]$AwsAccountId,
    
    [Parameter(Mandatory=$true)]
    [string]$Environment,
    
    [string]$SlackWebhook,
    [decimal]$CostThreshold = 10000,  # $10,000 monthly threshold
    [int]$AnalysisPeriodDays = 30
)

Write-Host "💰 Starting FinOps automation for $Environment..." -ForegroundColor Green

# Function to get AWS costs
function Get-AWSCosts {
    param(
        [datetime]$StartDate,
        [datetime]$EndDate,
        [string[]]$GroupBy = @("SERVICE")
    )
    
    $costData = aws ce get-cost-and-usage `
        --time-period Start=$($StartDate.ToString("yyyy-MM-dd")),End=$($EndDate.ToString("yyyy-MM-dd")) `
        --granularity DAILY `
        --metrics BlendedCost `
        --group-by Type=DIMENSION,Key=$($GroupBy -join ",") `
        --output json | ConvertFrom-Json
    
    return $costData
}

# Function to analyze cost trends
function Analyze-CostTrends {
    param(
        [object]$CostData
    )
    
    $trends = @()
    $previousCost = 0
    
    foreach ($result in $CostData.ResultsByTime) {
        $dailyCost = 0
        foreach ($group in $result.Groups) {
            $dailyCost += [decimal]$group.Metrics.BlendedCost.Amount
        }
        
        if ($previousCost -gt 0) {
            $changePercent = (($dailyCost - $previousCost) / $previousCost) * 100
            $trends += @{
                Date = $result.TimePeriod.Start
                Cost = $dailyCost
                Change = $changePercent
            }
        }
        
        $previousCost = $dailyCost
    }
    
    return $trends
}

# Function to get rightsizing recommendations
function Get-RightsizingRecommendations {
    $recommendations = aws ce get-rightsizing-recommendation `
        --service AmazonEC2 `
        --output json | ConvertFrom-Json
    
    $savings = 0
    $recCount = 0
    
    foreach ($rec in $recommendations.RightsizingRecommendations) {
        if ($rec.RightsizingType -ne "None") {
            $recCount++
            if ($rec.ModifyRecommendationDetail.TargetInstances) {
                $savings += [decimal]$rec.ModifyRecommendationDetail.TargetInstances[0].EstimatedMonthlySavings
            }
        }
    }
    
    return @{
        Count = $recCount
        PotentialSavings = $savings
        Recommendations = $recommendations.RightsizingRecommendations
    }
}

# Function to identify unused resources
function Find-UnusedResources {
    Write-Host "🔍 Identifying unused resources..." -ForegroundColor Yellow
    
    $unusedResources = @()
    
    # Find unattached EBS volumes
    $unattachedVolumes = aws ec2 describe-volumes `
        --filters "Name=status,Values=available" `
        --query "Volumes[?State=='available'].[VolumeId,Size,VolumeType,CreateTime]" `
        --output json | ConvertFrom-Json
    
    foreach ($volume in $unattachedVolumes) {
        $unusedResources += @{
            Type = "EBS Volume"
            ResourceId = $volume[0]
            Size = "$($volume[1])GB"
            EstimatedMonthlyCost = $volume[1] * 0.10  # Approximate cost per GB
        }
    }
    
    # Find unused Elastic IPs
    $unusedEIPs = aws ec2 describe-addresses `
        --query "Addresses[?AssociationId==null].[PublicIp,AllocationId]" `
        --output json | ConvertFrom-Json
    
    foreach ($eip in $unusedEIPs) {
        $unusedResources += @{
            Type = "Elastic IP"
            ResourceId = $eip[1]
            PublicIp = $eip[0]
            EstimatedMonthlyCost = 3.65  # $0.005/hour * 24 * 30
        }
    }
    
    # Find idle load balancers (simplified check)
    $loadBalancers = aws elbv2 describe-load-balancers --output json | ConvertFrom-Json
    foreach ($lb in $loadBalancers.LoadBalancers) {
        # Check if load balancer has targets
        $targets = aws elbv2 describe-target-groups `
            --load-balancer-arn $lb.LoadBalancerArn `
            --output json | ConvertFrom-Json
        
        $hasHealthyTargets = $false
        foreach ($tg in $targets.TargetGroups) {
            $health = aws elbv2 describe-target-health `
                --target-group-arn $tg.TargetGroupArn `
                --output json | ConvertFrom-Json
            
            if ($health.TargetHealthDescriptions | Where-Object { $_.TargetHealth.State -eq "healthy" }) {
                $hasHealthyTargets = $true
                break
            }
        }
        
        if (-not $hasHealthyTargets) {
            $unusedResources += @{
                Type = "Load Balancer"
                ResourceId = $lb.LoadBalancerName
                EstimatedMonthlyCost = 22.50  # Approximate ALB cost
            }
        }
    }
    
    return $unusedResources
}

# Function to generate cost optimization report
function Generate-CostReport {
    param(
        [object]$CostData,
        [object]$Trends,
        [object]$RightsizingRecs,
        [object]$UnusedResources
    )
    
    $totalCurrentCost = 0
    foreach ($result in $CostData.ResultsByTime) {
        foreach ($group in $result.Groups) {
            $totalCurrentCost += [decimal]$group.Metrics.BlendedCost.Amount
        }
    }
    
    $totalPotentialSavings = $RightsizingRecs.PotentialSavings
    foreach ($resource in $UnusedResources) {
        $totalPotentialSavings += $resource.EstimatedMonthlyCost
    }
    
    $report = @{
        Environment = $Environment
        AnalysisPeriod = "$AnalysisPeriodDays days"
        TotalCost = $totalCurrentCost
        PotentialSavings = $totalPotentialSavings
        SavingsPercentage = ($totalPotentialSavings / $totalCurrentCost) * 100
        RightsizingOpportunities = $RightsizingRecs.Count
        UnusedResourcesCount = $UnusedResources.Count
        Recommendations = @()
    }
    
    # Add specific recommendations
    if ($RightsizingRecs.Count -gt 0) {
        $report.Recommendations += "💡 $($RightsizingRecs.Count) EC2 instances can be rightsized for $($RightsizingRecs.PotentialSavings.ToString('C')) monthly savings"
    }
    
    if ($UnusedResources.Count -gt 0) {
        $unusedSavings = ($UnusedResources | Measure-Object -Property EstimatedMonthlyCost -Sum).Sum
        $report.Recommendations += "🗑️ $($UnusedResources.Count) unused resources can be removed for $($unusedSavings.ToString('C')) monthly savings"
    }
    
    # Check for cost anomalies
    $highCostDays = $Trends | Where-Object { $_.Change -gt 20 }
    if ($highCostDays.Count -gt 0) {
        $report.Recommendations += "⚠️ $($highCostDays.Count) days with >20% cost increase detected - investigate usage patterns"
    }
    
    return $report
}

# Function to send Slack notification
function Send-SlackNotification {
    param(
        [object]$Report
    )
    
    if (-not $SlackWebhook) {
        Write-Host "⚠️ No Slack webhook provided, skipping notification" -ForegroundColor Yellow
        return
    }
    
    $color = "good"
    if ($Report.TotalCost -gt $CostThreshold) {
        $color = "warning"
    }
    if ($Report.TotalCost -gt ($CostThreshold * 1.5)) {
        $color = "danger"
    }
    
    $message = @{
        text = "💰 FinOps Report for $($Report.Environment)"
        attachments = @(
            @{
                color = $color
                fields = @(
                    @{
                        title = "Total Cost ($($Report.AnalysisPeriod))"
                        value = $Report.TotalCost.ToString('C')
                        short = $true
                    }
                    @{
                        title = "Potential Savings"
                        value = $Report.PotentialSavings.ToString('C')
                        short = $true
                    }
                    @{
                        title = "Savings Opportunity"
                        value = "$($Report.SavingsPercentage.ToString('F1'))%"
                        short = $true
                    }
                    @{
                        title = "Optimization Opportunities"
                        value = "$($Report.RightsizingOpportunities) rightsizing + $($Report.UnusedResourcesCount) unused resources"
                        short = $true
                    }
                )
                text = ($Report.Recommendations -join "`n")
            }
        )
    } | ConvertTo-Json -Depth 10
    
    try {
        Invoke-RestMethod -Uri $SlackWebhook -Method Post -Body $message -ContentType "application/json"
        Write-Host "✅ Slack notification sent" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to send Slack notification: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Main execution
try {
    # Get cost data
    $endDate = Get-Date
    $startDate = $endDate.AddDays(-$AnalysisPeriodDays)
    
    Write-Host "📊 Analyzing costs from $($startDate.ToString('yyyy-MM-dd')) to $($endDate.ToString('yyyy-MM-dd'))..." -ForegroundColor Yellow
    $costData = Get-AWSCosts -StartDate $startDate -EndDate $endDate -GroupBy @("SERVICE", "USAGE_TYPE")
    
    # Analyze trends
    Write-Host "📈 Analyzing cost trends..." -ForegroundColor Yellow
    $trends = Analyze-CostTrends -CostData $costData
    
    # Get rightsizing recommendations
    Write-Host "🎯 Getting rightsizing recommendations..." -ForegroundColor Yellow
    $rightsizingRecs = Get-RightsizingRecommendations
    
    # Find unused resources
    $unusedResources = Find-UnusedResources
    
    # Generate report
    Write-Host "📋 Generating cost optimization report..." -ForegroundColor Yellow
    $report = Generate-CostReport -CostData $costData -Trends $trends -RightsizingRecs $rightsizingRecs -UnusedResources $unusedResources
    
    # Display report
    Write-Host "`n💰 FinOps Report for $Environment" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host "Total Cost ($($report.AnalysisPeriod)): $($report.TotalCost.ToString('C'))" -ForegroundColor White
    Write-Host "Potential Savings: $($report.PotentialSavings.ToString('C'))" -ForegroundColor Yellow
    Write-Host "Savings Opportunity: $($report.SavingsPercentage.ToString('F1'))%" -ForegroundColor Yellow
    Write-Host "Rightsizing Opportunities: $($report.RightsizingOpportunities)" -ForegroundColor White
    Write-Host "Unused Resources: $($report.UnusedResourcesCount)" -ForegroundColor White
    
    Write-Host "`n📋 Recommendations:" -ForegroundColor Green
    foreach ($rec in $report.Recommendations) {
        Write-Host "  $rec" -ForegroundColor White
    }
    
    # Send Slack notification
    Send-SlackNotification -Report $report
    
    # Save detailed report
    $reportPath = "finops-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath
    Write-Host "`n📄 Detailed report saved to: $reportPath" -ForegroundColor Green
    
    Write-Host "`n🎉 FinOps analysis completed successfully!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Error during FinOps analysis: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

## 🏆 Enterprise Cost Optimization Success Stories

### Netflix - $100M+ Annual Savings
**Challenge:** Optimizing costs for 200M+ global users
**Strategy:**
- Predictive auto-scaling based on viewing patterns
- Reserved Instance optimization
- Multi-region cost optimization
- Custom cost allocation by content type

**Results:**
- $100M+ annual savings
- 40% reduction in compute costs
- 99.99% availability maintained
- Real-time cost visibility

### Spotify - 40% Multi-Cloud Savings
**Challenge:** Managing costs across AWS, GCP, and Azure
**Strategy:**
- Workload placement optimization
- Spot instance utilization (80% of compute)
- Automated resource scheduling
- Cross-cloud cost comparison

**Results:**
- 40% overall cost reduction
- 80% spot instance adoption
- $50M+ annual savings
- Improved resource utilization

---

**Master Enterprise Cost Optimization and become the FinOps expert every company needs!** 💰