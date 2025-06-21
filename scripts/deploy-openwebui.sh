#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

# Check if this is macOS or Windows
if ! is_linux; then
  warn "⚠️ You'll need to open minikube tunnel in a separate terminal to expose nginx ingress controller."
  # Use 127.0.0.1 for macOS | Windows as minikube ip as Docker is running in a VM
  MINIKUBE_IP="127.0.0.1"

else
  MINIKUBE_IP=$(minikube ip 2>/dev/null | tr '.' '-')
fi

OPENWEBUI_HOST=openwebui-${MINIKUBE_IP}.traefik.me

info "🖥️  Deploying OpenWebUI..."
info "📝 Updating OpenWebUI values with IP: ${MINIKUBE_IP}"
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
