# Jenkins CI/CD Pipeline Setup

This directory contains the declarative `Jenkinsfile` for automating the build, testing, vulnerability scanning, containerization, and deployment of the To-Do application to AWS EKS.

---

## Pipeline Stages

1. **Checkout Code**: Clones the Git repository and checks out the target branch.
2. **Backend CI**: Runs `npm ci`, `npm run lint` (ESLint), and `npm test` (Jest + Supertest).
3. **Frontend CI**: Runs `npm ci`, `npm run lint`, and `npm run build` (Vite production bundle).
4. **Security & Vulnerability Scan**: Scans repo files and dependencies using Trivy.
5. **Build Docker Images**: Builds multi-stage Docker images for backend and frontend with unique build/commit tags and `latest`.
6. **Scan Docker Images**: Runs container security vulnerability scanning.
7. **Push Docker Images**: Authenticates to Docker Hub / AWS ECR and pushes images.
8. **Deploy to Kubernetes (EKS)**: Configures `kubectl` via AWS CLI, applies manifests using `kustomize`, and verifies rolling rollout status.

---

## Required Jenkins Plugins

Ensure the following plugins are installed in Jenkins (`Manage Jenkins` > `Plugins`):
- **Docker Pipeline** (`docker-workflow`)
- **NodeJS Plugin** (`nodejs`)
- **Credentials Binding Plugin** (`credentials-binding`)
- **AWS Steps / Pipeline AWS Plugin** (`pipeline-aws`)
- **AnsiColor** (`ansicolor`)

---

## Required Jenkins Credentials

Add the following credentials under `Manage Jenkins` > `Credentials` > `System` > `Global credentials`:

1. **`docker-hub-credentials`**:
   - Kind: `Username with password`
   - Scope: `Global`
   - Username: Your Docker Hub username
   - Password / Token: Your Docker Hub Personal Access Token (PAT)

2. **`aws-eks-credentials`**:
   - Kind: `AWS Credentials`
   - Scope: `Global`
   - Access Key ID: IAM user access key with EKS/EC2 permissions
   - Secret Access Key: IAM user secret key

---

## Agent Requirements

The Jenkins runner agent must have the following CLI tools installed:
- `docker` (with socket permission for the `jenkins` user)
- `nodejs` (v18 or v20) and `npm`
- `aws-cli` (v2)
- `kubectl`
- `trivy` (optional, for security scanning)
