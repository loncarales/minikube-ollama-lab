# Makefile for Ollama and OpenWebUI deployment on Minikube

# Variables
MINIKUBE_MEMORY ?= 16384m
MINIKUBE_CPUS ?= 4
MINIKUBE_NODES ?= 2
MINIKUBE_DRIVER ?= docker

# Get Minikube IP and format it for the hostname
MINIKUBE_IP = $(shell minikube ip 2>/dev/null | tr '.' '-')
OPENWEBUI_HOST = openwebui-$(MINIKUBE_IP).traefik.me

.PHONY: all clean start stop delete setup-ingress setup-cert-manager deploy-ollama deploy-openwebui verify help

# Default target
all: start setup-ingress setup-cert-manager deploy-ollama deploy-openwebui verify
	@echo "✅ Deployment complete!"
	@echo "🌐 Access OpenWebUI at: https://$(OPENWEBUI_HOST)"

# Help message
help:
	@echo "Ollama and OpenWebUI Deployment Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all                  Complete deployment (default)"
	@echo "  start                Start Minikube with GPU support"
	@echo "  setup-ingress        Enable Ingress addon"
	@echo "  setup-cert-manager   Install cert-manager and configure TLS"
	@echo "  deploy-ollama        Deploy Ollama using Helm"
	@echo "  deploy-openwebui     Deploy OpenWebUI using Helm"
	@echo "  verify               Verify the installation"
	@echo "  stop                 Stop Minikube"
	@echo "  delete               Delete Minikube cluster"
	@echo "  clean                Uninstall all components"
	@echo ""
	@echo "Configuration:"
	@echo "  MINIKUBE_MEMORY      Memory allocation for Minikube (default: ${MINIKUBE_MEMORY})"
	@echo "  MINIKUBE_CPUS        CPU allocation for Minikube (default: ${MINIKUBE_CPUS})"
	@echo "  MINIKUBE_NODES       Number of Minikube nodes (default: ${MINIKUBE_NODES})"
	@echo "  MINIKUBE_DRIVER      Minikube driver (default: ${MINIKUBE_DRIVER})"

# Start Minikube with GPU support
.PHONY: start
start:
	@bash scripts/start.sh $(MINIKUBE_DRIVER) $(MINIKUBE_MEMORY) $(MINIKUBE_CPUS) $(MINIKUBE_NODES)

# Enable Ingress addon
setup-ingress:
	@bash scripts/enable-ingress.sh

# Install cert-manager and configure TLS
setup-cert-manager:
	@bash scripts/setup-cert-manager.sh

# Deploy Ollama using Helm
deploy-ollama:
	@bash scripts/deploy-ollama.sh

# Deploy OpenWebUI using Helm
deploy-openwebui:
	@bash scripts/deploy-openwebui.sh

# Verify the installation
verify:
	@bash scripts/verify-installation.sh

# Stop Minikube
stop:
	@bash scripts/stop-minikube.sh

# Delete Minikube cluster
delete:
	@bash scripts/delete-minikube.sh

# Uninstall all components
clean:
	@bash scripts/clean-up.sh
