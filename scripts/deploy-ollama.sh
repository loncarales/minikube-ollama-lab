#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

info "🧠 Deploying Ollama..."
helm repo add otwld https://helm.otwld.com/
helm repo update

# Check if the GPU is enabled in docker
if check_gpu_support; then
    info "✅ GPU support is enabled in Docker. Deploying Ollama with GPU support."
    # Replace enabled: XXXX with enabled: true in ollama-values.yaml
    sed -i.bak "s/enabled: XXXX/enabled: true/g" ollama-values.yaml
else
    warn "⚠️ GPU support is not enabled in Docker. Deploying Ollama without GPU support."
    # Replace enabled: XXXX with enabled: false in ollama-values.yaml
    sed -i.bak "s/enabled: XXXX/enabled: false/g" ollama-values.yaml
fi

helm upgrade --install ollama otwld/ollama \
  --namespace ollama --create-namespace \
  -f ollama-values.yaml

info "⏳ Waiting for Ollama to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/ollama -n ollama
success "✅ Ollama deployed successfully"
