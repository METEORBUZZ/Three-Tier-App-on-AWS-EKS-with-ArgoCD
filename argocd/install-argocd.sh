#!/usr/bin/env bash
# ==============================================================================
# ARGOCD INSTALLATION & SETUP SCRIPT
# ==============================================================================
# This script installs ArgoCD on your AWS EKS cluster, configures access,
# and outputs the initial admin password.
# ==============================================================================
set -euo pipefail

echo "=========================================================="
echo "🚀 1. Creating 'argocd' Namespace..."
echo "=========================================================="
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "=========================================================="
echo "📦 2. Installing Official ArgoCD Manifests..."
echo "=========================================================="
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=========================================================="
echo "⏳ 3. Waiting for ArgoCD Server to become Ready..."
echo "=========================================================="
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s

echo "=========================================================="
echo "🎯 4. Registering To-Do App GitOps Application..."
echo "=========================================================="
kubectl apply -f "$(dirname "$0")/application.yaml"

echo "=========================================================="
echo "🔑 5. Retrieving Initial Admin Password..."
echo "=========================================================="
ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "✅ ArgoCD successfully installed and configured!"
echo "----------------------------------------------------------"
echo "Username: admin"
echo "Password: ${ADMIN_PASSWORD}"
echo "----------------------------------------------------------"
echo ""
echo "To access the ArgoCD Web Dashboard locally, run:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "Then open in your browser: https://localhost:8080"
echo "=========================================================="
