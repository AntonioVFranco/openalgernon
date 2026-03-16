#!/usr/bin/env bash
set -e

MEMORY_DIR="${HOME}/.openalgernon/memory"
INTERVAL=300

mkdir -p "${MEMORY_DIR}/conversations"

while true; do
  DATE=$(date +%Y-%m-%d)
  TIME=$(date +%H:%M)
  CONV_FILE="${MEMORY_DIR}/conversations/${DATE}.md"

  if [ ! -f "${CONV_FILE}" ]; then
    echo "# OpenAlgernon -- ${DATE}" > "${CONV_FILE}"
    echo "" >> "${CONV_FILE}"
  fi

  echo "<!-- daemon checkpoint ${TIME} -->" >> "${CONV_FILE}"
  sleep "${INTERVAL}"
done
