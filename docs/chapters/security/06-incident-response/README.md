# 🚨 Security Incident Response - The $10 Million Hour

## 🎯 Objective
Respond to security incidents like the pros - minimize damage, learn, and improve.

> **"The question is not if you will be breached, but when. Your response determines the damage."** - Kevin Mitnick, Security Expert

## 🌟 Why This Matters - The Incident Response Reality

### Companies That Excel at Incident Response

**🎮 Sony PlayStation** - Transformed after 2011 breach
- **2011 Disaster:** 77 million accounts compromised, 23 days offline
- **Cost:** $171 million in damages and lost revenue¹
- **Transformation:** Built world-class incident response team
- **2023 Result:** Detected and contained breach in 2 hours, zero customer impact²
- **Learning:** Great incident response is built on the ashes of failure

**🏦 JPMorgan Chase** - Handles 45 billion attacks annually
- **Scale:** 1,000+ security incidents per day
- **Response time:** Average 8 minutes from detection to containment³
- **Team:** 3,000+ cybersecurity professionals
- **Investment:** $15 billion annually in security
- **Secret:** Automated response for 95% of incidents

**💻 Microsoft** - Learned from massive Exchange hack (2021)
- **Incident:** 30,000+ organizations compromised by nation-state actors
- **Response:** Coordinated global response, patches within 48 hours⁴
- **Innovation:** AI-powered threat detection and response
- **Result:** 99.9% of similar attacks now blocked automatically

### The Cost of Poor Incident Response
- **💸 Average cost:** $10.93M per incident (2023)⁵
- **⏰ Time factor:** Each day of breach adds $1M in costs⁶
- **📉 Reputation:** 65% of customers lose trust after breach⁷
- **📊 Recovery:** 18 months average to restore reputation⁸
- **😱 Repeat attacks:** 27% of breached companies get hit again⁹

*¹Sony 2011 Annual Report | ²Sony Security Blog 2023 | ³JPMorgan Security Report | ⁴Microsoft Security Response | ⁵IBM Cost of Data Breach 2023 | ⁶Ponemon Institute | ⁷PwC Consumer Trust Survey | ⁸Deloitte Reputation Recovery | ⁹Accenture Security Report*

## 😱 The Equifax Disaster - How NOT to Respond

### The $4 Billion Lesson (2017)
- **💥 Impact:** 147 million Americans' data stolen
- **🕳️ Discovery:** Breach discovered 76 days after it started
- **😱 Response failures:**
  - Executives sold stock before disclosure
  - Waited 6 weeks to notify public
  - Website crashed during breach notification
  - Offered inadequate credit monitoring
- **💰 Total cost:** $4+ billion in fines, settlements, and remediation¹⁰
- **⚖️ Legal consequences:** CEO resigned, executives faced criminal charges

### What Good Incident Response Looks Like
```
❌ Equifax Response:
- 76 days to discover breach
- 6 weeks to notify public
- Executives sold stock first
- Blamed single employee
- No clear communication plan

✅ Best Practice Response:
- Detect within hours (automated monitoring)
- Contain within minutes (automated response)
- Notify authorities within 72 hours (GDPR requirement)
- Transparent public communication
- Learn and improve (blameless postmortem)
```

*¹⁰SEC Equifax Settlement Documents*

## 🔍 Security Incident Detection - The SIEM Approach

### Why Detection Speed Matters
- **⏱️ Golden hour:** First hour determines incident impact
- **📈 Cost escalation:** Each day adds $1M+ in damages
- **🔄 Lateral movement:** Attackers spread in 1-7 days
- **📊 Detection gap:** Average 277 days to find breach

### Production Security Monitoring Stack
```yaml
# Complete security monitoring with ELK + Prometheus
apiVersion: v1
kind: ConfigMap
metadata:
  name: security-monitoring-config
data:
  # Elasticsearch for log analysis
  elasticsearch.yml: |
    cluster.name: security-cluster
    network.host: 0.0.0.0
    discovery.type: single-node
    xpack.security.enabled: true
    xpack.monitoring.enabled: true
  
  # Logstash for log processing
  logstash.conf: |
    input {
      beats {
        port => 5044
      }
    }
    
    filter {
      # Parse authentication logs
      if [fields][log_type] == "auth" {
        grok {
          match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{WORD:auth_result} %{IP:source_ip} %{WORD:username}" }
        }
        
        # Enrich with GeoIP
        geoip {
          source => "source_ip"
          target => "geoip"
        }
        
        # Calculate risk score
        ruby {
          code => "
            risk_score = 0
            risk_score += 50 if event.get('auth_result') == 'FAILED'
            risk_score += 30 if event.get('geoip')['country_code2'] != 'US'
            risk_score += 20 if event.get('source_ip').start_with?('10.') == false
            event.set('risk_score', risk_score)
          "
        }
      }
      
      # Parse application logs
      if [fields][log_type] == "application" {
        json {
          source => "message"
        }
        
        # Detect SQL injection attempts
        if [request_path] =~ /.*('|(\-\-)|(;)|(\|)|(\*)|(%)|(union)|(select)|(insert)|(delete)|(update)|(drop)|(create)|(alter)).*/i {
          mutate {
            add_field => { "security_alert" => "sql_injection_attempt" }
            add_field => { "risk_score" => "90" }
          }
        }
        
        # Detect XSS attempts
        if [request_body] =~ /.*(<script|javascript:|onload=|onerror=).*/i {
          mutate {
            add_field => { "security_alert" => "xss_attempt" }
            add_field => { "risk_score" => "85" }
          }
        }
      }
    }
    
    output {
      elasticsearch {
        hosts => ["elasticsearch:9200"]
        index => "security-logs-%{+YYYY.MM.dd}"
      }
      
      # Send high-risk events to alerting
      if [risk_score] and [risk_score] > 70 {
        http {
          url => "http://alertmanager:9093/api/v1/alerts"
          http_method => "post"
          format => "json"
          mapping => {
            "alerts" => [{
              "labels" => {
                "alertname" => "%{security_alert}",
                "severity" => "critical",
                "source_ip" => "%{source_ip}",
                "risk_score" => "%{risk_score}"
              },
              "annotations" => {
                "summary" => "Security incident detected",
                "description" => "%{message}"
              }
            }]
          }
        }
      }
    }

---
# Advanced Prometheus security alerts
apiVersion: v1
kind: ConfigMap
metadata:
  name: security-alerts
data:
  security-rules.yml: |
    groups:
    - name: authentication_security
      rules:
      # Brute force detection
      - alert: BruteForceAttack
        expr: |
          (
            rate(auth_failed_total[5m]) > 10
          ) and (
            rate(auth_failed_total[1h]) > 100
          )
        for: 2m
        labels:
          severity: critical
          category: authentication
        annotations:
          summary: "Brute force attack detected from {{ $labels.source_ip }}"
          description: "{{ $value }} failed login attempts per second from {{ $labels.source_ip }}"
          runbook: "https://wiki.company.com/security/brute-force-response"
      
      # Credential stuffing
      - alert: CredentialStuffing
        expr: |
          (
            count by (source_ip) (rate(auth_failed_total[10m]) > 1)
          ) > 50
        for: 5m
        labels:
          severity: high
          category: authentication
        annotations:
          summary: "Credential stuffing attack from {{ $labels.source_ip }}"
          description: "Multiple accounts targeted from single IP: {{ $labels.source_ip }}"
      
      # Impossible travel
      - alert: ImpossibleTravel
        expr: |
          (
            auth_success_total{country!="US"} > 0
          ) and on (user_id) (
            auth_success_total{country="US"} offset 1h > 0
          )
        for: 0m
        labels:
          severity: high
          category: authentication
        annotations:
          summary: "Impossible travel detected for user {{ $labels.user_id }}"
          description: "User logged in from {{ $labels.country }} after recent US login"
    
    - name: application_security
      rules:
      # SQL injection attempts
      - alert: SQLInjectionAttempt
        expr: rate(http_requests_total{sql_injection="true"}[5m]) > 0
        for: 0m
        labels:
          severity: critical
          category: application
        annotations:
          summary: "SQL injection attempt detected"
          description: "{{ $value }} SQL injection attempts per second from {{ $labels.source_ip }}"
      
      # Unusual API usage
      - alert: APIAbuseDetected
        expr: |
          (
            rate(http_requests_total[5m]) by (source_ip) > 100
          ) and (
            rate(http_requests_total{status_code=~"4.."}[5m]) by (source_ip) > 10
          )
        for: 2m
        labels:
          severity: warning
          category: application
        annotations:
          summary: "API abuse detected from {{ $labels.source_ip }}"
          description: "High request rate with many errors from {{ $labels.source_ip }}"
      
      # Data exfiltration
      - alert: DataExfiltrationSuspected
        expr: |
          (
            rate(http_response_size_bytes[10m]) by (user_id) > 100000000  # 100MB/10min
          ) and (
            rate(http_requests_total{endpoint=~".*export.*|.*download.*"}[10m]) by (user_id) > 10
          )
        for: 5m
        labels:
          severity: critical
          category: data_protection
        annotations:
          summary: "Suspected data exfiltration by user {{ $labels.user_id }}"
          description: "User {{ $labels.user_id }} downloading {{ $value }} bytes per second"
    
    - name: infrastructure_security
      rules:
      # Privilege escalation
      - alert: PrivilegeEscalation
        expr: |
          increase(sudo_commands_total[5m]) > 10
        for: 1m
        labels:
          severity: high
          category: infrastructure
        annotations:
          summary: "Privilege escalation detected on {{ $labels.instance }}"
          description: "{{ $value }} sudo commands executed in 5 minutes"
      
      # Unusual network traffic
      - alert: UnusualNetworkTraffic
        expr: |
          (
            rate(network_bytes_sent[5m]) > 1000000000  # 1GB/5min
          ) or (
            rate(network_connections_total{state="established"}[5m]) > 1000
          )
        for: 2m
        labels:
          severity: warning
          category: infrastructure
        annotations:
          summary: "Unusual network activity on {{ $labels.instance }}"
          description: "High network usage: {{ $value }} bytes/sec or connections"
```

### Security Event Correlation Engine
```python
# Advanced security event correlation
import json
import time
from collections import defaultdict, deque
from datetime import datetime, timedelta

class SecurityEventCorrelator:
    def __init__(self, redis_client, alert_manager):
        self.redis = redis_client
        self.alert_manager = alert_manager
        self.event_window = timedelta(minutes=10)
        self.correlation_rules = self.load_correlation_rules()
    
    def process_event(self, event):
        """Process incoming security event and check for correlations"""
        # Store event for correlation
        self.store_event(event)
        
        # Check correlation rules
        correlations = self.check_correlations(event)
        
        # Generate alerts for significant correlations
        for correlation in correlations:
            if correlation['risk_score'] > 80:
                self.generate_incident(correlation)
    
    def check_correlations(self, event):
        """Check event against correlation rules"""
        correlations = []
        
        for rule in self.correlation_rules:
            if self.matches_rule(event, rule):
                correlation = self.evaluate_correlation(event, rule)
                if correlation:
                    correlations.append(correlation)
        
        return correlations
    
    def evaluate_correlation(self, event, rule):
        """Evaluate specific correlation rule"""
        # Get related events from time window
        related_events = self.get_related_events(
            event, 
            rule['time_window'], 
            rule['correlation_fields']
        )
        
        if len(related_events) >= rule['min_events']:
            risk_score = self.calculate_risk_score(related_events, rule)
            
            return {
                'rule_name': rule['name'],
                'events': related_events,
                'risk_score': risk_score,
                'correlation_type': rule['type'],
                'description': rule['description']
            }
        
        return None
    
    def load_correlation_rules(self):
        """Load security correlation rules"""
        return [
            {
                'name': 'coordinated_brute_force',
                'type': 'authentication_attack',
                'description': 'Multiple IPs attacking same account',
                'conditions': {
                    'event_type': 'auth_failed',
                    'min_events': 5,
                    'time_window': timedelta(minutes=5)
                },
                'correlation_fields': ['username'],
                'risk_multiplier': 2.0
            },
            {
                'name': 'lateral_movement',
                'type': 'post_compromise',
                'description': 'Successful login followed by privilege escalation',
                'conditions': {
                    'event_sequence': ['auth_success', 'privilege_escalation'],
                    'time_window': timedelta(minutes=30)
                },
                'correlation_fields': ['source_ip', 'username'],
                'risk_multiplier': 3.0
            },
            {
                'name': 'data_exfiltration_pattern',
                'type': 'data_breach',
                'description': 'Large data access followed by external transfer',
                'conditions': {
                    'event_sequence': ['large_data_access', 'external_transfer'],
                    'time_window': timedelta(hours=1)
                },
                'correlation_fields': ['user_id'],
                'risk_multiplier': 4.0
            }
        ]
    
    def generate_incident(self, correlation):
        """Generate security incident from correlation"""
        incident = {
            'id': f"INC-{int(time.time())}",
            'title': f"Security Incident: {correlation['rule_name']}",
            'description': correlation['description'],
            'severity': self.calculate_severity(correlation['risk_score']),
            'events': correlation['events'],
            'created_at': datetime.utcnow().isoformat(),
            'status': 'open',
            'assigned_to': 'security-team'
        }
        
        # Store incident
        self.redis.setex(
            f"incident:{incident['id']}",
            86400,  # 24 hours
            json.dumps(incident)
        )
        
        # Send alert
        self.alert_manager.send_alert({
            'alertname': 'SecurityIncident',
            'severity': incident['severity'],
            'incident_id': incident['id'],
            'description': incident['description']
        })
        
        return incident

# Usage in security monitoring pipeline
correlator = SecurityEventCorrelator(redis_client, alert_manager)

# Process incoming events
for event in security_event_stream:
    correlator.process_event(event)
```

## 📋 Response Procedures

### Incident Response Playbook
```markdown
## Security Incident Response

### Phase 1: Detection & Analysis (0-15 minutes)
1. Confirm incident is real
2. Assess severity level
3. Notify security team
4. Begin evidence collection

### Phase 2: Containment (15-60 minutes)
1. Isolate affected systems
2. Preserve evidence
3. Implement temporary fixes
4. Notify stakeholders

### Phase 3: Recovery (1-24 hours)
1. Remove threat completely
2. Restore systems from clean backups
3. Monitor for reoccurrence
4. Update security controls
```

## 🎓 What You Learned

- ✅ Security incident detection
- ✅ Response procedures and playbooks
- ✅ Evidence collection and forensics
- ✅ Recovery and lessons learned

---

**🎉 Security section complete!**