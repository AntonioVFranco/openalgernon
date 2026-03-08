#!/usr/bin/env bash
set -e

DB="/tmp/openalgernon-smoke-test.db"

echo "Running OpenAlgernon smoke tests..."

# Test 1: schema initializes
sqlite3 "${DB}" < "$(dirname "$0")/../schema/study.sql"
TABLES=$(sqlite3 "${DB}" ".tables")
echo "${TABLES}" | grep -q "card_state" || { echo "FAIL: card_state table missing"; exit 1; }
echo "PASS: schema initializes correctly"

# Test 2: FSRS math expression is valid
RESULT=$(sqlite3 "${DB}" \
  "SELECT CAST(ROUND((1.5 / 0.2346) * (POW(0.9, (1.0 / -0.5)) - 1.0)) AS INTEGER) AS next_days;")
[ -n "${RESULT}" ] || { echo "FAIL: FSRS expression returned empty"; exit 1; }
echo "PASS: FSRS expression evaluates to ${RESULT} days"

# Test 3: FSRS result is in a sane range (1-10 days for stability=1.5)
[ "${RESULT}" -ge 1 ] && [ "${RESULT}" -le 10 ] || \
  { echo "FAIL: FSRS result ${RESULT} outside expected range 1-10"; exit 1; }
echo "PASS: FSRS result is in sane range"

# Test 4: INSERT and SELECT round-trip
sqlite3 "${DB}" \
  "INSERT INTO materials (slug, name, local_path, algernonspec)
   VALUES ('test-material', 'Test Material', '/tmp/test', '1');
   INSERT INTO decks (material_id, name, topic)
   VALUES (1, 'Test Deck', 'testing');
   INSERT INTO cards (deck_id, type, front, back, tags)
   VALUES (1, 'flashcard', 'What is X?', 'X is Y.', '[\"N1\"]');
   INSERT INTO card_state (card_id, stability, due_date)
   VALUES (1, 0.4, date('now'));"
COUNT=$(sqlite3 "${DB}" "SELECT COUNT(*) FROM cards;")
[ "${COUNT}" -eq 1 ] || { echo "FAIL: card insert failed"; exit 1; }
echo "PASS: card insert and select round-trip"

# Test 5: due cards query works
DUE=$(sqlite3 "${DB}" \
  "SELECT COUNT(*) FROM card_state WHERE due_date <= date('now');")
[ "${DUE}" -eq 1 ] || { echo "FAIL: due cards query returned ${DUE}"; exit 1; }
echo "PASS: due cards query returns correct count"

# Cleanup
rm "${DB}"

echo ""
echo "All smoke tests passed."
