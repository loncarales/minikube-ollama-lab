#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

info "🧹 Cleaning up..."
info "🗑️  Uninstalling OpenWebUI..."
# Check if release exists before attempting to uninstall
if helm list -n open-webui | grep -q open-webui; then
  helm uninstall open-webui -n open-webui
else
  warn "OpenWebUI release not found, skipping uninstallation."
fi

info "🗑️  Uninstalling Ollama..."
# Check if release exists before attempting to uninstall
if helm list -n ollama | grep -q ollama; then
  helm uninstall ollama -n ollama
else
  warn "Ollama release not found, skipping uninstallation."
fi

info "🗑️  Uninstalling cert-manager..."
# Check if release exists before attempting to uninstall
if helm list -n cert-manager | grep -q cert-manager; then
  helm uninstall cert-manager -n cert-manager
else
  warn "Cert-manager release not found, skipping uninstallation."
fi

info "🗑️  Deleting namespaces..."
kubectl delete namespace ollama open-webui cert-manager
success "✅ Cleanup complete"
