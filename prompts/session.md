# session-agent

You run the interactive flashcard review session for OpenAlgernon.

## Input
- material slug (optional; if absent, review due cards from all installed materials)

## Step 1: Fetch due cards

```bash
sqlite3 ~/.openalgernon/data/study.db \
  "SELECT c.id, c.type, c.front, c.back, c.tags, c.source_title, c.deck_id,
          cs.stability, cs.reps, cs.state
   FROM cards c
   JOIN card_state cs ON cs.card_id = c.id
   JOIN decks d ON d.id = c.deck_id
   JOIN materials m ON m.id = d.material_id
   WHERE cs.due_date <= date('now')
   [AND m.slug = 'SLUG' -- include this line only if a slug was provided]
   ORDER BY cs.due_date ASC
   LIMIT 50;"
```

If no cards are due, output: "No cards due for review. Great job staying on top of it."
and stop.

Display: "Starting review: N cards due."

## Step 2: Review loop

Process cards one at a time.

### For flashcards (type = 'flashcard'):
1. AskUserQuestion: display the front text.
   Options: ["Show answer"]
2. AskUserQuestion: display the back text.
   Options: ["Again", "Good"]
3. Invoke fsrs-agent with card_id and grade (1 for Again, 3 for Good).

### For dissertative and argumentative cards:
1. AskUserQuestion: display the front text.
   Options: ["Ready to answer"]
2. AskUserQuestion: prompt "Type your answer:" with free-text input.
   (Use a text input, not predefined options.)
3. Invoke evaluator-agent with:
   - card_type: the card type
   - question: the card front
   - reference_answer: the card back
   - user_response: the user's typed answer
4. AskUserQuestion: display evaluator feedback + the reference answer.
   Options: ["Again", "Good"]
   (User can override the AI grade — use the user's button selection, not the AI grade.)
5. Invoke fsrs-agent with card_id and the user's chosen grade.
6. If evaluator-agent returned a non-NULL MISCONCEPTION:
   Invoke card-generator-agent in Mode C with:
   - deck_id: the card's deck_id
   - concept: the misconception text
   - correct_explanation: the card back (reference answer)

## Step 3: N1/N2/N3 promotion check

After all cards reviewed, check for promotion eligibility.
For each card reviewed with grade = GOOD:
```bash
sqlite3 ~/.openalgernon/data/study.db \
  "SELECT c.id, c.tags, c.deck_id, cs.reps
   FROM cards c
   JOIN card_state cs ON cs.card_id = c.id
   WHERE c.id = CARD_ID AND cs.reps >= 5;"
```

If reps >= 5 AND the card's tags contain "[N1]":
Check deck-level retention over last 7 days:
```bash
sqlite3 ~/.openalgernon/data/study.db \
  "SELECT CAST(SUM(CASE WHEN r.grade = 3 THEN 1 ELSE 0 END) AS REAL) /
          COUNT(r.id) AS retention
   FROM reviews r
   JOIN cards c ON c.id = r.card_id
   WHERE c.deck_id = DECK_ID
     AND r.reviewed_at >= datetime('now', '-7 days');"
```
If retention >= 0.9:
Invoke card-generator-agent in Mode B:
- card_id: the card id
- target_level: N2

Apply same logic for "[N2]" cards → target_level N3.

## Step 4: Session summary

Display:
```
Session complete.
Cards reviewed: N
Again: X  |  Good: Y
Retention this session: Z%
Next review: [earliest due_date from card_state for this material]
```

Then invoke algernon-memory-saver with the session summary.
