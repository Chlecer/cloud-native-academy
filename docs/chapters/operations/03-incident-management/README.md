# 🚨 Incident Management

## 🎯 Objective
Build processes to handle incidents effectively and learn from failures.

> **"The difference between a good company and a great company is how quickly they recover from failures."** - Netflix Engineering

## 🌟 Why This Matters - Real World Impact

### Companies That Excel at Incident Management

**🎬 Netflix** - Handles 1 billion+ hours of streaming monthly
- **Result:** 99.99% uptime despite massive scale
- **Secret:** Chaos engineering + excellent incident response
- **Learning:** They intentionally break things to improve recovery

**🛒 Amazon** - Processes millions of orders daily
- **Famous incident:** 2017 S3 outage took down half the internet
- **Response:** 4-hour recovery, detailed postmortem, architectural changes
- **Learning:** Even giants fail, but great companies learn and improve

**💳 Stripe** - Processes billions in payments
- **Challenge:** Payment failures = immediate revenue loss
- **Solution:** Sub-15-minute response times, automated rollbacks
- **Result:** 99.99%+ payment success rate

### The Cost of Poor Incident Management
- **💸 Downtime costs:** $5,600 per minute for e-commerce¹
- **😤 Customer trust:** 25% of users abandon apps after one bad experience²
- **👥 Team burnout:** Poor processes lead to 3AM panic calls³
- **📉 Business impact:** 43% of companies experience 1+ hours of downtime monthly⁴

*¹Gartner 2023 | ²Google/SOASTA Research | ³DORA Report 2023 | ⁴Uptime Institute*

## 📋 Incident Response Process

### Severity Levels (Used by Google, Facebook, Uber)

```
🔴 SEV-1 (Critical) - "All hands on deck"
- Complete service outage (Netflix can't stream)
- Data loss or corruption (Bank loses transaction data)
- Security breach (Customer data exposed)
- Response time: 15 minutes
- Example: "Users can't login to our app"

🟡 SEV-2 (High) - "Important but not panic"
- Partial service degradation (Slow loading times)
- Performance issues (API response time > 5 seconds)
- Non-critical feature failure (Recommendation engine down)
- Response time: 1 hour
- Example: "Search is slow but working"

🟢 SEV-3 (Medium) - "Fix when convenient"
- Minor issues (Typo in UI)
- Cosmetic problems (Button color wrong)
- Response time: 24 hours
- Example: "Footer link is broken"
```

### Real Incident Examples

**SEV-1 Example - E-commerce Site Down**
```
⏰ 14:30 - Monitoring alerts: "HTTP 500 errors spiking"
⏰ 14:32 - On-call engineer confirms: checkout completely broken
⏰ 14:35 - Incident declared, war room created
⏰ 14:45 - Root cause found: database connection pool exhausted
⏰ 15:00 - Fix deployed: increased connection pool size
⏰ 15:15 - Service restored, monitoring for stability

💰 **Impact:** $50,000 lost revenue in 45 minutes
- **Calculation:** 10,000 users × $5 average order × 100% checkout failure
- **Industry benchmark:** E-commerce loses $5,600/minute during outages (Gartner)

📚 **Learning:** Need better database monitoring
- **Best practice:** Monitor connection pool utilization (Google SRE recommendation)
- **Tool:** Prometheus + Grafana for database metrics
```

## 🔧 On-Call Setup

### Why On-Call Rotation?
- ✅ **24/7 coverage** - Someone always available for critical issues
- ✅ **Shared responsibility** - Prevents burnout, distributes knowledge
- ✅ **Faster response** - Dedicated person gets alerts immediately
- ✅ **Accountability** - Clear ownership during incidents

### PagerDuty Integration - The Industry Standard

**What is PagerDuty?**
- 📱 **On-call management platform** used by 70% of Fortune 500 companies¹
- 🔔 **Intelligent alerting** - wakes up the right person at the right time
- 📈 **Incident orchestration** - coordinates response across teams
- 📊 **Analytics** - tracks response times and incident patterns

**Who uses PagerDuty?**
- **Netflix** - Manages 4,000+ daily deployments
- **Shopify** - Handles Black Friday traffic spikes
- **Zoom** - Ensures 300M+ daily meeting participants stay connected
- **Electronic Arts** - Keeps gaming servers running 24/7

**Why not just use email/Slack?**
- ❌ **Email** - Gets lost, no escalation, no acknowledgment tracking
- ❌ **Slack** - People miss notifications, no phone calls for critical issues
- ✅ **PagerDuty** - Guaranteed delivery, phone calls, SMS, escalation chains

### The Complete Alert Flow
```
1. Prometheus detects issue →
2. Alertmanager processes alert →
3. PagerDuty receives alert →
4. PagerDuty pages on-call engineer →
5. Engineer acknowledges and resolves →
6. PagerDuty tracks resolution time
```

### Alertmanager Configuration (Connects Prometheus to PagerDuty)
```yaml
# alertmanager.yml - This is the bridge between monitoring and people
global:
  pagerduty_url: 'https://events.pagerduty.com/v2/enqueue'  # PagerDuty API endpoint

route:
  group_by: ['alertname']     # Group similar alerts (e.g., multiple pods failing)
  group_wait: 10s            # Wait 10s to collect related alerts
  group_interval: 10s        # Send grouped alerts every 10s
  repeat_interval: 1h        # Re-page if not acknowledged in 1 hour
  receiver: 'pagerduty'      # Send to PagerDuty (not email/slack)

receivers:
- name: 'pagerduty'
  pagerduty_configs:
  - routing_key: 'YOUR_INTEGRATION_KEY'  # Links to specific PagerDuty service
    description: '{{ .GroupLabels.alertname }}'  # What's broken?
    details:
      firing: '{{ .Alerts.Firing | len }}'      # How many alerts active?
      resolved: '{{ .Alerts.Resolved | len }}'  # How many resolved?
      cluster: '{{ .CommonLabels.cluster }}'    # Which environment?
      severity: '{{ .CommonLabels.severity }}'  # How urgent?
```

**Why this configuration matters:**
- `group_wait: 10s` - **Prevents alert spam** (imagine 100 pods failing = 100 separate pages)
- `repeat_interval: 1h` - **Ensures response** (pages again if engineer doesn't acknowledge)
- `routing_key` - **Routes to right team** (database alerts go to DB team, not frontend team)

*¹PagerDuty State of Digital Operations Report 2023*

### Setting Up Your PagerDuty Integration

**Step 1: Create PagerDuty Service**
1. Go to PagerDuty → Services → New Service
2. Name: "Production Alerts"
3. Integration: "Prometheus"
4. Copy the **Integration Key** (this becomes your `routing_key`)

**Step 2: Test the Integration**
```bash
# Test alert directly to PagerDuty
curl -X POST https://events.pagerduty.com/v2/enqueue \
  -H "Content-Type: application/json" \
  -d '{
    "routing_key": "YOUR_INTEGRATION_KEY",
    "event_action": "trigger",
    "payload": {
      "summary": "Test alert from Kubernetes",
      "severity": "critical",
      "source": "alertmanager-test"
    }
  }'

# Test through Alertmanager
curl -X POST http://alertmanager:9093/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '[{
    "labels": {
      "alertname": "TestAlert",
      "severity": "critical"
    },
    "annotations": {
      "summary": "This is a test alert from Alertmanager"
    }
  }]'
```

**Step 3: Verify It Works**
- 📱 Check your phone - you should get a call/SMS
- 💻 Check PagerDuty dashboard - incident should appear
- ✅ Acknowledge the test incident

### On-Call Best Practices (Used by Netflix, Spotify)
- 🔄 **Rotate weekly** - prevents burnout
- 📱 **Multiple contact methods** - phone, SMS, push notification
- ⏰ **Escalation rules** - if no response in 5 minutes, page manager
- 📊 **Track metrics** - response time, resolution time, incident frequency

## 📝 Runbooks

### Database Connection Issues
```markdown
# Runbook: Database Connection Failures

## Symptoms
- Application errors: "Connection timeout"
- High response times
- 5xx HTTP status codes

## Investigation Steps

### 1. Check Database Health
```bash
# Check if database pods are running
kubectl get pods -l app=postgres
```
**What to look for:**
- `STATUS: Running` = Good
- `STATUS: CrashLoopBackOff` = Database keeps crashing
- `READY: 0/1` = Pod not ready to accept connections

```bash
# Check database logs for errors
kubectl logs -l app=postgres --tail=100
```
**Common error patterns:**
- `connection refused` = Database not accepting connections
- `out of memory` = Database needs more resources
- `disk full` = Storage issue

### 2. Check Connection Pool Status
```bash
# Test application's database health endpoint
kubectl exec -it app-pod -- curl localhost:8080/health/db
```
**Expected responses:**
- `{"status": "healthy"}` = Connection pool working
- `{"status": "unhealthy"}` = Pool exhausted or database unreachable
- `Connection timeout` = Network or database issue

```bash
# Check connection pool metrics (if available)
kubectl exec -it app-pod -- curl localhost:8080/metrics | grep pool
```

### 3. Test Network Connectivity
```bash
# Test if database service is reachable
kubectl exec -it app-pod -- nc -zv postgres-service 5432
```
**Results meaning:**
- `Connection succeeded` = Network path is working
- `Connection refused` = Service exists but not accepting connections
- `Name resolution failed` = DNS/service discovery issue

```bash
# Alternative connectivity tests
kubectl exec -it app-pod -- nslookup postgres-service
kubectl exec -it app-pod -- ping postgres-service
kubectl exec -it app-pod -- telnet postgres-service 5432
```

## Resolution Steps

### 1. Restart Application Pods
```bash
kubectl rollout restart deployment/myapp
```

**Why use `rollout restart`?**
- ✅ **Zero-downtime restart** - Kubernetes creates new pods before terminating old ones
- ✅ **Rolling update** - Pods restart one by one, maintaining service availability
- ✅ **Automatic rollback** - If new pods fail, old ones stay running
- ✅ **Preserves configuration** - Uses existing deployment spec, just forces pod recreation

**Alternative commands and when to use:**
```bash
# ❌ Don't use - kills all pods at once (downtime)
kubectl delete pods -l app=myapp

# ✅ Use rollout restart - safe, zero-downtime
kubectl rollout restart deployment/myapp

# ✅ Check restart status
kubectl rollout status deployment/myapp

# ✅ Rollback if restart caused issues
kubectl rollout undo deployment/myapp
```

### 2. Scale Database if Needed
```bash
kubectl scale deployment postgres --replicas=2
```

**Why scaling helps:**
- ✅ **Distributes load** across multiple database instances
- ✅ **Increases connection capacity** - more pods = more connections
- ✅ **Provides redundancy** - if one pod fails, others continue

**Scaling best practices:**
```bash
# Check current replica count
kubectl get deployment postgres

# Scale up gradually
kubectl scale deployment postgres --replicas=2

# Wait for pods to be ready
kubectl wait --for=condition=Available deployment/postgres --timeout=300s

# Verify all pods are running
kubectl get pods -l app=postgres

# Check if scaling resolved the issue
kubectl logs -l app=myapp --tail=50 | grep -i "connection"
```

### 4. Advanced Troubleshooting

**Check resource usage:**
```bash
# Check if pods are resource-constrained
kubectl top pods -l app=postgres
kubectl describe pod postgres-pod-name
```
**Look for:**
- `CPU: 100%` = CPU throttling
- `Memory: 90%+` = Memory pressure
- `Events: FailedScheduling` = Resource constraints

**Check Kubernetes events:**
```bash
# See recent cluster events
kubectl get events --sort-by='.lastTimestamp' | tail -20

# Filter events for specific namespace
kubectl get events -n production --field-selector involvedObject.name=postgres
```

**Database-specific checks:**
```bash
# Check database connections (PostgreSQL example)
kubectl exec -it postgres-pod -- psql -U postgres -c \
  "SELECT count(*) as active_connections FROM pg_stat_activity WHERE state = 'active';"

# Check database locks
kubectl exec -it postgres-pod -- psql -U postgres -c \
  "SELECT * FROM pg_locks WHERE NOT granted;"
```

## Escalation Path

### When to Escalate
- ✅ **15 minutes** - No progress on SEV-1 incidents
- ✅ **30 minutes** - Issue persists despite following runbook
- ✅ **Unknown root cause** - Need specialist knowledge
- ✅ **Multiple systems affected** - Potential infrastructure issue

### How to Escalate
```bash
# Page database team lead
curl -X POST https://events.pagerduty.com/v2/enqueue \
  -H "Content-Type: application/json" \
  -d '{
    "routing_key": "DATABASE_TEAM_KEY",
    "event_action": "trigger",
    "payload": {
      "summary": "Database connection issues - escalation needed",
      "severity": "critical",
      "source": "incident-runbook"
    }
  }'
```

### Escalation Handoff
**Provide this information:**
1. **Timeline** - When issue started, what was tried
2. **Impact** - How many users/services affected
3. **Evidence** - Logs, metrics, error messages
4. **Current state** - What's working, what's not

```markdown
# Escalation Template
**Incident:** Database connection failures
**Started:** 14:30 UTC
**Impact:** 15% of users unable to login
**Tried:** Restarted app pods, checked network connectivity
**Current state:** Database pods running but connection pool exhausted
**Logs:** See #incident-123 Slack thread
**Next steps needed:** Database expert to investigate connection limits
```
```

## 📊 Post-Incident Review

> **"Failure is not the opposite of success, it's part of success."** - Google SRE Book

### Why Blameless Postmortems Work

**🚀 Companies doing this right:**
- **Google:** Publishes internal postmortems, celebrates learning from failures¹
- **Etsy:** "Failure parties" - team celebrates what they learned²
- **PagerDuty:** Open-sources their postmortem process³

**📈 Results (Research-backed):**
- **60% reduction** in repeat incidents⁴
- **50% faster** incident resolution (teams learn patterns)⁵
- **2.5x higher** team performance with psychological safety⁶
- **40% better** system reliability through failure analysis⁷

*¹Google SRE Book | ²Etsy Engineering Blog | ³PagerDuty Guide | ⁴DORA Report | ⁵Harvard Business Review | ⁶Google Research | ⁷MIT Sloan Study*

### Blameless Postmortem Template (Google/Netflix Style)
```markdown
# Incident Postmortem: [Date] - [Brief Description]

## Summary
- **Duration**: 2 hours 15 minutes
- **Impact**: 15% of users affected
- **Root Cause**: Database connection pool exhaustion

## Timeline
- 14:30 - First alerts received
- 14:35 - Incident declared, team assembled
- 14:45 - Root cause identified
- 15:30 - Temporary fix deployed
- 16:45 - Permanent fix deployed, incident resolved

## What Went Well 🎆
- ✅ **Quick detection:** Monitoring caught issue in 2 minutes
- ✅ **Team response:** War room assembled in 5 minutes
- ✅ **Communication:** Stakeholders updated every 15 minutes
- ✅ **Root cause:** Database team identified issue quickly

## What Went Wrong 🔍
- ❌ **Blind spot:** No monitoring for connection pool metrics
- ❌ **Outdated docs:** Runbook had wrong database commands
- ❌ **Slow fix:** Took 30 minutes to deploy simple config change
- ❌ **Prevention:** This same issue happened 6 months ago

## Action Items 🎯
**Prevent recurrence:**
- [ ] Add connection pool monitoring dashboard (Owner: @dev-team, Due: Next week)
- [ ] Set up alerts when pool utilization > 80% (Owner: @ops-team, Due: 3 days)

**Improve response:**
- [ ] Update database runbooks with current commands (Owner: @ops-team, Due: 3 days)
- [ ] Practice deployment process in staging (Owner: @dev-team, Due: 1 week)

**Architectural improvements:**
- [ ] Implement circuit breaker pattern (Owner: @dev-team, Due: 2 weeks)
- [ ] Add database connection pooling (Owner: @backend-team, Due: 1 month)

**Follow-up:**
- [ ] Review action items in next team meeting (Owner: @team-lead, Due: 1 week)
- [ ] Share learnings with other teams (Owner: @ops-team, Due: 2 weeks)
```

## 🎓 What You Learned

### Technical Skills
- ✅ **Incident classification** - Prioritize like Netflix and Google
- ✅ **On-call setup** - PagerDuty integration that actually works
- ✅ **Runbook creation** - Step-by-step guides that save hours
- ✅ **Kubernetes troubleshooting** - Real commands for real problems

### Leadership Skills
- ✅ **Blameless culture** - Learn from failures like top tech companies
- ✅ **Communication** - Keep stakeholders informed during chaos
- ✅ **Process improvement** - Turn incidents into system improvements

### Career Impact (Market Data)
- 💼 **Site Reliability Engineer:** $120k-$200k+ at FAANG¹
- 💼 **DevOps Engineer** with incident management: $95k-$160k²
- 💼 **Engineering Manager** (incident management = proven leadership)³
- 💼 **Reliability Consulting:** $150-$300/hour freelance rates⁴
- 💼 **Job growth:** 22% increase in SRE roles (2023-2024)⁵

*¹Levels.fyi | ²Stack Overflow Survey | ³HBR Leadership Study | ⁴Upwork Data | ⁵LinkedIn Jobs Report*

> **Next step:** Practice these skills in your current role. Start small - create a runbook for one common issue. Your team will thank you when the next incident happens!

---

## 🚀 Ready to Level Up?

**What successful engineers do next:**
1. **Implement one thing** - Pick the easiest win (maybe a simple runbook)
2. **Share knowledge** - Teach your team what you learned
3. **Practice** - Use these techniques in your next incident
4. **Build reputation** - Become the person others trust during outages

**Next:** [Automation & CI/CD](../04-automation-cicd/) - Learn how to prevent incidents through automation!

---

## 📚 Sources & Further Reading

### Industry Reports & Research
- [Gartner IT Infrastructure Report 2023](https://www.gartner.com/en/newsroom/press-releases/2023-06-15-gartner-says-average-cost-of-it-downtime-is-5600-per-minute) - Downtime cost statistics
- [DORA State of DevOps Report 2023](https://cloud.google.com/devops/state-of-devops) - DevOps performance metrics
- [Stack Overflow Developer Survey 2023](https://survey.stackoverflow.co/2023/#salary) - Developer salary data
- [Google/SOASTA Mobile Performance Research](https://www.thinkwithgoogle.com/marketing-strategies/app-and-mobile/mobile-page-speed-new-industry-benchmarks/) - User behavior studies

### Company Engineering Blogs & Case Studies
- [Netflix Tech Blog - Chaos Engineering](https://netflixtechblog.com/the-netflix-simian-army-16e57fbab116) - How Netflix builds resilient systems
- [AWS Post-Event Summaries](https://aws.amazon.com/message/41926/) - Real incident postmortems from AWS
- [Stripe Engineering Blog](https://stripe.com/blog/engineering) - Payment system reliability
- [Etsy Engineering - Blameless Postmortems](https://www.etsy.com/codeascraft/blameless-postmortems) - How to learn from failures
- [PagerDuty Postmortem Guide](https://postmortems.pagerduty.com/) - Open-source incident response

### Academic & Management Research
- [Google SRE Book - Chapter 15](https://sre.google/sre-book/postmortem-culture/) - Postmortem culture
- [Harvard Business Review - Learning from Failure](https://hbr.org/2011/04/strategies-for-learning-from-failure) - Organizational learning
- [Google's Project Aristotle](https://rework.withgoogle.com/blog/five-keys-to-a-successful-google-team/) - Psychological safety research
- [MIT Sloan - Learning from Operational Failures](https://mitsloan.mit.edu/ideas-made-to-matter/how-to-learn-operational-failures) - Systems thinking

### Salary & Career Data
- [Levels.fyi SRE Salaries](https://www.levels.fyi/t/software-engineer/focus/site-reliability-engineer) - Tech company compensation
- [Upwork Freelancer Rates 2023](https://www.upwork.com/hire/devops-engineers/) - Consulting rates

### Tools & Documentation
- [Kubernetes Official Documentation](https://kubernetes.io/docs/) - kubectl commands and best practices
- [Prometheus Monitoring](https://prometheus.io/docs/) - Metrics and alerting
- [PagerDuty Integration Guide](https://developer.pagerduty.com/) - On-call setup

> **Note:** All statistics and examples are based on publicly available information from the sources listed above. Links verified as of 2024.