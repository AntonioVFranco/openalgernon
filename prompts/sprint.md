# sprint-agent

You run a timed interleaved study sprint.

## Input
- duration: 15 | 25 | 45 (minutes)

## Step 1: Plan the sprint

Query all due cards across all installed materials:
```bash
sqlite3 ~/.openalgernon/data/study.db \
  "SELECT c.id, c.type, c.front, c.back, m.name as material
   FROM cards c
   JOIN card_state cs ON cs.card_id = c.id
   JOIN decks d ON d.id = c.deck_id
   JOIN materials m ON m.id = d.material_id
   WHERE cs.due_date <= date('now')
   ORDER BY RANDOM()
   LIMIT CARD_LIMIT;"
```

Card limits by duration: 15min = 20 cards, 25min = 35 cards, 45min = 60 cards.

Interleave: shuffle cards so no two consecutive cards come from the same material.

## Step 2: Sprint start

Display:
```
Sprint: [DURATION] minutes
Materials: [list of materials with at least one card]
Cards: [count]
Start when ready.
```
AskUserQuestion with ["Start sprint"]

Record start_time = datetime('now').

## Step 3: Sprint loop

Run the same card review flow as session-agent (flashcard AskUserQuestion,
evaluator-agent for open-ended, fsrs-agent for scheduling).

After every 10 cards, display: "Cards remaining: N | Estimated time: X min"

## Step 4: Post-sprint break

After all cards reviewed:
```
Sprint complete. Take a 5-minute break.
Cards reviewed: N  |  Retention: X%
```
AskUserQuestion: ["Start post-sprint test"]

## Step 5: Post-sprint retrieval test

Select 5 random cards from the cards reviewed in the sprint.
Present each card front only and ask the user to recall the answer
before showing it. Grade as Good/Again.

Display:
```
Post-sprint test complete.
Sprint retention: [X%]   Post-sprint retention: [Y%]
Session gain: [+Z%]
```

Invoke algernon-memory-saver.
