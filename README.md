# LLMs on Minikube: Ollama and OpenWebUI with Ingress & TLS

![Kubernetes](https://img.shields.io/badge/kubernetes-minikube-blue)
![License](https://img.shields.io/badge/license-MIT-green.svg)

This guide will walk you through setting up Ollama and OpenWebUI, and then explain how to configure an Ingress controller.

---

## 🧠 Why This Project?

Running Large Language Models (LLMs) locally with GPU acceleration provides:

- ✅ Privacy and data control for sensitive information
- ✅ Lower latency compared to cloud-based solutions
- ✅ No subscription costs for API usage
- ✅ Full control over model selection and configuration
- ✅ Perfect for development, testing, and learning environments

---

## Table of Contents
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
  - [Automated Deployment](#automated-deployment)
    - [Using the Makefile](#using-the-makefile)
  - [Manual Deployment](#manual-deployment)
    - [Start Minikube](#start-minikube)
    - [Enable Ingress](#enable-ingress)
    - [Install cert-manager](#install-cert-manager)
    - [Ollama Deployment](#ollama-deployment-with-helm)
    - [Open-WebUI Deployment](#open-webui-deployment-with-helm)
- [Accessing the Services](#accessing-the-services)
- [Verifying the Installation](#verifying-the-installation)
- [Testing CUDA in Containers](#testing-cuda-in-containers)
- [Updating and Upgrading](#updating-and-upgrading)
- [Uninstalling and Cleanup](#uninstalling-and-cleanup)
- [Troubleshooting](#troubleshooting)

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed and configured:

- Minikube: Your local Kubernetes cluster.
- kubectl: The Kubernetes command-line tool.
- Helm: The package manager for Kubernetes.
- mkcert: A simple tool for making locally-trusted development certificates.
- NVIDIA Container Toolkit: Properly installed on your system to enable GPU access within containers.
- CUDA Toolkit and cuda-drivers installed

## 🚀 Setup Instructions

You have two options for deploying the project:

1. **Automated Deployment**: Using the provided Makefile
2. **Manual Deployment**: Following the step-by-step instructions

### 🤖 Automated Deployment

#### Using the Makefile

A Makefile is provided to automate the entire deployment process. To use it:

```bash
# Deploy everything with default settings
make

# Or run specific steps
make start           # Start Minikube with GPU support
make setup-ingress   # Enable Ingress addon
make setup-cert-manager # Install cert-manager and configure TLS
make deploy-ollama   # Deploy Ollama
make deploy-openwebui # Deploy OpenWebUI
make verify          # Verify the installation

# To clean up
make clean           # Uninstall all components
make delete          # Delete Minikube cluster

# For help
make help
```

You can customize the Minikube settings by setting variables:

```bash
# Example with custom settings
MINIKUBE_MEMORY=32768m MINIKUBE_CPUS=12 make
```

### 🔄 Manual Deployment

If you prefer to deploy manually, follow these steps:

#### 🖥️ Start Minikube

Start your Minikube cluster with the appropriate GPU flags:

```bash
# First, if you have an existing Minikube cluster, delete it
minikube delete

# Start a new cluster with sufficient resources
minikube start --driver=docker --gpus=all --memory=16384m --cpus=4 --nodes=2 --wait=all
```

By starting your Minikube cluster with these settings, you ensure that the underlying infrastructure is capable of supporting the resource demands of your Kubernetes deployment, preventing scheduling failures and ensuring smooth operation.

#### 🌐 Enable Ingress

Enable the Nginx Ingress controller in Minikube:

```bash
minikube addons enable ingress
```

#### 🔒 Create locally signed SSL certificates with mkcert

Before installing cert-manager, you need to create locally signed SSL certificates using mkcert:

```bash
# Install mkcert if you haven't already
# Generate a local CA and certificates
mkcert -install
```

#### 🛡️ Install cert-manager

To manage TLS certificates in your Kubernetes cluster, you can use cert-manager. This tool automates the management and issuance of TLS certificates.

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set crds.enabled=true
```

Create a Kubernetes Secret with the mkcert CA:

```bash
kubectl create secret tls mkcert-ca-key-pair \
  --key "$(mkcert -CAROOT)/rootCA-key.pem" \
  --cert "$(mkcert -CAROOT)/rootCA.pem" \
  -n cert-manager
```

Create a ClusterIssuer for cert-manager:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: mkcert-cluster-issuer
  namespace: cert-manager
spec:
  ca:
    secretName: mkcert-ca-key-pair
```

#### 🧠 Ollama Deployment with Helm

There's a community-maintained Helm chart that works well for deploying Ollama.

1. Add the Helm Repository:

```bash
helm repo add otwld https://helm.otwld.com/
helm repo update
```

2. Configure `ollama-values.yaml`:

The repository includes an `ollama-values.yaml` file with the necessary configurations.

3. Install Ollama:

```bash
helm upgrade --install ollama otwld/ollama \
  --namespace ollama --create-namespace \
  -f ollama-values.yaml
```

#### 🖥️ Open-WebUI Deployment with Helm

Next, deploy Open-WebUI using Helm. This will allow you to manage the web interface for Ollama.

1. Add the Open-WebUI Helm repository:

```bash
helm repo add open-webui https://open-webui.github.io/helm-charts
helm repo update
```

2. Configure `open-webui-values.yaml`:

Before configuring the open-webui-values.yaml file, you need to determine your minikube IP address, which will be used in the ingress configuration to access the service later:

```bash
minikube ip
```

Make note of this IP address (e.g., 192.168.49.2) as you'll need to include it in the hostname configuration.

The repository includes an `open-webui-values.yaml` file that you may need to update with your Minikube IP.

3. Install Open-WebUI:

```bash
helm upgrade --install open-webui open-webui/open-webui \
  --namespace open-webui --create-namespace \
  -f open-webui-values.yaml
```

## 🌐 Accessing the Services

After deployment, you can access the Open-WebUI service through the configured Ingress:

1. **Access Open-WebUI**: Open your browser and navigate to:
   ```
   https://openwebui-192-168-49-2.traefik.me
   ```

   This hostname automatically resolves to 192.168.49.2 (the IP of minikube) using the free wildcard DNS service traefik.me.

2. **Note about Ollama**: Ollama is not exposed via ingress and is only accessible from within the cluster. Open-WebUI is configured to communicate with Ollama internally.

## ✅ Verifying the Installation

To verify that your installation is working correctly:

1. **Check pod status**:
   ```bash
   kubectl get pods -n ollama
   kubectl get pods -n open-webui
   ```
   All pods should be in the `Running` state.

2. **Verify Ingress**:
   ```bash
   kubectl get ingress -A
   ```
   The ingress resources should have an ADDRESS assigned.

3. **Test Ollama API**:
   ```bash
   kubectl run -it -n ollama --rm debug --image=byrnedo/alpine-curl --restart=Never -- -k http://ollama:11434/api/tags | jq
   ```
   This should return a JSON response with available models.

## 🔥 Testing CUDA in Containers

Testing CUDA functionality is essential when running GPU-accelerated workloads like Ollama. Proper CUDA configuration ensures that your LLM models can leverage GPU acceleration for faster inference. This section provides methods to verify CUDA is working correctly in your containerized environment.

To ensure that CUDA is properly configured and functioning in your containers, follow these steps:

### Basic CUDA Verification

1. **Check NVIDIA Driver and CUDA Version**:
   ```bash
   kubectl exec -it -n ollama $(kubectl get pods -n ollama -l app.kubernetes.io/name=ollama -o name) -- nvidia-smi
   ```
   This command should display information about your GPU, including the NVIDIA driver version and CUDA version.

### Testing CUDA Functionality with Ollama

1. **Run a Simple CUDA Test**:
   ```bash
   kubectl exec -it -n ollama $(kubectl get pods -n ollama -l app.kubernetes.io/name=ollama -o name) -- bash -c "nvidia-smi -q"
   ```
   This provides detailed information about your GPU, including memory usage, utilization, and processes.

2. **Test CUDA with a Model**:
   ```bash
   # Pull a CUDA-compatible model
   kubectl exec -it -n ollama $(kubectl get pods -n ollama -l app.kubernetes.io/name=ollama -o name) -- ollama pull llama2

   # Run a simple inference to test GPU acceleration
   kubectl exec -it -n ollama $(kubectl get pods -n ollama -l app.kubernetes.io/name=ollama -o name) -- bash -c 'echo "Explain quantum computing in simple terms" | ollama run llama2'
   ```

3. **Monitor GPU Usage During Inference**:
   ```bash
   # In a separate terminal, run:
   kubectl exec -it -n ollama $(kubectl get pods -n ollama -l app.kubernetes.io/name=ollama -o name) -- watch -n 0.5 nvidia-smi
   ```
   This will show real-time GPU usage. When running inference with Ollama, you should see GPU utilization increase.

## 🔄 Updating and Upgrading

To update the deployed components:

1. **Update Helm repositories**:
   ```bash
   helm repo update
   ```

2. **Upgrade Ollama**:
   ```bash
   helm upgrade ollama otwld/ollama \
     --namespace ollama \
     -f ollama-values.yaml
   ```

3. **Upgrade Open-WebUI**:
   ```bash
   helm upgrade open-webui open-webui/open-webui \
     --namespace open-webui \
     -f open-webui-values.yaml
   ```

## 🧹 Uninstalling and Cleanup

To remove the deployment and clean up resources:

1. **Uninstall Open-WebUI**:
   ```bash
   helm uninstall open-webui -n open-webui
   ```

2. **Uninstall Ollama**:
   ```bash
   helm uninstall ollama -n ollama
   ```

3. **Remove cert-manager**:
   ```bash
   helm uninstall cert-manager -n cert-manager
   ```

4. **Delete namespaces**:
   ```bash
   kubectl delete namespace ollama open-webui cert-manager
   ```

5. **Stop Minikube** (optional):

> Stop Minikube only if you no longer need the local Kubernetes environment.

   ```bash
   minikube stop
   ```

6. **Delete Minikube cluster** (optional):

> Only run this if you want to completely remove the Minikube environment and all its data.

   ```bash
   minikube delete
   ```

## 🔧 Troubleshooting

### Common Issues

1. **Pods stuck in Pending state**:
   - **Issue**: Insufficient resources allocated to Minikube.
   - **Solution**: Increase memory and CPU allocation when starting Minikube.
   ```bash
   minikube delete
   minikube start --driver=docker --gpus=all --memory=32768m --cpus=12
   ```

2. **GPU not detected in containers**:
   - **Issue**: NVIDIA Container Toolkit not properly configured.
   - **Solution**: Verify the toolkit installation and ensure the Docker runtime is configured correctly.
   ```bash
   sudo nvidia-ctk runtime configure --runtime=docker
   sudo systemctl restart docker
   ```

3. **Ingress not working**:
   - **Issue**: Ingress controller not properly initialized or DNS resolution not working.
   - **Solution**: Check the Ingress controller status and verify the hostname format.
   ```bash
   kubectl get pods -n ingress-nginx
   # Verify the minikube IP
   minikube ip
   # Your hostname should be in the format: openwebui-[minikube-ip-with-dashes].traefik.me
   ```

4. **Certificate errors**:
   - **Issue**: cert-manager not properly configured or CA not trusted.
   - **Solution**: Verify cert-manager installation and ensure the CA is properly configured.
   ```bash
   kubectl get clusterissuer
   kubectl describe certificate -n ollama
   ```

5. **Connection refused errors**:
   - **Issue**: Services not properly exposed or not running.
   - **Solution**: Check service status and port forwarding.
   ```bash
   kubectl get svc -n ollama
   kubectl get svc -n open-webui
   ```

## 📜 License

MIT - see [LICENSE](LICENSE)

## ❤️ Credits

- Inspired by the open-source LLM community
- Made possible by [Ollama](https://ollama.ai/) and [Open-WebUI](https://github.com/open-webui/open-webui)
- Developed with ❤️ for the AI community
