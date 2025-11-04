#!/usr/bin/env bash
set -euo pipefail

# Base del repo (2 niveles arriba de este script)
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")"/../.. && pwd)"
# Si viene DEST_DIR_REL desde backup.conf, convertirlo a absoluto dentro del repo.
if [[ -n "${DEST_DIR_REL:-}" ]]; then
  DEST_DIR="$BASE_DIR/$DEST_DIR_REL"
fi
# Si DEST_DIR no quedó seteado, por defecto al repo:
DEST_DIR="${DEST_DIR:-$BASE_DIR/docs/evidencias/backups-linux}"
# -----------------------------------------------
# Carga la config (define SRC_DIRS, DEST_DIR, RETAIN_DAYS)
. "$(dirname -- "${BASH_SOURCE[0]}")/backup.conf"

# Asegura carpetas y log
LOG_DIR="$BASE_DIR/docs/evidencias"
mkdir -p "$LOG_DIR" "$DEST_DIR"
LOG_FILE="$LOG_DIR/linux_backup_$(date +%F_%H%M%S).log"

exec > >(tee -a "$LOG_FILE") 2>&1

DATE=$(date +%F_%H%M%S)
ARCHIVE="$DEST_DIR/backup_$DATE.tar.gz"

echo "[INFO] Iniciando backup -> $ARCHIVE"
tar -czf "$ARCHIVE" ${SRC_DIRS}

echo "[INFO] Rotación: borrando backups > $RETAIN_DAYS días"
find "$DEST_DIR" -name 'backup_*.tar.gz' -mtime +"$RETAIN_DAYS" -print -delete

echo "[DONE] Backup OK: $ARCHIVE"
