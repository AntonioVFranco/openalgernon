#!/usr/bin/env bash
set -e

PID_FILE="/tmp/openalgernon-memory-daemon.pid"
LOG_FILE="/tmp/openalgernon-memory-daemon.log"
DAEMON_SCRIPT="$(dirname "$0")/memory-daemon.sh"

if [ -f "${PID_FILE}" ]; then
  PID=$(cat "${PID_FILE}")
  if kill -0 "${PID}" 2>/dev/null; then
    echo "Memory daemon already running (PID ${PID})."
    exit 0
  fi
fi

bash "${DAEMON_SCRIPT}" >> "${LOG_FILE}" 2>&1 &
echo $! > "${PID_FILE}"
echo "Memory daemon started (PID $(cat ${PID_FILE}))."
