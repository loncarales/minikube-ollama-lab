#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

info "🔍 Verifying installation..."
info "📊 Checking pod status..."
kubectl get pods -n ollama
kubectl get pods -n open-webui
info "🌐 Checking ingress..."
kubectl get ingress -n open-webui
info "🔒 Checking certificates..."
kubectl get certificates -n open-webui
success "✅ Verification complete"

success "✅ Deployment complete!"

# Check if this is macOS or Windows
if ! is_linux; then
  warn "⚠️ You'll need to open minikube tunnel in a separate terminal to expose nginx ingress controller."
  # Use 127.0.0.1 for macOS | Windows as minikube ip as Docker is running in a VM
  MINIKUBE_IP="127.0.0.1"

else
  MINIKUBE_IP=$(minikube ip 2>/dev/null | tr '.' '-')
fi

OPENWEBUI_HOST=openwebui-${MINIKUBE_IP}.traefik.me
info "🌐 Access OpenWebUI at: https://${OPENWEBUI_HOST}"
