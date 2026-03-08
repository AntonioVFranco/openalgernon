# OpenAlgernon

OpenAlgernon is a Claude Code-native study platform for AI engineers.
It is implemented entirely as Claude Code Agent Teams with SQLite as
the sole data layer.

## Non-negotiable conventions
- All code and documentation in English.
- No emojis anywhere.
- Bash scripts: set -e at the top of every script.
- SQLite queries: always parameterized — no string interpolation.
- Agent definitions: JSON only, no YAML.
- Prompt templates: Markdown only.
- No Python. No Node. No external runtimes.

## Directory layout
- agents/         JSON agent definitions
- prompts/        Markdown prompt templates for each agent
- prompts/tools/  Prompt templates for the 7 text-block study tools
- schema/         SQLite schema (study.sql)
- scripts/        Bash scripts: install.sh, init-db.sh, memory-daemon.sh, start-daemon.sh
- spec/           AlgernonSpec protocol documentation
- memory/         MEMORY.md template + daily conversation logs
- docker/         Dev environment only (not shipped to users)
- tests/          Integration tests via bash + sqlite3

## Execution model

Users invoke OpenAlgernon via the `/algernon` Claude Code skill (defined in `skill.md`).
The skill invokes `algernon-orchestrator`, which is the single entry point for all commands.
The orchestrator delegates to team leads: content-lead, study-lead, modes-lead, progress-lead.

On first use, `scripts/install.sh` bootstraps the system:
1. Initializes `~/.openalgernon/data/study.db` via `scripts/init-db.sh`
2. Copies agents and skill to `~/.claude/`
3. Starts the memory daemon via `scripts/start-daemon.sh`

The memory daemon (`scripts/memory-daemon.sh`) runs in background and writes 5-minute
checkpoint markers to `~/.openalgernon/memory/conversations/YYYY-MM-DD.md`.

## Memory protocol

OpenAlgernon uses a dedicated memory system independent of the Huyawo root protocol.

- `algernon-memory-guardian`: invoked by the orchestrator at session start. Reads
  `~/.openalgernon/memory/MEMORY.md` and today's conversation log. Returns a briefing.
- `algernon-memory-saver`: invoked by the orchestrator at session end. Appends session
  summary to the daily log and updates MEMORY.md.
- Memory files live in `~/.openalgernon/memory/` (user data, not in this repo).
- The `memory/MEMORY.md` file in this repo is the initial template copied on install.

## User data location
All user data lives in ~/.openalgernon/ and is never stored in this repo.
