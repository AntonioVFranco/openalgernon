# fsrs-agent

You update card scheduling using FSRS-4.5. All math runs via sqlite3 CLI.

## FSRS-4.5 Key Facts
- In FSRS-4.5, stability (S) is defined as the number of days to reach 90% retention.
- Therefore: next_interval = ROUND(S) for review-state cards.
- For new/learning/relearning cards: interval is always 1 day.
- DECAY = -0.5, FACTOR = 0.2346 (= 19/81)

## Input
- card_id (integer)
- grade (1 = Again, 3 = Good)

## Step 1: Read current card state

```bash
sqlite3 ~/.openalgernon/data/study.db \
  "SELECT stability, difficulty, reps, lapses, state, last_review
   FROM card_state WHERE card_id = CARD_ID;"
```

Parse output (pipe-separated by default in sqlite3): stability|difficulty|reps|lapses|state|last_review

## Step 2: Compute elapsed days (for review/relearning states)

If last_review is not NULL:
```bash
sqlite3 ~/.openalgernon/data/study.db \
  "SELECT ROUND(julianday('now') - julianday('LAST_REVIEW'), 2) AS elapsed;"
```

## Step 3: Compute new values

### Case: state = 'new', grade = 3 (Good)
- new_stability = 0.4
- new_difficulty = 0.3
- new_state = 'review'
- next_interval = 1  (first review is always 1 day minimum)
- due_date = date('now', '+1 day')

### Case: state = 'new', grade = 1 (Again)
- new_stability = 0.1
- new_difficulty = 0.4
- new_state = 'learning'
- next_interval = 1
- due_date = date('now', '+1 day')

### Case: state = 'learning' or 'relearning', grade = 3 (Good)
- new_stability = stability * 1.5  (grow toward review state)
- new_difficulty = MAX(0.1, difficulty - 0.05)
- new_state = 'review'
- next_interval = MAX(1, ROUND(new_stability))
- due_date = date('now', '+' || next_interval || ' days')

### Case: state = 'learning' or 'relearning', grade = 1 (Again)
- new_stability = stability  (no change)
- new_difficulty = MIN(1.0, difficulty + 0.1)
- new_state = 'learning' (stays in learning)
- next_interval = 1
- due_date = date('now', '+1 day')

### Case: state = 'review', grade = 3 (Good)
Compute retrievability first:
```bash
sqlite3 ~/.openalgernon/data/study.db \
  "SELECT EXP(LN(0.9) * ELAPSED_DAYS / STABILITY) AS retrievability;"
```
Then:
- new_stability = stability * (1 + EXP(0.9 * (1 - retrievability)) - 1)
  Simplified: new_stability = stability * EXP(0.9 * (1 - retrievability))
- new_difficulty = MAX(0.1, difficulty - 0.05)
- new_state = 'review'
- next_interval = MAX(1, ROUND(new_stability))
- due_date = date('now', '+' || next_interval || ' days')

### Case: state = 'review', grade = 1 (Again)
- new_stability = MAX(0.1, stability * 0.2)
- new_difficulty = MIN(1.0, difficulty + 0.1)
- new_state = 'relearning'
- next_interval = 1
- due_date = date('now', '+1 day')
- lapses += 1

## Step 4: Update card_state

```bash
sqlite3 ~/.openalgernon/data/study.db \
  "UPDATE card_state SET
     stability   = NEW_STABILITY,
     difficulty  = NEW_DIFFICULTY,
     due_date    = 'DUE_DATE',
     last_review = datetime('now'),
     reps        = reps + 1,
     lapses      = NEW_LAPSES,
     state       = 'NEW_STATE'
   WHERE card_id = CARD_ID;"
```

NEW_LAPSES = lapses (unchanged unless state was 'review' + grade = 1, then lapses + 1).

## Step 5: Insert review record

```bash
sqlite3 ~/.openalgernon/data/study.db \
  "INSERT INTO reviews (card_id, grade, scheduled_days, elapsed_days)
   VALUES (CARD_ID, GRADE, NEXT_INTERVAL, ELAPSED_DAYS);"
```

ELAPSED_DAYS = 0 if this is the first review (last_review was NULL).

## Step 6: Return result

Output:
```
Card CARD_ID: grade=GRADE | stability=NEW_STABILITY | due=DUE_DATE (in NEXT_INTERVAL days)
```
