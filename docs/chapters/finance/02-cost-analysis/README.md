# 🔍 Cost Analysis & Monitoring - The Netflix Approach

## 🎯 Objective
Build cost monitoring that prevents the next Snapchat $2 billion cloud disaster.

> **"You can't manage what you don't measure."** - Peter Drucker

## 🌟 Why This Matters - The $50 Billion Cloud Waste Problem

### Companies That Master Cost Analysis

**🎬 Netflix** - Optimized $1B+ annual AWS spend
- **Challenge:** Stream to 230M+ subscribers globally without overspending
- **Strategy:** Real-time cost monitoring + predictive analytics + automated optimization
- **Tools:** Custom FinOps platform + Spinnaker + cost allocation by microservice
- **Result:** 23% cost reduction while 3x scaling capacity¹
- **Learning:** Granular cost visibility enables smart optimization

**🏦 Capital One** - Saved $100M+ through cost analytics
- **Transformation:** From on-premises to 100% cloud with cost control
- **Strategy:** Real-time cost dashboards + chargeback model + automated rightsizing
- **Innovation:** Machine learning for cost prediction and anomaly detection
- **Impact:** 40% reduction in cloud costs while improving performance²
- **Secret:** Treat cost data like business intelligence

**📊 Spotify** - Manages multi-cloud costs efficiently
- **Scale:** 400M+ users across AWS, GCP, and on-premises
- **Challenge:** Cost allocation across 4,000+ microservices and 1,200+ teams
- **Solution:** Automated cost tagging + team-based budgets + real-time alerts
- **Result:** 30% cost optimization while maintaining 99.9% uptime³
- **Lesson:** Automation is key to managing complex cost structures

### The Cost of Poor Cost Management
- **💸 Cloud waste:** $17.6 billion wasted annually on unused resources⁴
- **📈 Overspend:** 32% average cloud budget overrun⁵
- **😱 Surprise bills:** 68% of companies experience unexpected cloud costs⁶
- **⏰ Detection time:** 45 days average to notice cost anomalies⁷
- **📉 Optimization gap:** Only 23% of companies have mature cost optimization⁸

*¹Netflix Tech Blog | ²Capital One FinOps Report | ³Spotify Engineering Blog | ⁴Flexera State of Cloud | ⁵RightScale Cloud Report | ⁶CloudHealth Cost Survey | ⁷Densify Cloud Waste Report | ⁸FinOps Foundation Survey*

## 😱 The Snapchat Lesson - When Cost Monitoring Fails

### The $2 Billion Google Cloud Commitment (2017)
- **💥 Impact:** Snapchat committed to spend $2B over 5 years with Google Cloud
- **🕳️ Problem:** No granular cost monitoring or optimization strategy
- **📉 Result:** User growth slowed but cloud costs remained fixed
- **💰 Consequence:** $2B commitment became major financial burden
- **📈 Stock impact:** 82% stock price drop partly due to cloud costs⁹
- **🔄 Recovery:** Took 3 years to renegotiate and optimize cloud spend

### What Proper Cost Analysis Would Have Prevented
```
❌ What Snapchat Did:
- Fixed commitment without usage forecasting
- No cost monitoring or optimization
- No correlation between user growth and costs
- No scenario planning for different growth rates

✅ What They Should Have Done:
- Real-time cost monitoring and alerts
- Usage-based forecasting models
- Cost optimization automation
- Flexible pricing negotiations
```

*⁹Snapchat SEC Filings 2017-2020*

## 📊 Cost Dashboard Setup

### AWS Cost Explorer API
```python
import boto3
import pandas as pd
from datetime import datetime, timedelta

def get_monthly_costs():
    ce = boto3.client('ce')
    
    end_date = datetime.now().strftime('%Y-%m-%d')
    start_date = (datetime.now() - timedelta(days=90)).strftime('%Y-%m-%d')
    
    response = ce.get_cost_and_usage(
        TimePeriod={
            'Start': start_date,
            'End': end_date
        },
        Granularity='MONTHLY',
        Metrics=['BlendedCost'],
        GroupBy=[
            {'Type': 'DIMENSION', 'Key': 'SERVICE'},
        ]
    )
    
    return response['ResultsByTime']

# Get costs by service
costs = get_monthly_costs()
for month in costs:
    print(f"Month: {month['TimePeriod']['Start']}")
    for group in month['Groups']:
        service = group['Keys'][0]
        amount = group['Metrics']['BlendedCost']['Amount']
        print(f"  {service}: ${float(amount):.2f}")
```

### Grafana Dashboard
```yaml
# docker-compose.yml for monitoring stack
version: '3.8'
services:
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus

volumes:
  grafana-data:
  prometheus-data:
```

## 🚨 Cost Alerts

### AWS Budget Alerts
```json
{
  "BudgetName": "MonthlyBudget",
  "BudgetLimit": {
    "Amount": "1000",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST",
  "CostFilters": {
    "TagKey": ["Environment"],
    "TagValue": ["production"]
  },
  "NotificationsWithSubscribers": [
    {
      "Notification": {
        "NotificationType": "ACTUAL",
        "ComparisonOperator": "GREATER_THAN",
        "Threshold": 80,
        "ThresholdType": "PERCENTAGE"
      },
      "Subscribers": [
        {
          "SubscriptionType": "EMAIL",
          "Address": "finance@company.com"
        }
      ]
    }
  ]
}
```

### Slack Cost Alerts
```python
import requests
import json

def send_cost_alert(amount, threshold, webhook_url):
    if amount > threshold:
        message = {
            "text": f"🚨 Cost Alert: Monthly spend is ${amount:.2f}, exceeding threshold of ${threshold:.2f}",
            "attachments": [
                {
                    "color": "danger",
                    "fields": [
                        {
                            "title": "Current Spend",
                            "value": f"${amount:.2f}",
                            "short": True
                        },
                        {
                            "title": "Threshold",
                            "value": f"${threshold:.2f}",
                            "short": True
                        }
                    ]
                }
            ]
        }
        
        response = requests.post(webhook_url, json=message)
        return response.status_code == 200
```

## 📈 Cost Forecasting

### Simple Linear Forecast
```python
import numpy as np
from sklearn.linear_model import LinearRegression

def forecast_monthly_cost(historical_costs, months_ahead=3):
    # Prepare data
    X = np.array(range(len(historical_costs))).reshape(-1, 1)
    y = np.array(historical_costs)
    
    # Train model
    model = LinearRegression()
    model.fit(X, y)
    
    # Forecast
    future_months = np.array(range(len(historical_costs), 
                                 len(historical_costs) + months_ahead)).reshape(-1, 1)
    forecast = model.predict(future_months)
    
    return forecast

# Example usage
historical_costs = [800, 850, 920, 880, 950, 1020]
forecast = forecast_monthly_cost(historical_costs)
print(f"Forecasted costs for next 3 months: {forecast}")
```

## 💡 Cost Optimization Recommendations

### Automated Recommendations
```python
def analyze_cost_optimization():
    recommendations = []
    
    # Check for unused resources
    unused_volumes = get_unused_ebs_volumes()
    if unused_volumes:
        savings = sum(vol['size'] * 0.10 for vol in unused_volumes)  # $0.10/GB/month
        recommendations.append({
            'type': 'unused_storage',
            'description': f'Delete {len(unused_volumes)} unused EBS volumes',
            'monthly_savings': savings
        })
    
    # Check for over-provisioned instances
    oversized_instances = get_oversized_instances()
    for instance in oversized_instances:
        current_cost = instance['monthly_cost']
        recommended_cost = instance['recommended_monthly_cost']
        savings = current_cost - recommended_cost
        
        recommendations.append({
            'type': 'rightsizing',
            'description': f'Downsize {instance["id"]} from {instance["current_type"]} to {instance["recommended_type"]}',
            'monthly_savings': savings
        })
    
    return recommendations

def get_unused_ebs_volumes():
    ec2 = boto3.client('ec2')
    volumes = ec2.describe_volumes(
        Filters=[{'Name': 'status', 'Values': ['available']}]
    )
    return volumes['Volumes']
```

## 🎯 Cost Allocation

### Chargeback Model
```python
def calculate_team_costs(start_date, end_date):
    ce = boto3.client('ce')
    
    response = ce.get_cost_and_usage(
        TimePeriod={
            'Start': start_date,
            'End': end_date
        },
        Granularity='MONTHLY',
        Metrics=['BlendedCost'],
        GroupBy=[
            {'Type': 'TAG', 'Key': 'Team'},
            {'Type': 'TAG', 'Key': 'Project'}
        ]
    )
    
    team_costs = {}
    for result in response['ResultsByTime']:
        for group in result['Groups']:
            team = group['Keys'][0] if group['Keys'][0] else 'untagged'
            project = group['Keys'][1] if len(group['Keys']) > 1 else 'unknown'
            cost = float(group['Metrics']['BlendedCost']['Amount'])
            
            if team not in team_costs:
                team_costs[team] = {}
            team_costs[team][project] = cost
    
    return team_costs
```

## 🎓 What You Learned

- ✅ Cost dashboard creation with Grafana
- ✅ Automated cost alerts and notifications
- ✅ Cost forecasting techniques
- ✅ Optimization recommendations
- ✅ Chargeback and cost allocation

---

**Next:** [Resource Optimization](../03-resource-optimization/)