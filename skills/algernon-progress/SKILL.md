---
name: algernon-progress
description: >
  Progress reporting, memory management, and session logging for OpenAlgernon.
  Use when the user runs `/algernon report`, says "ver progresso", "meu relatorio
  de estudos", "como estou indo", "ver retencao", "estatisticas de estudo",
  "atualizar memoria", or "salvar sessao". Also used internally by other skills
  at the end of sessions to write memory logs and update MEMORY.md.
---

# algernon-progress

You handle progress reporting, memory updates, and session logging. The report
gives the user a clear picture of where they are in the curriculum, what their
retention looks like, and what to focus on next.

## Constants

```bash
ALGERNON_HOME="${ALGERNON_HOME:-$HOME/.openalgernon}"
DB="${ALGERNON_HOME}/data/study.db"
MEMORY="${ALGERNON_HOME}/memory/MEMORY.md"
CONVERSATIONS="${ALGERNON_HOME}/memory/conversations"
```

---

## Progress Report

Run all queries and format the full report.

### Overall retention (last 30 days):
```bash
sqlite3 "$DB" \
  "SELECT ROUND(
     CAST(SUM(CASE WHEN grade=3 THEN 1 ELSE 0 END) AS REAL) / COUNT(id) * 100, 1
   ) AS retention_pct
   FROM reviews
   WHERE reviewed_at >= datetime('now', '-30 days');"
```

### Cards due today:
```bash
sqlite3 "$DB" "SELECT COUNT(*) FROM card_state WHERE due_date <= date('now');"
```

### Total cards:
```bash
sqlite3 "$DB" "SELECT COUNT(*) FROM cards;"
```

### Per-material breakdown:
```bash
sqlite3 "$DB" \
  "SELECT m.name,
          COUNT(DISTINCT c.id) AS total_cards,
          SUM(cs.reps) AS total_reps,
          ROUND(AVG(cs.stability), 2) AS avg_stability
   FROM materials m
   JOIN decks d ON d.material_id = m.id
   JOIN cards c ON c.deck_id = d.id
   JOIN card_state cs ON cs.card_id = c.id
   GROUP BY m.id;"
```

### Weak areas (most lapses):
```bash
sqlite3 "$DB" \
  "SELECT c.front, cs.lapses, c.tags
   FROM cards c JOIN card_state cs ON cs.card_id = c.id
   WHERE cs.lapses > 2
   ORDER BY cs.lapses DESC LIMIT 10;"
```

### Active days (last 7):
```bash
sqlite3 "$DB" \
  "SELECT COUNT(DISTINCT date(reviewed_at)) AS active_days
   FROM reviews
   WHERE reviewed_at >= datetime('now', '-7 days');"
```

### Report Format

```
Progress Report -- YYYY-MM-DD

Overall retention (30d): X%
Cards due today: N
Total cards: N
Active days (last 7): N/5

Per-material:
  [MATERIAL]: N cards  avg stability Y days

Weak areas (most lapses):
  - [card front] (N lapses) [tags]

Recommended next session:
  [One clear recommendation based on the data]
```

---

## Memory Save

Called by other skills at the end of each session. Input: session_summary (string).

1. Append to today's conversation log:
   ```bash
   DATE=$(date +%Y-%m-%d)
   TIME=$(date +%H:%M)
   echo "[$TIME] SESSION_SUMMARY" >> "$CONVERSATIONS/$DATE.md"
   ```

2. Update `$MEMORY`:
   - Update "Last session" with today's date and activity.
   - Increment "Current streak" if this is the first session today.
   - Increment "Total sessions" count.
   - Update "Average retention" if a review session occurred.
   - Add to "Weak areas" if gaps were identified during the session.

   Read the file, apply the changes in-place, write it back.
   Preserve all other content exactly — do not reformat.
