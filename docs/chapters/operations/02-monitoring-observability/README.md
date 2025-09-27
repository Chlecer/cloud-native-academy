# 📊 Monitoring & Observability - The Google SRE Way

## 🎯 Objective
Build monitoring like Google SRE - detect issues before users notice them.

> **"Monitoring is not about collecting data. It's about turning data into insights that drive action."** - Ben Treynor, Google VP of Engineering (Creator of SRE)

## 🌟 Why This Matters - The $62 Billion Downtime Problem

### Companies That Excel at Observability

**🔍 Google** - Monitors 1 billion+ users with 99.99% uptime
- **Scale:** 8.5 billion searches daily across global infrastructure
- **Strategy:** SLI/SLO-based monitoring + error budgets + proactive alerting
- **Innovation:** Created SRE discipline + Prometheus + OpenTelemetry
- **Result:** 99.99%+ uptime while deploying 5,000+ times daily¹
- **Learning:** Observability enables reliability at scale

**🎬 Netflix** - Observes 15,000+ microservices in real-time
- **Challenge:** Monitor 230M+ users streaming across 4,000+ microservices
- **Tools:** Custom observability platform + distributed tracing + chaos engineering
- **Innovation:** Predictive alerting prevents 80% of potential outages
- **Impact:** 99.99% streaming uptime despite massive complexity²
- **Secret:** Observability as competitive advantage

**💳 Stripe** - Monitors $640B in payments with zero tolerance for errors
- **Reliability:** 99.999% payment success rate (5 minutes downtime/year)
- **Strategy:** Real-time metrics + distributed tracing + business KPI monitoring
- **Tools:** Custom observability stack + machine learning anomaly detection
- **Result:** Sub-second incident detection and response³
- **Lesson:** Financial services require observability perfection

### The Cost of Poor Observability
- **💸 Downtime cost:** $5,600 per minute average⁴
- **⏰ Detection time:** 206 minutes average to detect issues⁵
- **😱 MTTR impact:** Poor monitoring increases MTTR by 300%⁶
- **📉 Customer impact:** 88% of users abandon apps after poor experience⁷
- **📈 Business loss:** $62B annually lost to preventable downtime⁸

*¹Google SRE Book | ²Netflix Tech Blog | ³Stripe Engineering | ⁴Gartner Downtime Report | ⁵Datadog State of Monitoring | ⁶New Relic Observability Report | ⁷Google Performance Study | ⁸Uptime Institute Global Survey*

## 🔍 The Three Pillars

### 1. Metrics (What happened?)
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
```

### 2. Logs (Why did it happen?)
```yaml
# fluentd-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      format json
    </source>
    
    <match kubernetes.**>
      @type elasticsearch
      host elasticsearch.logging.svc.cluster.local
      port 9200
      index_name kubernetes
    </match>
```

### 3. Traces (How did it happen?)
```javascript
// Jaeger tracing setup
const { initTracer } = require('jaeger-client');

const config = {
  serviceName: 'user-service',
  sampler: {
    type: 'const',
    param: 1,
  },
  reporter: {
    logSpans: true,
    agentHost: 'jaeger-agent',
    agentPort: 6832,
  },
};

const tracer = initTracer(config);

// Instrument HTTP requests
app.use((req, res, next) => {
  const span = tracer.startSpan(`${req.method} ${req.path}`);
  req.span = span;
  
  res.on('finish', () => {
    span.setTag('http.status_code', res.statusCode);
    span.finish();
  });
  
  next();
});
```

## 📈 Application Metrics

### Custom Metrics with Prometheus
```javascript
const prometheus = require('prom-client');

// Create metrics
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

const httpRequestsTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

// Middleware to collect metrics
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const labels = {
      method: req.method,
      route: req.route?.path || req.path,
      status_code: res.statusCode
    };
    
    httpRequestDuration.observe(labels, duration);
    httpRequestsTotal.inc(labels);
  });
  
  next();
});

// Metrics endpoint
app.get('/metrics', (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(prometheus.register.metrics());
});
```

## 🚨 Alerting Rules

### Prometheus Alerting
```yaml
# alerts.yml
groups:
  - name: application
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status_code=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second"
      
      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "95th percentile latency is {{ $value }}s"
```

### Slack Notifications
```yaml
# alertmanager.yml
global:
  slack_api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    slack_configs:
      - channel: '#alerts'
        title: 'Alert: {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
```

## 📊 Grafana Dashboards

### Application Dashboard
```json
{
  "dashboard": {
    "title": "Application Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{route}}"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total{status_code=~\"5..\"}[5m])",
            "legendFormat": "5xx errors"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      }
    ]
  }
}
```

## 🔍 Log Analysis

### Structured Logging
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'app.log' })
  ]
});

// Usage
logger.info('User login', {
  userId: user.id,
  email: user.email,
  ip: req.ip,
  userAgent: req.get('User-Agent')
});

logger.error('Database connection failed', {
  error: error.message,
  stack: error.stack,
  query: 'SELECT * FROM users'
});
```

## 🎓 What You Learned

- ✅ Three pillars of observability
- ✅ Prometheus metrics collection
- ✅ Grafana dashboard creation
- ✅ Alerting and notification setup
- ✅ Structured logging practices
- ✅ Distributed tracing with Jaeger

---

**Next:** [Incident Management](../03-incident-management/)