# Progress Team

## stats-agent queries

### Overall retention (last 30 days)
```bash
sqlite3 ~/.openalgernon/data/study.db \
  "SELECT ROUND(
     CAST(SUM(CASE WHEN grade = 3 THEN 1 ELSE 0 END) AS REAL) /
     COUNT(id) * 100, 1
   ) as retention_pct
   FROM reviews
   WHERE reviewed_at >= datetime('now', '-30 days');"
```

### Cards due today
```bash
sqlite3 ~/.openalgernon/data/study.db \
  "SELECT COUNT(*) FROM card_state WHERE due_date <= date('now');"
```

### Per-material breakdown
```bash
sqlite3 ~/.openalgernon/data/study.db \
  "SELECT m.name,
          COUNT(DISTINCT c.id) as total_cards,
          SUM(cs.reps) as total_reps,
          ROUND(AVG(cs.stability), 2) as avg_stability
   FROM materials m
   JOIN decks d ON d.material_id = m.id
   JOIN cards c ON c.deck_id = d.id
   JOIN card_state cs ON cs.card_id = c.id
   GROUP BY m.id;"
```

### Weak areas (cards with most lapses)
```bash
sqlite3 ~/.openalgernon/data/study.db \
  "SELECT c.front, cs.lapses, c.tags
   FROM cards c JOIN card_state cs ON cs.card_id = c.id
   WHERE cs.lapses > 2
   ORDER BY cs.lapses DESC LIMIT 10;"
```

## report-agent output format

```
Progress Report — [date]

Overall retention (30d): X%
Cards due today: N
Total cards: N

Per-material:
  [MATERIAL]: N cards · X% retention · avg stability Y days

Weak areas (most lapses):
  - [card front] ([N lapses])

Recommended next session:
  [One clear recommendation based on the stats]
```
