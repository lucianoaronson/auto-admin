#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")"/../.. && pwd)"
OUT_DIR="$BASE_DIR/docs/evidencias"
mkdir -p "$OUT_DIR"
REPORT="$OUT_DIR/linux_audit_$(hostname)_$(date +%F_%H%M%S).csv"

echo "host,tipo,fecha,detalle" > "$REPORT"

# auth.log (Debian/Ubuntu) o secure (RHEL-like)
AUTH_FILE="/var/log/auth.log"
[[ -f /var/log/secure ]] && AUTH_FILE="/var/log/secure"

# Autenticaciones fallidas
if [[ -f "$AUTH_FILE" ]]; then
  grep -E "Failed password|Invalid user" "$AUTH_FILE" 2>/dev/null | tail -n 200 \
  | while IFS= read -r line; do
      echo "$(hostname),login_failed,${line:0:15},\"$line\"" >> "$REPORT"
    done

  # Uso de sudo
  grep -E "sudo: *[a-zA-Z0-9_-]+ :" "$AUTH_FILE" 2>/dev/null | tail -n 200 \
  | while IFS= read -r line; do
      echo "$(hostname),sudo_use,${line:0:15},\"$line\"" >> "$REPORT"
    done
fi

# Info de usuarios (uids >= 1000)
getent passwd | awk -F: '{print $1";"$3}' \
| while IFS=";" read -r u uid; do
    if [[ "$uid" -ge 1000 ]]; then
      cdate=$((sudo chage -l "$u" 2>/dev/null || true) | awk -F: '/Last password change/{print $2}' | xargs)
      echo "$(hostname),user_info,$(date +%F),\"$u (pwd_change:$cdate)\"" >> "$REPORT"
    fi
  done

echo "[DONE] Reporte generado: $REPORT"
echo "[DONE] Reporte generado: $REPORT"
exit 0
