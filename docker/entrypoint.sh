#!/usr/bin/env bash
set -e

ALGERNON_HOME="${ALGERNON_HOME:-/root/.openalgernon}"

# Re-initialize the database if the volume was just mounted and the DB is missing.
# This handles the case where a fresh named volume is attached.
if [ ! -f "${ALGERNON_HOME}/data/study.db" ]; then
  echo "Initializing OpenAlgernon database..."
  bash /opt/openalgernon/scripts/init-db.sh
fi

# Copy the MEMORY.md template if the user has no memory file yet.
if [ ! -f "${ALGERNON_HOME}/memory/MEMORY.md" ]; then
  mkdir -p "${ALGERNON_HOME}/memory/conversations"
  cp /opt/openalgernon/memory/MEMORY.md "${ALGERNON_HOME}/memory/MEMORY.md"
fi

# Start the memory daemon in the background.
bash /opt/openalgernon/scripts/memory-daemon.sh &

exec "$@"
