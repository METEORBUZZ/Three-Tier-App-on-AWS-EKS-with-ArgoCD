# ☸️ Kubernetes Manifests (CKA / CKAD Architecture Guide)

This directory contains production-grade Kubernetes manifests for the ToDo application, architected to meet **CKA (Certified Kubernetes Administrator)** and **CKAD (Certified Kubernetes Application Developer)** standards.

---

## 🏗️ Architecture Overview

```text
k8s-manifests/
├── namespace.yaml                  # Namespace + Pod Security Standards (PSA)
├── kustomization.yaml              # Kustomize v5 root overlay
├── ingress.yaml                    # Ingress (Prefix & Exact routing via IngressClass)
├── networkpolicies/                # CKA Security Domain: Zero-Trust Network Isolation
│   ├── default-deny.yaml           # Default-deny all incoming traffic
│   ├── frontend-netpol.yaml        # Ingress -> Frontend (port 80) + DNS
│   ├── backend-netpol.yaml         # Ingress & Frontend -> Backend (port 5000)
│   └── mongodb-netpol.yaml         # Backend ONLY -> MongoDB (port 27017)
├── backend/                        # Node.js REST API Workload
│   ├── configmap.yaml              # Non-sensitive runtime environment variables
│   ├── secret.yaml                 # Confidential database credentials
│   ├── deployment.yaml             # HA Deployment, Anti-Affinity, 3 Probes, Non-root
│   ├── service.yaml                # ClusterIP service with named port
│   ├── hpa.yaml                    # HorizontalPodAutoscaler (CPU 70%, Memory 80%)
│   └── pdb.yaml                    # PodDisruptionBudget (minAvailable: 1 for drains)
├── frontend/                       # React (Vite) + Nginx SPA Workload
│   ├── deployment.yaml             # HA Deployment, Anti-Affinity, 3 Probes, Non-root
│   ├── service.yaml                # ClusterIP service
│   ├── hpa.yaml                    # HorizontalPodAutoscaler (2 to 5 replicas)
│   └── pdb.yaml                    # PodDisruptionBudget (minAvailable: 1)
└── mongodb/                        # Database Workload
    ├── pvc.yaml                    # PersistentVolumeClaim (5Gi ReadWriteOnce)
    ├── deployment.yaml             # Single-replica with Recreate strategy
    └── service.yaml                # Headless/ClusterIP database service
```

---

## 🎯 CKA / CKAD Best Practice Checklist

| CKA Domain & Exam Pattern | Implementation Detail | Manifest Location |
| :--- | :--- | :--- |
| **Pod Security Standards (PSA)** | `baseline` enforcement with `restricted` audit warnings | [`namespace.yaml`](file:///Users/apple/Downloads/to_do-app/k8s-manifests/namespace.yaml) |
| **Least Privilege Security** | `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, `capabilities: drop: ["ALL"]`, `seccompProfile: RuntimeDefault` | Backend & Frontend Deployments |
| **Zero-Downtime Rollouts** | `strategy.type: RollingUpdate` with `maxSurge: 1` and `maxUnavailable: 0` | Backend & Frontend Deployments |
| **Tri-Probe Health Architecture** | `startupProbe` (protects slow cold boots) + `livenessProbe` (detects deadlocks) + `readinessProbe` (prevents 502/504 errors) | All Deployments |
| **Graceful Pod Termination** | `preStop` sleep hook (allows kube-proxy endpoint withdrawal) + `terminationGracePeriodSeconds: 30` | Backend & Frontend Deployments |
| **High Availability Scheduling** | `podAntiAffinity` (prevents multiple pods from co-locating on the same worker node) | Backend & Frontend Deployments |
| **Zero-Trust Network Isolation** | Default-deny ingress + explicit least-privilege East-West traffic allowlists | [`networkpolicies/`](file:///Users/apple/Downloads/to_do-app/k8s-manifests/networkpolicies) |
| **Maintenance Protection** | `PodDisruptionBudget` (`minAvailable: 1`) guarantees availability during `kubectl drain` | [`backend/pdb.yaml`](file:///Users/apple/Downloads/to_do-app/k8s-manifests/backend/pdb.yaml) & [`frontend/pdb.yaml`](file:///Users/apple/Downloads/to_do-app/k8s-manifests/frontend/pdb.yaml) |
| **Elastic Autoscaling** | `HorizontalPodAutoscaler` v2 scaling replicas 2-5 based on CPU & Memory targets | [`backend/hpa.yaml`](file:///Users/apple/Downloads/to_do-app/k8s-manifests/backend/hpa.yaml) & [`frontend/hpa.yaml`](file:///Users/apple/Downloads/to_do-app/k8s-manifests/frontend/hpa.yaml) |
| **Stateful Volume Integrity** | `strategy.type: Recreate` guarantees old pod releases EBS volume before new pod mounts | [`mongodb/deployment.yaml`](file:///Users/apple/Downloads/to_do-app/k8s-manifests/mongodb/deployment.yaml) |

---

## 🚀 Deployment & Operations

### 1. Dry-run validation
```bash
kubectl kustomize k8s-manifests/
```

### 2. Apply all resources to cluster
```bash
kubectl apply -k k8s-manifests/
```

### 3. Verify rollout and status
```bash
# Check pod distribution and health
kubectl get pods -n todo-app -o wide

# Check autoscalers
kubectl get hpa -n todo-app

# Check Pod Disruption Budgets
kubectl get pdb -n todo-app

# Check Network Policies
kubectl get networkpolicy -n todo-app
```
