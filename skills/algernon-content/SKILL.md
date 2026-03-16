---
name: algernon-content
description: >
  Material and card management for OpenAlgernon. Use when the user runs any
  of: `/algernon install`, `list`, `info`, `update`, `remove`, `import`,
  `audio`, `ingest`, or says "instalar material", "listar materiais",
  "gerar cards", "instalar novo conteudo", "remover material", "importar PDF",
  "gerar podcast NotebookLM", or "criar flashcards para [material]". Also
  handles card generation (all three modes: generate new cards, promote
  N1/N2/N3, create correction cards).
---

# algernon-content

You handle all material management and card operations for OpenAlgernon.
This covers installing and removing materials, generating cards at all
depth levels, and creating NotebookLM audio scripts.

## Constants

```bash
ALGERNON_HOME="${ALGERNON_HOME:-$HOME/.openalgernon}"
DB="${ALGERNON_HOME}/data/study.db"
MATERIALS="${ALGERNON_HOME}/materials"
```

---

## Material Management

### list

```bash
sqlite3 "$DB" \
  "SELECT slug, name, author, version, installed_at
   FROM materials ORDER BY installed_at DESC;"
```

Format as a readable list. If empty: "No materials installed yet."

### info SLUG

```bash
sqlite3 "$DB" \
  "SELECT slug, name, author, version, repo_url, local_path, installed_at
   FROM materials WHERE slug = 'SLUG';"
```

### install github:org/repo

1. Clone the repository:
   ```bash
   git clone --depth 1 https://github.com/ORG/REPO "$MATERIALS/SLUG"
   ```
2. Read `$MATERIALS/SLUG/algernon.yaml` for: name, author, version, content files,
   card distribution, focus concepts.
3. Register in DB:
   ```bash
   sqlite3 "$DB" \
     "INSERT INTO materials (slug, name, author, version, repo_url, local_path, algernonspec)
      VALUES ('SLUG','NAME','AUTHOR','VERSION',
              'https://github.com/ORG/REPO',
              '$MATERIALS/SLUG',
              'v1');"
   ```
4. Run card generation for this material (see Card Generation section below).
5. Confirm: "Material SLUG installed. N cards generated."

### import local:PATH

1. Read the file at `$ALGERNON_HOME/files/PATH` (supports .md, .txt, .pdf).
2. For PDF: extract text. For MD/TXT: use as-is.
3. Generate a slug from the filename (lowercase, hyphens, no extension).
4. Register in DB with local_path and empty repo_url.
5. Run card generation.
6. Confirm: "Material SLUG imported. N cards generated."

### update SLUG

```bash
LOCAL_PATH=$(sqlite3 "$DB" "SELECT local_path FROM materials WHERE slug = 'SLUG';")
git -C "$LOCAL_PATH" pull --ff-only
```

Confirm: "Material SLUG updated."

### remove SLUG

Confirm with user before proceeding (this cannot be undone).

If confirmed:
```bash
LOCAL_PATH=$(sqlite3 "$DB" "SELECT local_path FROM materials WHERE slug = 'SLUG';")
sqlite3 "$DB" "DELETE FROM materials WHERE slug = 'SLUG';"
rm -rf "$LOCAL_PATH"
```

(The DELETE cascades to decks, cards, card_state, and reviews via foreign keys.)

---

## Card Generation

### Mode A — Generate Cards for a Material

Read `LOCAL_PATH/algernon.yaml` to get:
- `content`: list of content files
- `cards.distribution`: [flashcard%, dissertative%, argumentative%] (default [50, 30, 20])
- `cards.focus`: list of priority concepts

For a default batch of 20 cards:
- 10 flashcards, 6 dissertative, 4 argumentative

Card rules:
- All new cards start at N1. Tags must include `[N1]`.
- Prioritize concepts listed in `cards.focus`.
- **Flashcard**: front = concise question or term. back = precise 1-sentence definition.
- **Dissertative**: front = "Explain [concept] in your own words."
  back = reference answer covering 3-5 key points.
- **Argumentative**: front = "Compare X vs Y" or "When would you choose X over Y?"
  back = structured comparison with trade-offs listed on both sides.

Create a deck first:
```bash
sqlite3 "$DB" \
  "INSERT INTO decks (material_id, name, topic)
   VALUES (MATERIAL_ID, 'DECK_NAME', 'TOPIC');
   SELECT last_insert_rowid();"
```

Insert each card and its initial card_state:
```bash
sqlite3 "$DB" \
  "INSERT INTO cards (deck_id, type, front, back, tags, source_file, source_title)
   VALUES (DECK_ID, 'TYPE', 'FRONT', 'BACK', '[\"[N1]\",\"TAG\"]', 'FILE', 'TITLE');
   INSERT INTO card_state (card_id, due_date)
   VALUES (last_insert_rowid(), date('now'));"
```

Escape all single quotes in card text as '' (two single quotes) for SQLite.

### Mode B — Promote Card (N1 → N2 or N2 → N3)

Input: card_id, target_level

Read the original card, then generate a deeper version:
- N2: differentiator + when to use + main trade-off (2-3 sentences on back)
- N3: full technical depth, production nuances, edge cases (detailed back)

```bash
sqlite3 "$DB" \
  "INSERT INTO cards (deck_id, type, front, back, tags, source_file, source_title)
   VALUES (DECK_ID, 'TYPE', 'FRONT', 'DEEP_BACK', '[\"[N2]\",\"TAG\"]', 'FILE', 'TITLE');
   INSERT INTO card_state (card_id, due_date)
   VALUES (last_insert_rowid(), date('now'));"
```

### Mode C — Correction Card

Input: deck_id, misconception, correct_explanation

```bash
sqlite3 "$DB" \
  "INSERT INTO cards (deck_id, type, front, back, tags)
   VALUES (DECK_ID, 'flashcard',
           'CORRECTION: MISCONCEPTION_AS_QUESTION',
           'CORRECT_EXPLANATION',
           '[\"[correction]\",\"[N1]\"]');
   INSERT INTO card_state (card_id, due_date)
   VALUES (last_insert_rowid(), date('now'));"
```

---

## Audio / NotebookLM

### audio [SLUG]

Generates a podcast-style learning script from the material.

1. Read all content files for the material.
2. Generate a two-host dialogue script:
   ```
   HOST A: [question or framing]
   HOST B: [explanation using N1 definitions]
   HOST A: [follow-up or analogy request]
   HOST B: [deeper explanation or example]
   ...
   ```
3. Cover all major concepts grouped by section.
4. Save the script to `$MATERIALS/SLUG/podcast-script.md`.

### ingest URL|PATH [--title TITLE]

1. Fetch the URL (or read the local file at `$ALGERNON_HOME/files/PATH`).
2. Extract title from page metadata or from `--title` flag.
3. Create a slug from the title (lowercase, hyphens).
4. Save content to `$MATERIALS/SLUG/content/01-main.md`.
5. Generate a minimal `algernon.yaml` pointing at the content file.
6. Register in DB and run card generation.
7. Confirm: "Material SLUG created from ingest. N cards generated."
