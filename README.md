# Production-Ready DevOps To-Do Application

A clean, production-ready, DevOps-friendly To-Do application engineered specifically as a reference workload for **Terraform (AWS EKS), Jenkins CI/CD, Kubernetes (K8s Manifests + Kustomize), GitOps (ArgoCD/Flux), and Prometheus/Grafana Monitoring**.

---

## Architecture Overview

```
                          +------------------------+
                          |   Browser / Ingress    |
                          +-----------+------------+
                                      |
                             Port 80  | (HTTP)
                                      v
                          +------------------------+
                          |   Frontend Container   |
                          | (React + Vite + Nginx) |
                          +-----------+------------+
                                      |
                           Port 5000  | REST API (/api/tasks)
                                      v
+-----------------------+ +------------------------+ +-----------------------+
| Prometheus / Grafana  |<|   Backend Container    |>|  Kubernetes Probes    |
|   (GET /metrics)      | |  (Node.js + Express)   | |    (GET /health)      |
+-----------------------+ +-----------+------------+ +-----------------------+
                                      |
                          Port 27017  | Mongoose ODM
                                      v
                          +------------------------+
                          |   MongoDB Database     |
                          | (Persistent Volume)    |
                          +------------------------+
```

---

## Project Structure

```text
todo-app/
├── .dockerignore
├── .env.example
├── .gitignore
├── docker-compose.yml
├── README.md
├── backend/                     # Node.js + Express API
│   ├── Dockerfile
│   ├── package.json
│   ├── src/
│   │   ├── app.js               # Express app & middleware setup
│   │   ├── index.js             # Server listener & DB lifecycle
│   │   ├── config/db.js         # Mongoose connection
│   │   ├── middleware/          # Prometheus metrics & error handler
│   │   ├── models/Task.js       # Task Mongoose schema
│   │   └── routes/              # /api/tasks, /health, /metrics
│   └── tests/tasks.test.js      # Unit & API tests (Jest + Supertest)
├── frontend/                    # React (Vite) Single Page App
│   ├── Dockerfile               # Multi-stage build + Nginx serve
│   ├── nginx.conf               # SPA routing & caching
│   ├── package.json
│   └── src/                     # Components, API client, styles
├── terraform/                   # AWS Infrastructure as Code (3-Stage EKS + VPC)
│   ├── dev/                     # Stage 1: Development (VPC + EKS)
│   ├── stage/                   # Stage 2: Staging (VPC + EKS)
│   ├── prod/                    # Stage 3: Production (Multi-AZ VPC + EKS)
│   ├── modules/                 # Reusable VPC & EKS blueprints
│   └── README.md
├── k8s-manifests/               # Kubernetes Manifests (CKA & Production Grade)
│   ├── namespace.yaml           # Namespace with Pod Security Standards (PSA)
│   ├── kustomization.yaml       # Kustomize v5 root overlay
│   ├── ingress.yaml             # Ingress with IngressClassName & path routing
│   ├── networkpolicies/         # Zero-Trust NetworkPolicies (Default Deny, Backend, Frontend, Mongo)
│   ├── mongodb/                 # PVC, Recreate Deployment, Service
│   ├── backend/                 # ConfigMap, Secret, Deployment, Service, HPA, PDB
│   ├── frontend/                # Deployment, Service, HPA, PDB
│   └── README.md                # CKA architecture & best practices guide
├── .github/workflows/          # CI Automation (GitHub Actions)
│   └── ci.yml                   # Build, Test, Security Scan, Push & GitOps tag update
├── argocd/                      # CD Automation (ArgoCD GitOps)
│   ├── application.yaml         # ArgoCD Application definition (Auto-Sync)
│   ├── install-argocd.sh        # Automated ArgoCD setup script
│   └── README.md                # GitOps continuous delivery guide
└── monitoring/                  # Prometheus & Grafana Observability
    ├── servicemonitor.yaml      # Prometheus Operator ServiceMonitor
    ├── prometheus-rules.yaml    # Alert rules (Down, 5xx rate, High latency)
    ├── prometheus-values.yaml   # Helm values for kube-prometheus-stack
    ├── grafana-dashboard.json   # Ready-to-import Grafana dashboard
    └── README.md                # Monitoring setup guide
```

---

## REST API Endpoints

| Method | Endpoint | Description | Request Body | Status Codes |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/health` | Kubernetes Liveness & Readiness probe | None | `200` |
| `GET` | `/metrics` | Prometheus metrics scrape endpoint | None | `200` |
| `GET` | `/api/tasks` | Get all tasks (optional `?status=active\|completed`) | None | `200`, `500` |
| `POST` | `/api/tasks` | Create a new task | `{"title": "string"}` | `201`, `400`, `500` |
| `PUT` | `/api/tasks/:id` | Update task title or status | `{"title"?: "string", "completed"?: boolean}` | `200`, `400`, `404`, `500` |
| `DELETE` | `/api/tasks/:id` | Delete a task | None | `200`, `400`, `404`, `500` |

---

## Environment Variables

### Backend (`backend/.env`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `PORT` | Port for Express server | `5000` |
| `NODE_ENV` | Runtime environment (`development`, `production`, `test`) | `development` |
| `MONGO_URI` | MongoDB connection string | `mongodb://localhost:27017/todo-db` |
| `CORS_ORIGIN` | Allowed CORS origins (`*` or comma-separated URLs) | `http://localhost:5173` |

### Frontend (`frontend/.env`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `VITE_API_URL` | Base URL of backend REST API | `http://localhost:5000` |

---

## Quick Start: Local Development

### 1. Run with Docker Compose (Entire Stack)
```bash
docker compose up --build -d
```
- **Frontend UI**: [http://localhost](http://localhost)
- **Backend API**: [http://localhost:5000/api/tasks](http://localhost:5000/api/tasks)
- **Health Check**: [http://localhost:5000/health](http://localhost:5000/health)
- **Prometheus Metrics**: [http://localhost:5000/metrics](http://localhost:5000/metrics)

To stop:
```bash
docker compose down -v
```

### 2. Run Locally (Without Docker)
```bash
# Start MongoDB (if not running)
docker run -d -p 27017:27017 --name local-mongo mongo:7.0

# Backend
cd backend
npm install
npm run dev

# Frontend (in another terminal)
cd frontend
npm install
npm run dev
```

### 3. Run Tests & Linting
```bash
# Backend unit & integration tests with Jest & Supertest
cd backend
npm test
npm run lint

# Frontend linting & build
cd ../frontend
npm run lint
npm run build
```

---

## DevOps Infrastructure & Deployment

### 1. Provision Infrastructure with Terraform (Dev, Stage, Prod)
Choose the stage to provision (`dev`, `stage`, or `prod`):
```bash
cd terraform/dev
# or: cd terraform/stage, cd terraform/prod

terraform init
terraform plan
terraform apply
```
Update your local kubeconfig for the target cluster:
```bash
# For Dev:
aws eks update-kubeconfig --region us-east-1 --name todo-dev-eks-cluster

# For Stage:
# aws eks update-kubeconfig --region us-east-1 --name todo-stage-eks-cluster

# For Prod:
# aws eks update-kubeconfig --region us-east-1 --name todo-prod-eks-cluster
```

### 2. Deploy to Kubernetes with Kustomize
```bash
# Deploy MongoDB, Backend, Frontend, Ingress, and Namespace
kubectl apply -k k8s-manifests/

# Verify rollout status
kubectl get pods -n todo-app
kubectl rollout status deployment/todo-backend -n todo-app
kubectl rollout status deployment/todo-frontend -n todo-app
```

### 3. Setup CI/CD with GitHub Actions & ArgoCD
1. **GitHub Actions (CI):**
   - Add your Docker Hub credentials in GitHub repo settings (**Settings > Secrets and variables > Actions**):
     - `DOCKERHUB_USERNAME`: your Docker Hub username
     - `DOCKERHUB_TOKEN`: your Docker Hub Personal Access Token
   - On every push to `main`, `.github/workflows/ci.yml` tests backend & frontend, runs Trivy security scans, builds Docker images, and automatically updates image tags in `k8s-manifests/kustomization.yaml`.

2. **ArgoCD (CD):**
   - Install ArgoCD and register the GitOps application:
     ```bash
     ./argocd/install-argocd.sh
     ```
   - ArgoCD automatically detects updated manifests pushed to Git and synchronizes new deployments to the EKS cluster with zero downtime!

### 4. Deploy Monitoring (Prometheus & Grafana)
```bash
# Install Prometheus & Grafana stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f monitoring/prometheus-values.yaml

# Apply ServiceMonitor and Alert rules
kubectl apply -f monitoring/servicemonitor.yaml
kubectl apply -f monitoring/prometheus-rules.yaml

# Port-forward Grafana UI
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```
Import `monitoring/grafana-dashboard.json` into Grafana to monitor traffic, latency percentiles, status codes, and Node.js runtime memory.
# Three-Tier-App-on-AWS-EKS-with-ArgoCD
