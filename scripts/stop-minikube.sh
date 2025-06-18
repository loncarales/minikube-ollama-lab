#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

info "⏹️  Stopping Minikube..."
minikube stop
success "✅ Minikube stopped"
