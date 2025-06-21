#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

# Read the parameters from the command line
MINIKUBE_DRIVER=${1:-"docker"}           # First parameter, defaults to docker
MINIKUBE_MEMORY=${2:-"16384m"}           # Second parameter, defaults to 16384 MB
MINIKUBE_CPUS=${3:-"4"}                  # Third parameter, defaults to 4 CPUs
MINIKUBE_NODES=${4:-"2"}                 # Fourth parameter, defaults to 2 node

if [[ ! "$MINIKUBE_CPUS" =~ ^[0-9]+$ ]]; then
    echo "Error: CPUs must be a number"
    exit 0
fi

if [[ ! "$MINIKUBE_NODES" =~ ^[0-9]+$ ]]; then
    echo "Error: Nodes must be a number"
    exit 0
fi

# Print the configuration
echo "📋 Configuration:"
echo "Driver: $MINIKUBE_DRIVER"
echo "Memory: $MINIKUBE_MEMORY MB"
echo "CPUs: $MINIKUBE_CPUS"
echo "Nodes: $MINIKUBE_NODES"

# Check if Minikube is already running
if minikube status &>/dev/null; then
    warn "⚠️ Minikube is already running. Please stop it first."
    exit 0
fi

# Check if the GPU is enabled in docker
if check_gpu_support; then
    info "✅ GPU support is enabled in Docker. Running Minikube with GPU support."
    GPU_SUPPORT="--gpus=all"
else
    warn "⚠️ GPU support is not enabled in Docker. Running Minikube without GPU support."
    GPU_SUPPORT=""
fi

info "🚀 Starting Minikube with GPU support..."
minikube start --driver="$MINIKUBE_DRIVER" --memory="$MINIKUBE_MEMORY" --cpus="$MINIKUBE_CPUS" --nodes="$MINIKUBE_NODES" $GPU_SUPPORT --wait=all
success "✅ Minikube started successfully"
success "🖥️  Minikube IP: $(minikube ip)"
