FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Runtime dependencies: sqlite3 (required), git (material installs), curl (ingest)
RUN apt-get update && apt-get install -y \
    sqlite3 \
    git \
    curl \
    bash \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# OpenAlgernon user-data directory (mirrors the native ~/.openalgernon path)
ENV ALGERNON_HOME=/root/.openalgernon

# Embed the full repo so the container is self-contained
WORKDIR /opt/openalgernon
COPY . .

# Bootstrap: init database and directory layout
RUN bash scripts/init-db.sh \
    && mkdir -p "${ALGERNON_HOME}/materials" \
                "${ALGERNON_HOME}/files" \
                "${ALGERNON_HOME}/memory/conversations" \
    && cp memory/MEMORY.md "${ALGERNON_HOME}/memory/MEMORY.md"

# Register agents and skills where Claude Code expects them
RUN mkdir -p /root/.claude/agents /root/.claude/skills \
    && cp agents/*.json /root/.claude/agents/ \
    && cp skill.md /root/.claude/skills/algernon.md \
    && for skill_dir in skills/*/; do \
         skill_name=$(basename "${skill_dir}"); \
         mkdir -p "/root/.claude/skills/${skill_name}"; \
         cp "${skill_dir}/SKILL.md" "/root/.claude/skills/${skill_name}/SKILL.md"; \
       done

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
