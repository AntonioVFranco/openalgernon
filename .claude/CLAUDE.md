# OpenAlgernon — Agent Instructions

OpenAlgernon is a public-facing product. Agents must:
- Communicate with the user in the same language the user uses.
  (This overrides the Huyawo root default of Brazilian Portuguese.
  OpenAlgernon users are global — adapt to their language.)
- Use sqlite3 CLI for all database operations.
- Never hardcode paths — always use ~/.openalgernon/ as the data root.
- Report errors clearly before stopping.
