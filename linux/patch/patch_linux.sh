#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")"/../.. && pwd)"
LOG_DIR="$BASE_DIR/docs/evidencias"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/linux_patch_$(date +%F_%H%M%S).log"

exec > >(tee -a "$LOG_FILE") 2>&1

ID=$(
  awk -F= '/^ID=/{gsub(/"/,"",$2); print $2}' /etc/os-release 2>/dev/null \
  || echo "unknown"
)
LOWER=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
echo "[INFO] Distro detectada: $LOWER"

if [[ "$LOWER" =~ (debian|ubuntu) ]]; then
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
elif [[ "$LOWER" =~ (rhel|centos|rocky|almalinux|fedora) ]]; then
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf -y upgrade
  else
    sudo yum -y update
  fi
else
  echo "[WARN] Distro no soportada automáticamente."
  exit 1
fi

# Chequeo simple de reboot (válido en Debian/Ubuntu)
NEED_REBOOT=0
[[ -f /var/run/reboot-required ]] && NEED_REBOOT=1

if [[ $NEED_REBOOT -eq 1 ]]; then
  echo "[INFO] Reboot requerido (no se ejecuta reboot automáticamente en WSL)."
else
  echo "[DONE] Sistema actualizado sin reinicio requerido."
fi
