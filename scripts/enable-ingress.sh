#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

info "🌐 Enabling Ingress addon..."
minikube addons enable ingress
success "✅ Ingress addon enabled"
