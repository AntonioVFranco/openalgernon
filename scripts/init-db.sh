#!/usr/bin/env bash
set -e

DATA_DIR="${HOME}/.openalgernon/data"
DB_PATH="${DATA_DIR}/study.db"
SCHEMA_PATH="$(dirname "$0")/../schema/study.sql"

mkdir -p "${DATA_DIR}"

if [ -f "${DB_PATH}" ]; then
  echo "Database already exists at ${DB_PATH}. Skipping initialization."
  exit 0
fi

sqlite3 "${DB_PATH}" < "${SCHEMA_PATH}"
echo "Database initialized at ${DB_PATH}."
