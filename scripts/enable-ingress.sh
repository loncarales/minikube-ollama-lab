#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

info "🌐 Enabling Ingress addon..."
minikube addons enable ingress
success "✅ Ingress addon enabled"

# If this is macOS or Windows, we need to patch the ingress controller for type LoadBalancer
if ! is_linux; then
    info "🔧 Patching Ingress controller for non-Linux systems..."
    kubectl patch svc ingress-nginx-controller -n ingress-nginx  \
        -p '{"spec": {"type": "LoadBalancer"}}'
    success "✅ Ingress controller patched for non-Linux systems"
fi
