# Prometheus Alerting Helm Chart

A production-ready Helm chart for deploying Prometheus and AlertManager with SRE-focused, actionable alerting on Kubernetes.

##  Why Helm Chart Over Raw Manifests?

###  **Major Advantages**

| Feature | Raw Manifests | Helm Chart |
|---------|---------------|------------|
| **Deployment** | Multiple `kubectl apply` commands | Single `helm install` command |
| **Configuration** | Edit multiple YAML files | One `values.yaml` file |
| **Upgrades** | Manual kubectl operations | `helm upgrade` |
| **Rollback** | Manual recreation | `helm rollback` in seconds |
| **Versioning** | Git tags | Built-in chart versioning |
| **Templating** | Copy-paste for each env | Reusable templates |
| **Package Distribution** | Share entire directory | Single `.tgz` package |
| **Dependencies** | Manual management | Automatic via Chart.yaml |
| **Validation** | Manual YAML checks | `helm lint` and testing |
| **Documentation** | Separate README | Built-in `helm show` |

### **Real-World Benefits**

**Before (Manifests)**:

# Deploy to production
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-prometheus-configmap.yaml
kubectl apply -f 02-prometheus-rules-configmap.yaml
kubectl apply -f 03-alertmanager-configmap.yaml
kubectl apply -f 04-prometheus-rbac.yaml
kubectl apply -f 05-prometheus-deployment.yaml
kubectl apply -f 06-alertmanager-deployment.yaml

# Now deploy to staging with different values?
# Copy all files, edit each one manually, apply again...


**After (Helm)**:

# Deploy to production
helm install prometheus-prod ./prometheus-alerting -f values-prod.yaml

# Deploy to staging with different config
helm install prometheus-staging ./prometheus-alerting -f values-staging.yaml

# Upgrade
helm upgrade prometheus-prod ./prometheus-alerting

# Rollback instantly if something breaks
helm rollback prometheus-prod


##  Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Configuration](#configuration)
- [Upgrading](#upgrading)
- [Uninstallation](#uninstallation)
- [Advanced Usage](#advanced-usage)
- [Multi-Environment Setup](#multi-environment-setup)
- [Troubleshooting](#troubleshooting)

##  Prerequisites

### Required

1. **Kubernetes Cluster** (v1.20+)

   kubectl version --short


2. **Helm 3** installed

   # Install Helm on Linux/Mac
   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   
   # Verify installation
   helm version


3. **kubectl** configured with cluster access

   kubectl cluster-info


4. **Cluster Admin Permissions**
 
   kubectl auth can-i create clusterrole
   # Should return "yes"


### Optional

5. **Slack Webhook** for notifications
6. **PagerDuty** integration keys
7. **Ingress Controller** (nginx, traefik) for external access

### Verify Prerequisites


# Check Helm
helm version --short

# Check Kubernetes access
kubectl get nodes

# Check if you can create namespaces
kubectl auth can-i create namespace

# List available storage classes
kubectl get storageclass


## Quick Start

### 1. Clone the Repository


git clone https://github.com/akashyadavv1711/RFE-assignment.git
cd prometheus-alerting


### 2. Install with Default Values


# Create namespace
kubectl create namespace monitoring

# Install the chart
helm install prometheus ./prometheus-alerting \
  --namespace monitoring \
  --create-namespace


### 3. Access Prometheus


# Port-forward
kubectl port-forward -n monitoring svc/prometheus-prometheus-alerting 9090:9090

# Open browser
open http://localhost:9090


That's it! You now have Prometheus and AlertManager running.

## Installation

### Method 1: Install from Local Chart


# Basic installation
helm install prometheus ./prometheus-alerting \
  --namespace monitoring \
  --create-namespace

# With custom values file
helm install prometheus ./prometheus-alerting \
  --namespace monitoring \
  --create-namespace \
  --values values.yaml

# With inline value overrides
helm install prometheus ./prometheus-alerting \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.service.type=LoadBalancer \
  --set alertmanager.enabled=true


### Method 2: Install from Package


# Package the chart
helm package prometheus-alerting

# Install from package
helm install prometheus prometheus-alerting-1.0.0.tgz \
  --namespace monitoring \
  --create-namespace


### Method 3: Install from Helm Repository (Future)


# Add repository
helm repo add my-charts https://charts.example.com

# Update repository
helm repo update

# Install
helm install prometheus my-charts/prometheus-alerting \
  --namespace monitoring \
  --create-namespace


### Installation with Credentials

**Create a values file** (`values.yaml`):


alertmanager:
  config:
    global:
      slack_api_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
    
    receivers:
      pagerduty:
        enabled: true
        serviceKey: "your-pagerduty-service-key"
        routingKey: "your-pagerduty-routing-key"


**Install**:


helm install prometheus ./prometheus-alerting \
  --namespace monitoring \
  --create-namespace \
  --values my-values.yaml


**Or use --set flags**:


helm install prometheus ./prometheus-alerting \
  --namespace monitoring \
  --create-namespace \
  --set alertmanager.config.global.slack_api_url="https://hooks.slack.com/..." \
  --set alertmanager.config.receivers.pagerduty.serviceKey="your-key"


### Verify Installation


# Check deployment status
helm status prometheus -n monitoring

# List all releases
helm list -n monitoring

# Get all resources
kubectl get all -n monitoring

# Check pods are running
kubectl get pods -n monitoring -w


## Configuration

### Key Configuration Options

The chart can be configured via `values.yaml`. Here are the most important options:

#### Prometheus Configuration


prometheus:
  # Enable/disable Prometheus
  enabled: true
  
  # Image configuration
  image:
    repository: prom/prometheus
    tag: v2.48.0
  
  # Resource limits
  resources:
    requests:
      memory: "512Mi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "2000m"
  
  # Persistent storage
  persistence:
    enabled: true
    size: 10Gi
    storageClass: ""  # Use default
  
  # Service type (ClusterIP, NodePort, LoadBalancer)
  service:
    type: NodePort
    nodePort: 30090
  
  # Ingress
  ingress:
    enabled: true
    hosts:
      - host: prometheus.example.com


#### AlertManager Configuration


alertmanager:
  enabled: true
  
  # Notification channels
  config:
    global:
      slack_api_url: "YOUR_SLACK_WEBHOOK"
    
    receivers:
      slack:
        critical:
          enabled: true
          channel: '#alerts-critical'
        warnings:
          enabled: true
          channel: '#alerts-warnings'
      
      pagerduty:
        enabled: true
        serviceKey: "YOUR_PAGERDUTY_KEY"


#### Alert Rules Configuration


alertRules:
  # Application alerts
  application:
    highErrorRate:
      enabled: true
      threshold: 1  # percentage
      duration: 5m
    
    highLatency:
      enabled: true
      threshold: 0.5  # seconds
      duration: 5m
  
  # Kubernetes alerts
  kubernetes:
    podDown:
      enabled: true
      duration: 2m


### Common Configuration Scenarios

#### 1. Production Setup with LoadBalancer


# values-prod.yaml
global:
  environment: production
  clusterName: prod-cluster

prometheus:
  service:
    type: LoadBalancer
  persistence:
    size: 50Gi
  resources:
    requests:
      memory: "2Gi"
      cpu: "1000m"
    limits:
      memory: "8Gi"
      cpu: "4000m"
  retention:
    time: 30d

alertmanager:
  config:
    global:
      slack_api_url: "https://hooks.slack.com/services/PROD/WEBHOOK"
    receivers:
      pagerduty:
        enabled: true
        serviceKey: "prod-pagerduty-key"


Install:

helm install prometheus ./prometheus-alerting \
  -n monitoring \
  --values values-prod.yaml


#### 2. Development Setup (Minimal Resources)


# values-dev.yaml
global:
  environment: development
  clusterName: dev-cluster

prometheus:
  service:
    type: NodePort
  persistence:
    enabled: false  # Use emptyDir
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  retention:
    time: 3d

alertmanager:
  enabled: false  # Disable in dev


#### 3. Enable Ingress with TLS


# values-ingress.yaml
prometheus:
  ingress:
    enabled: true
    className: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - host: prometheus.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: prometheus-tls
        hosts:
          - prometheus.yourdomain.com

alertmanager:
  ingress:
    enabled: true
    className: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - host: alertmanager.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: alertmanager-tls
        hosts:
          - alertmanager.yourdomain.com


#### 4. Deploy Sample Application


# Enable sample 3-tier app for testing
sampleApp:
  enabled: true
  
  frontend:
    replicas: 2
  
  api:
    replicas: 3
  
  database:
    replicas: 1
```

### View All Configuration Options

```bash
# Show default values
helm show values ./prometheus-alerting

# Show all chart information
helm show all ./prometheus-alerting

# Show chart README
helm show readme ./prometheus-alerting


## Upgrading

### Simple Upgrade


# Upgrade to latest chart version
helm upgrade prometheus ./prometheus-alerting \
  --namespace monitoring

# Upgrade with new values
helm upgrade prometheus ./prometheus-alerting \
  --namespace monitoring \
  --values new-values.yaml

# Upgrade with inline changes
helm upgrade prometheus ./prometheus-alerting \
  --namespace monitoring \
  --set prometheus.resources.requests.memory=1Gi


### Dry Run (Preview Changes)


# See what would change WITHOUT actually applying
helm upgrade prometheus ./prometheus-alerting \
  --namespace monitoring \
  --values new-values.yaml \
  --dry-run --debug


### Upgrade with Backup


# Get current values
helm get values prometheus -n monitoring > backup-values.yaml

# Upgrade
helm upgrade prometheus ./prometheus-alerting \
  --namespace monitoring \
  --values values.yaml
  
# If something goes wrong, rollback
helm rollback prometheus -n monitoring


### Rollback to Previous Version


# List revision history
helm history prometheus -n monitoring

# Rollback to previous version
helm rollback prometheus -n monitoring

# Rollback to specific revision
helm rollback prometheus 3 -n monitoring


### Force Upgrade (Recreate Pods)


# Force pod recreation
helm upgrade prometheus ./prometheus-alerting \
  --namespace monitoring \
  --recreate-pods


## Uninstallation

### Complete Removal


# Uninstall release
helm uninstall prometheus -n monitoring

# Delete namespace (removes all resources)
kubectl delete namespace monitoring


### Keep Data (PVCs)


# Uninstall but keep PVCs
helm uninstall prometheus -n monitoring

# PVCs remain, allowing data recovery
kubectl get pvc -n monitoring


### Clean Uninstall


# Remove everything including PVCs
helm uninstall prometheus -n monitoring
kubectl delete pvc --all -n monitoring
kubectl delete namespace monitoring


##  Advanced Usage

### Custom Alert Rules

Create `custom-alerts.yaml`:


extraAlertRules:
  - alert: CustomHighTraffic
    expr: rate(http_requests_total[5m]) > 1000
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High traffic detected"
      description: "Traffic is {{ $value }} req/s"


Install with custom alerts:


helm install prometheus ./prometheus-alerting \
  -n monitoring \
  --values custom-alerts.yaml


### Custom Scrape Targets


extraScrapeConfigs:
  - job_name: 'my-custom-service'
    kubernetes_sd_configs:
      - role: pod
        namespaces:
          names:
            - my-namespace
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        action: keep
        regex: my-app


### Use External Secrets

Instead of putting credentials in values.yaml:


# Create secret
kubectl create secret generic alertmanager-credentials \
  --from-literal=slack-webhook="https://hooks.slack.com/..." \
  --from-literal=pagerduty-key="your-key" \
  -n monitoring

# Reference in AlertManager config
# (requires modifying templates to read from secrets)


### Testing the Chart


# Lint the chart
helm lint ./prometheus-alerting

# Test template rendering
helm template prometheus ./prometheus-alerting \
  --values values.yaml \
  --debug

# Install in test mode
helm install prometheus ./prometheus-alerting \
  --namespace monitoring \
  --dry-run --debug


## Multi-Environment Setup

### Directory Structure


environments/
├── dev/
│   └── values-dev.yaml
├── staging/
│   └── values-staging.yaml
└── production/
    └── values-prod.yaml


### Environment-Specific Deployments

**Development**:

helm install prometheus-dev ./prometheus-alerting \
  -n monitoring-dev \
  --create-namespace \
  --values environments/dev/values-dev.yaml


**Staging**:

helm install prometheus-staging ./prometheus-alerting \
  -n monitoring-staging \
  --create-namespace \
  --values environments/staging/values-staging.yaml


**Production**:

helm install prometheus-prod ./prometheus-alerting \
  -n monitoring-prod \
  --create-namespace \
  --values environments/production/values-prod.yaml


### Example: Different Values Per Environment

**environments/dev/values-dev.yaml**:

global:
  environment: development

prometheus:
  persistence:
    enabled: false
  resources:
    requests:
      memory: "256Mi"

alertmanager:
  enabled: false


**environments/prod/values-prod.yaml**:

global:
  environment: production

prometheus:
  persistence:
    enabled: true
    size: 100Gi
  resources:
    requests:
      memory: "4Gi"
  
  service:
    type: LoadBalancer

alertmanager:
  enabled: true
  config:
    receivers:
      pagerduty:
        enabled: true


##  Troubleshooting

### Chart Installation Fails


# Check chart syntax
helm lint ./prometheus-alerting

# Debug template rendering
helm template prometheus ./prometheus-alerting --debug

# Check for typos in values
helm install prometheus ./prometheus-alerting \
  --dry-run --debug | grep -i error


### Pods Not Starting


# Check release status
helm status prometheus -n monitoring

# Get pod details
kubectl describe pod -n monitoring -l app=prometheus

# Check events
kubectl get events -n monitoring --sort-by='.lastTimestamp'


### Upgrade Fails


# See what would change
helm upgrade prometheus ./prometheus-alerting \
  -n monitoring \
  --dry-run --debug

# Force upgrade
helm upgrade prometheus ./prometheus-alerting \
  -n monitoring \
  --force

# Rollback if needed
helm rollback prometheus -n monitoring


### Values Not Applied


# Check what values are currently set
helm get values prometheus -n monitoring

# Check all computed values (including defaults)
helm get values prometheus -n monitoring --all

# Verify specific value
helm get values prometheus -n monitoring -o json | jq '.prometheus.resources'


### Release Stuck in Pending


# Delete pending release
helm delete prometheus -n monitoring

# Force delete if needed
kubectl delete secret -n monitoring -l owner=helm,name=prometheus

# Reinstall
helm install prometheus ./prometheus-alerting -n monitoring


##  Comparison: Manifests vs Helm

### Real Example

**Changing Slack Channel** (Manifests):

# 1. Edit configmap file
vim manifests/03-alertmanager-configmap.yaml
# 2. Find and replace channel name
# 3. Apply changes
kubectl apply -f manifests/03-alertmanager-configmap.yaml
# 4. Restart AlertManager manually
kubectl rollout restart deployment/alertmanager -n monitoring


**Changing Slack Channel** (Helm):

# Single command
helm upgrade prometheus ./prometheus-alerting \
  --set alertmanager.config.receivers.slack.critical.channel='#new-channel' \
  -n monitoring


### Deployment Time

| Task | Manifests | Helm |
|------|-----------|------|
| Initial setup | ~10 minutes | ~2 minutes |
| Change configuration | ~5 minutes | ~30 seconds |
| Deploy to new environment | ~15 minutes | ~2 minutes |
| Rollback after issue | Manual (15+ min) | Instant (1 command) |

## Additional Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Prometheus Helm Charts](https://github.com/prometheus-community/helm-charts)
- [Chart Development Guide](https://helm.sh/docs/chart_template_guide/)

## Contributing

Contributions welcome! To contribute:

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test with `helm lint` and `helm test`
5. Submit pull request


## Quick Commands Reference


# Install
helm install prometheus ./prometheus-alerting -n monitoring --create-namespace

# Upgrade
helm upgrade prometheus ./prometheus-alerting -n monitoring

# Rollback
helm rollback prometheus -n monitoring

# Uninstall
helm uninstall prometheus -n monitoring

# Status
helm status prometheus -n monitoring

# History
helm history prometheus -n monitoring

# Get values
helm get values prometheus -n monitoring

# Access Prometheus
kubectl port-forward -n monitoring svc/prometheus-prometheus-alerting 9090:9090

# Access AlertManager
kubectl port-forward -n monitoring svc/prometheus-prometheus-alerting-alertmanager 9093:9093
