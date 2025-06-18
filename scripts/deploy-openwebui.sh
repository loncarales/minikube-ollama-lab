#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

MINIKUBE_IP=$(minikube ip 2>/dev/null | tr '.' '-')
OPENWEBUI_HOST=openwebui-${MINIKUBE_IP}.traefik.me

info "🖥️  Deploying OpenWebUI..."
info "📝 Updating OpenWebUI values with Minikube IP: ${MINIKUBE_IP}"
sed -i.bak "s/openwebui-.*\.traefik\.me/${OPENWEBUI_HOST}/" open-webui-values.yaml
info "🔗 Setting OpenWebUI host to ${OPENWEBUI_HOST}"

helm repo add open-webui https://open-webui.github.io/helm-charts
helm repo update

# Check if statefulset already exists

helm upgrade --install open-webui open-webui/open-webui \
  --namespace open-webui --create-namespace \
  -f open-webui-values.yaml
info "⏳ Waiting for OpenWebUI to be ready..."
kubectl rollout status statefulset/open-webui -n open-webui --timeout=300s
success "✅ OpenWebUI deployed successfully"
