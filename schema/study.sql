-- OpenAlgernon study database schema
-- Requires SQLite 3.38+ for math functions (EXP, POW, LN)

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS materials (
  id            INTEGER PRIMARY KEY,
  slug          TEXT    NOT NULL UNIQUE,
  name          TEXT    NOT NULL,
  author        TEXT,
  version       TEXT,
  repo_url      TEXT,
  local_path    TEXT    NOT NULL,
  algernonspec  TEXT    NOT NULL,
  installed_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS decks (
  id          INTEGER PRIMARY KEY,
  material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
  name        TEXT    NOT NULL,
  topic       TEXT,
  created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS cards (
  id           INTEGER PRIMARY KEY,
  deck_id      INTEGER NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
  type         TEXT    NOT NULL CHECK(type IN ('flashcard','dissertative','argumentative')),
  front        TEXT    NOT NULL,
  back         TEXT    NOT NULL,
  tags         TEXT    NOT NULL DEFAULT '[]',
  source_file  TEXT,
  source_title TEXT,
  created_at   TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS card_state (
  card_id     INTEGER PRIMARY KEY REFERENCES cards(id) ON DELETE CASCADE,
  stability   REAL    NOT NULL DEFAULT 0.4,
  difficulty  REAL    NOT NULL DEFAULT 0.3,
  due_date    TEXT    NOT NULL DEFAULT (date('now')),
  last_review TEXT,
  reps        INTEGER NOT NULL DEFAULT 0,
  lapses      INTEGER NOT NULL DEFAULT 0,
  state       TEXT    NOT NULL DEFAULT 'new'
    CHECK(state IN ('new','learning','review','relearning'))
);

CREATE TABLE IF NOT EXISTS reviews (
  id             INTEGER PRIMARY KEY,
  card_id        INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
  reviewed_at    TEXT    NOT NULL DEFAULT (datetime('now')),
  grade          INTEGER NOT NULL CHECK(grade IN (1, 3)),
  response       TEXT,
  ai_feedback    TEXT,
  misconception  TEXT,
  scheduled_days REAL,
  elapsed_days   REAL
);

-- FSRS-4.5 next interval.
-- Stored here as documentation; fsrs-agent executes this via sqlite3 CLI.
--
-- next_interval = ROUND(stability)
--
-- Derivation:
--   The general formula is: I = S/FACTOR * (R^(1/DECAY) - 1)
--   With FSRS-4.5 constants DECAY=-0.5, FACTOR=19/81=0.2346, R=0.9:
--     I = S/0.2346 * (0.9^(-2) - 1)
--       = S/0.2346 * (19/81)
--       = S/0.2346 * 0.2346
--       = S
--
--   This simplification is by design: in FSRS-4.5, the stability value S
--   is defined as the number of days to reach 90% retention. Therefore
--   ROUND(stability) is the exact interval for the 90% target.
--
--   For learning/relearning states, the interval is hardcoded to 1 day
--   regardless of stability.

CREATE INDEX IF NOT EXISTS idx_card_state_due ON card_state(due_date);
CREATE INDEX IF NOT EXISTS idx_cards_deck     ON cards(deck_id);
CREATE INDEX IF NOT EXISTS idx_reviews_card   ON reviews(card_id);

-- Teaching engine tables

CREATE TABLE IF NOT EXISTS roadmaps (
    id           INTEGER PRIMARY KEY,
    material_id  INTEGER REFERENCES materials(id) ON DELETE CASCADE,
    discipline   TEXT NOT NULL,
    source_urls  TEXT NOT NULL,  -- JSON array of URLs
    modules_json TEXT NOT NULL,  -- full structured roadmap JSON
    created_at   TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS lesson_state (
    id               INTEGER PRIMARY KEY,
    material_id      INTEGER REFERENCES materials(id) ON DELETE SET NULL,
    module_id        TEXT NOT NULL,
    topic_id         TEXT NOT NULL,
    lesson_plan_json TEXT NOT NULL,
    technique_used   TEXT NOT NULL,
    student_level    TEXT NOT NULL
        CHECK(student_level IN ('beginner', 'intermediate', 'advanced')),
    status           TEXT NOT NULL DEFAULT 'active'
        CHECK(status IN ('active', 'completed', 'paused')),
    created_at       TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS comprehension_log (
    id            INTEGER PRIMARY KEY,
    lesson_id     INTEGER NOT NULL REFERENCES lesson_state(id) ON DELETE CASCADE,
    response_text TEXT NOT NULL,
    score         REAL,
    misconception TEXT,
    next_action   TEXT NOT NULL
        CHECK(next_action IN ('continue', 'deepen', 'pivot', 'advance', 'pending')),
    logged_at     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_roadmaps_discipline ON roadmaps(discipline);
CREATE INDEX IF NOT EXISTS idx_lesson_state_status ON lesson_state(status);
CREATE INDEX IF NOT EXISTS idx_comprehension_lesson ON comprehension_log(lesson_id);
