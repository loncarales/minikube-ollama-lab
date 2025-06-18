#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

warn "🗑️  Deleting Minikube cluster..."
minikube delete
success "✅ Minikube deleted"

