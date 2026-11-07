#!/usr/bin/env bash
# Avvio del FASAS cloud su un hosting Python persistente (Enzonic Cloud).
# Non installa pacchetti né genera chiavi: la preparazione e le credenziali restano nel pannello del provider.
set -euo pipefail

cd "$(dirname "$0")/.."

export FASAS_CLOUD=1
export DJANGO_DEBUG=0
export FASAS_MEDIA_ROOT="${FASAS_MEDIA_ROOT:-$PWD/runtime/media}"
export FASAS_BACKUP_DIR="${FASAS_BACKUP_DIR:-$PWD/runtime/backups}"
export GUNICORN_WORKERS="${GUNICORN_WORKERS:-1}"
export GUNICORN_THREADS="${GUNICORN_THREADS:-2}"

if [[ ! "${PORT:-}" =~ ^[0-9]+$ ]]; then
  echo "Enzonic: imposta PORT con la porta assegnata al server nel pannello." >&2
  exit 1
fi

mkdir -p "$FASAS_MEDIA_ROOT" "$FASAS_BACKUP_DIR"

if ! command -v pg_dump >/dev/null 2>&1; then
  echo "ATTENZIONE: pg_dump non trovato. Non usare dati reali: backup e prova di ripristino non sono collaudabili." >&2
elif [[ "$(pg_dump --version | grep -oE '[0-9]+' | head -n 1)" -lt 17 ]]; then
  echo "ATTENZIONE: il pg_dump installato è troppo vecchio per PostgreSQL 17 di Supabase." >&2
fi

python manage.py collectstatic --noinput --verbosity 0
exec bash docker/cloud.sh
