#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

info "🧠 Deploying Ollama..."
helm repo add otwld https://helm.otwld.com/
helm repo update
helm upgrade --install ollama otwld/ollama \
  --namespace ollama --create-namespace \
  -f ollama-values.yaml

info "⏳ Waiting for Ollama to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/ollama -n ollama
success "✅ Ollama deployed successfully"
