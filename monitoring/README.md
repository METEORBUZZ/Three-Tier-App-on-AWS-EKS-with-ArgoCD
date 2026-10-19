# Monitoring & Observability Setup

This directory contains the Prometheus, Alertmanager, and Grafana configurations for monitoring the To-Do application.

---

## 1. Deploy Prometheus & Grafana (kube-prometheus-stack)

Add the Prometheus Community Helm repository and install the stack:

```bash
# Add repo & update
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install monitoring stack into 'monitoring' namespace
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f monitoring/prometheus-values.yaml
```

---

## 2. Deploy ServiceMonitor & Alert Rules

Apply the ServiceMonitor so Prometheus scrapes the backend's `/metrics` endpoint, and apply custom alert rules:

```bash
# Apply ServiceMonitor
kubectl apply -f monitoring/servicemonitor.yaml

# Apply PrometheusRule alerts
kubectl apply -f monitoring/prometheus-rules.yaml
```

Verify target discovery in Prometheus:
```bash
# Port-forward Prometheus UI
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```
Open [http://localhost:9090/targets](http://localhost:9090/targets) to see `todo-backend-monitor` active.

---

## 3. Access Grafana & Import Dashboard

1. **Port-forward Grafana**:
   ```bash
   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
   ```

2. **Login Credentials**:
   - URL: [http://localhost:3000](http://localhost:3000)
   - Username: `admin`
   - Password: `admin` (or password configured in `prometheus-values.yaml`)

3. **Import Dashboard**:
   - Go to **Dashboards** > **New** > **Import**.
   - Upload or paste the contents of `monitoring/grafana-dashboard.json`.
   - Select the `Prometheus` datasource and click **Import**.

---

## 4. Metrics Monitored

- **HTTP Request Throughput**: Requests per second (RPS) grouped by status code (`2xx`, `4xx`, `5xx`).
- **Latency Distribution**: Quantiles (p50, p95, p99) calculated from `http_request_duration_seconds`.
- **Node.js Memory**: Heap used, total heap allocated, and process resident set size (RSS).
- **Node.js Event Loop Lag**: Delay in seconds tracking event loop blockage.
- **Alerts**:
  - `BackendServiceDown`: Pod unreachable for > 1m (Severity: Critical).
  - `HighHttp5xxErrorRate`: 5xx error rate > 5% over 5m (Severity: Warning).
  - `HighRequestLatency`: P95 latency > 1.0s (Severity: Warning).
