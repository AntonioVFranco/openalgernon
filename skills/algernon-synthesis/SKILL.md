---
name: algernon-synthesis
description: >
  Cross-material knowledge synthesis session for OpenAlgernon. Use when the
  user runs `/algernon synthesis`, says "quero conectar os materiais",
  "sintese entre materiais", "como X se relaciona com Y", "visao geral do
  curriculo", "integrar o conhecimento", or "ver o quadro geral". Requires at
  least 2 materials with reviewed cards. Surfaces conceptual bridges across
  materials and ends with a production scenario challenge.
---

# algernon-synthesis

You run a cross-material synthesis session. The goal is to build explicit
connections between concepts learned in different materials — the kind of
holistic understanding that separates someone who memorized facts from
someone who can actually design systems.

## Constants

```bash
ALGERNON_HOME="${ALGERNON_HOME:-$HOME/.openalgernon}"
DB="${ALGERNON_HOME}/data/study.db"
NOTION_CLI="${NOTION_CLI:-notion-cli}"
```

## Step 1 — Check Eligibility

```bash
sqlite3 "$DB" \
  "SELECT m.slug, m.name, COUNT(r.id) AS review_count
   FROM materials m
   JOIN decks d ON d.material_id = m.id
   JOIN cards c ON c.deck_id = d.id
   JOIN reviews r ON r.card_id = c.id
   GROUP BY m.id
   HAVING review_count > 0
   ORDER BY review_count DESC;"
```

If fewer than 2 materials have reviews:
"Synthesis requires at least 2 studied materials. Study more material first."

## Step 2 — Identify Cross-Material Concept Overlaps

From the tags and topics of reviewed cards across all studied materials,
identify 3-5 concept pairs that appear in multiple materials but carry a
different meaning or role in each context.

Examples of strong synthesis pairs:
- "evaluation" in RAG vs LLMOps contexts
- "chunking" in embedding vs RAG contexts
- "latency" in inference vs retrieval contexts
- "context" in prompt engineering vs agent memory contexts
- "retrieval" in BM25 vs vector similarity vs caching contexts

Prefer pairs where the same word genuinely means something different — that
contrast is the richest learning opportunity.

## Step 3 — Synthesis Questions

For each concept pair, ask:

AskUserQuestion (free text):
> "[CONCEPT] appears in both [MATERIAL_A] and [MATERIAL_B]. How does the meaning
> or role of [CONCEPT] differ between these two contexts? Where do they overlap?"

After each answer, give brief feedback:
- Name what the user connected well.
- Name any distinction they missed (one sentence only — do not lecture).

## Step 4 — Production Scenario Challenge

AskUserQuestion (free text):
> "If you were building a production AI system, how would the knowledge from
> [MATERIAL_A] and [MATERIAL_B] work together? Give a concrete scenario with
> specific design decisions."

Evaluate for:
1. Coherence — does the scenario make technical sense?
2. Specificity — are there real design decisions, not just buzzwords?
3. Correct use — are terms from both materials used accurately?

## Step 5 — Summary

```
Synthesis session complete.
Materials covered: [list]
Conceptual bridges built well: [list]
Bridges that need reinforcement: [list]
```

### Save to Notion (optional)

If `$NOTION_CLI` is available and `$NOTION_PAGE_ID` is set:

```bash
"$NOTION_CLI" append --page-id "$NOTION_PAGE_ID" --content "MARKDOWN"
```

### Save Memory

```bash
echo "[HH:MM] synthesis session | Materials: LIST | Needs reinforcement: LIST" \
  >> "${ALGERNON_HOME}/memory/conversations/YYYY-MM-DD.md"
```
