---
name: algernon-sprint
version: "1.0.0"
description: >
  Timed interleaved study sprint for OpenAlgernon. Use when the user runs
  `/algernon sprint [15|25|45]`, says "sprint de estudo", "sessao cronometrada",
  "25 minutos de revisao", "modo pomodoro", "quero fazer um sprint", or
  "revisar varios materiais de uma vez". Cards from all installed materials are
  shuffled and interleaved. Ends with a post-sprint retrieval test to measure
  retention gain.
---

# algernon-sprint

You run a timed interleaved study sprint. Cards from all installed materials are
shuffled together — interleaving different topics forces retrieval across contexts
and strengthens long-term retention compared to blocking by material.

## Constants

```bash
ALGERNON_HOME="${ALGERNON_HOME:-$HOME/.openalgernon}"
DB="${ALGERNON_HOME}/data/study.db"
```

## Card Limits by Duration

| Duration | Max Cards |
|----------|-----------|
| 15 min   | 20 cards  |
| 25 min   | 35 cards  |
| 45 min   | 60 cards  |

## Step 1 — Plan the Sprint

Fetch due cards across all materials:

```bash
sqlite3 "$DB" \
  "SELECT c.id, c.type, c.front, c.back, m.name AS material
   FROM cards c
   JOIN card_state cs ON cs.card_id = c.id
   JOIN decks d ON d.id = c.deck_id
   JOIN materials m ON m.id = d.material_id
   WHERE cs.due_date <= date('now')
   ORDER BY RANDOM()
   LIMIT CARD_LIMIT;"
```

Interleave the results: shuffle so no two consecutive cards come from the same
material. If there are not enough due cards to fill the limit, repeat cards from
the most overdue deck rather than reducing below ~15 cards.

## Step 2 — Sprint Start

```
Sprint: [DURATION] minutes
Materials: [list of materials represented]
Cards: [count]
```

AskUserQuestion: ["Start sprint"]

## Step 3 — Sprint Loop

Run the same review flow as `algernon-review`:
- Flashcards: show front → reveal back → Again/Good
- Dissertative/Argumentative: show front → free-text answer → AI evaluate → Again/Good
- After each grade, run FSRS scheduling (see `algernon-review` for full formulas)

After every 10 cards, display a progress line:
```
Cards remaining: N  |  Estimated time: X min
```

## Step 4 — Post-Sprint Break

After all cards reviewed:
```
Sprint complete. Take a 5-minute break.
Cards reviewed: N  |  Session retention: X%
```

AskUserQuestion: ["Start post-sprint test"]

## Step 5 — Post-Sprint Retrieval Test

Select 5 random cards from the cards reviewed in this sprint.
For each card:
1. Show only the front.
2. AskUserQuestion: ["Show answer"] — then show the back.
3. AskUserQuestion options: ["Again", "Good"]
4. Run FSRS update with the new grade.

Display:
```
Post-sprint test complete.
Sprint retention:      X%
Post-sprint retention: Y%
Session gain:          +Z%
```

A positive gain means the interleaved practice improved retention above the
pre-sprint baseline — the core signal that the session was effective.

## Step 6 — Save Memory

```bash
echo "[HH:MM] sprint [DURATION]min | Cards: N | Retention: X% | Post-sprint: Y% | Gain: +Z%" \
  >> "${ALGERNON_HOME}/memory/conversations/YYYY-MM-DD.md"
```
