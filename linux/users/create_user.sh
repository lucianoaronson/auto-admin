#!/usr/bin/env bash
set -euo pipefail
LOG_DIR="$(dirname "$0")/../../docs/evidencias"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/linux_create_user_$(date +%F_%H%M%S).log"


usage(){ echo "Uso: $0 -u <usuario> [-n \"Nombre Completo\"] [-g grupo1,grupo2]"; exit 1; }


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


exec > >(tee -a "$LOG_FILE") 2>&1


echo "[INFO] Creando usuario: $USERNAME"
if id "$USERNAME" &>/dev/null; then
echo "[OK] Usuario ya existe, nada que hacer"
exit 0
fi


sudo useradd -m -s /bin/bash ${FULLNAME:+-c "$FULLNAME"} "$USERNAME"
PASS=$(openssl rand -base64 18 | tr -d '=+/\n' | cut -c1-14)
echo "$USERNAME:$PASS" | sudo chpasswd
[[ -n "$GROUPS" ]] && sudo usermod -aG "$GROUPS" "$USERNAME"


sudo chage -d 0 "$USERNAME" # fuerza cambio de password en el primer login


cat <<EOF > "$LOG_DIR/${USERNAME}_credenciales.txt"
Usuario: $USERNAME
Password temporal: $PASS
Generado: $(date)
EOF


echo "[DONE] Usuario creado. Credenciales guardadas en docs/evidencias/${USERNAME}_credenciales.txt"
