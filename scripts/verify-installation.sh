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
