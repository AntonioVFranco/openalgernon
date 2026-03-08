#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/AntonioVFranco/openalgernon.git"
INSTALL_DIR="${HOME}/.openalgernon"
AGENTS_DIR="${HOME}/.claude/agents"
SKILLS_DIR="${HOME}/.claude/skills"

echo "Installing OpenAlgernon..."

# Check sqlite3
if ! command -v sqlite3 &> /dev/null; then
  echo "ERROR: sqlite3 not found."
  echo "Install with: apt install sqlite3 (Ubuntu) or brew install sqlite3 (macOS)"
  exit 1
fi

# Clone or update
if [ -d "${INSTALL_DIR}/src/.git" ]; then
  echo "Updating existing installation..."
  git -C "${INSTALL_DIR}/src" pull --ff-only
else
  mkdir -p "${INSTALL_DIR}"
  git clone --depth 1 "${REPO_URL}" "${INSTALL_DIR}/src"
fi

# Initialize database
bash "${INSTALL_DIR}/src/scripts/init-db.sh"

# Copy MEMORY.md template if not present
MEMORY_FILE="${INSTALL_DIR}/memory/MEMORY.md"
mkdir -p "${INSTALL_DIR}/memory/conversations"
if [ ! -f "${MEMORY_FILE}" ]; then
  cp "${INSTALL_DIR}/src/memory/MEMORY.md" "${MEMORY_FILE}"
fi

# Register agents globally
mkdir -p "${AGENTS_DIR}"
for agent_file in "${INSTALL_DIR}/src/agents/"*.json; do
  cp "${agent_file}" "${AGENTS_DIR}/"
done

# Register skill globally
mkdir -p "${SKILLS_DIR}"
cp "${INSTALL_DIR}/src/skill.md" "${SKILLS_DIR}/algernon.md"

# Start memory daemon
bash "${INSTALL_DIR}/src/scripts/start-daemon.sh"

echo ""
echo "OpenAlgernon installed successfully."
echo ""
echo "Try: /algernon install github:author/repo"
echo "Or:  /algernon help"
