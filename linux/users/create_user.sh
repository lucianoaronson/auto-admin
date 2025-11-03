#!/usr/bin/env bash
set -euo pipefail

# Carpeta de evidencias (relative al repo)
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")"/../.. && pwd)"
LOG_DIR="$BASE_DIR/docs/evidencias"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/linux_create_user_$(date +%F_%H%M%S).log"

usage(){
  echo "Uso: $0 -u <usuario> [-n \"Nombre Completo\"] [-g grupo1,grupo2]"
  exit 1
}

FULLNAME=""; GROUPS=""; USERNAME=""
while getopts ":u:n:g:" opt; do
  case $opt in
    u) USERNAME="$OPTARG" ;;
    n) FULLNAME="$OPTARG" ;;
    g) GROUPS="$OPTARG" ;;
    *) usage ;;
  esac
done
[[ -z "$USERNAME" ]] && usage

# Redirigimos todo a log + pantalla
exec > >(tee -a "$LOG_FILE") 2>&1

echo "[INFO] Creando usuario: $USERNAME"
if id "$USERNAME" &>/dev/null; then
  echo "[OK] Usuario ya existe, nada que hacer."
  exit 0
fi

# Crea el usuario con home y shell bash
sudo useradd -m -s /bin/bash ${FULLNAME:+-c "$FULLNAME"} "$USERNAME"

# Password temporal (intenta openssl; si no está, usa /dev/urandom)
if command -v openssl >/dev/null 2>&1; then
  PASS=$(openssl rand -base64 18 | tr -d '=+/\n' | cut -c1-14)
else
  PASS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 14)
fi
echo "$USERNAME:$PASS" | sudo chpasswd

# Agrega a grupos adicionales si se pasan
[[ -n "$GROUPS" ]] && sudo usermod -aG "$GROUPS" "$USERNAME"

# Fuerza cambio de password en primer login
sudo chage -d 0 "$USERNAME" || true

# Guarda credenciales en evidencias (no subir esto a un repo público)
CREDS="$LOG_DIR/${USERNAME}_credenciales.txt"
cat <<EOF > "$CREDS"
Usuario: $USERNAME
Password temporal: $PASS
Generado: $(date)
EOF

echo "[DONE] Usuario creado. Credenciales: $CREDS"

