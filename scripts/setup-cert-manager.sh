#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

info "🔒 Installing cert-manager..."
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set crds.enabled=true

info "⏳ Waiting for cert-manager to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager

info "🔑 Creating mkcert CA secret..."
mkcert -install
kubectl create secret tls mkcert-ca-key-pair \
  --key "$(mkcert -CAROOT)/rootCA-key.pem" \
  --cert "$(mkcert -CAROOT)/rootCA.pem" \
  -n cert-manager --dry-run=client -o yaml | kubectl apply -f -

info "📄 Creating ClusterIssuer..."
kubectl apply -f mkcert-cluster-issuer.yaml
success "✅ cert-manager setup complete"
