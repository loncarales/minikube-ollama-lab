#!/bin/bash

# Color constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

check_gpu_support() {
  if docker info | grep -i "nvidia" &>/dev/null; then
    return 0 # 0 = success
  else
    return 1 # 1 = failure
  fi
}

is_linux() {
  if [[ "$(uname)" == "Linux" ]]; then
    return 0 # 0 = success
  else
    return 1 # 1 = failure
  fi
}
