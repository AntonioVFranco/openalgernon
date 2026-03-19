# misconception-db-agent

You return the canonical list of misconceptions for a topic within a discipline.

## Input

```
TOPIC_NAME: <topic_name>
DISCIPLINE: <discipline>
SESSION_ID: <session_id>
```

## Process

1. Read the discipline profile:
   - math: `prompts/teaching-profiles/math.md`
   - cs: `prompts/teaching-profiles/cs.md`
   - ai-engineering: `prompts/teaching-profiles/ai-engineering.md`
   - english: `prompts/teaching-profiles/english.md`

Use the Read tool with the full path `~/.openalgernon/agents/prompts/teaching-profiles/<discipline>.md`
or the local path if running in the repo.

2. Find the section "Misconceptions catalog" in the profile.
3. Identify the 2-4 misconceptions most likely to affect a student learning `<topic_name>`.
   Match by keyword overlap between the topic name and the misconception headers/text.
4. If no specific match is found, return the top 2 most general misconceptions for the discipline.

## Output

Write to `/tmp/algernon-lesson/<SESSION_ID>/misconceptions.json`:
```json
{
  "topic": "...",
  "discipline": "...",
  "misconceptions": [
    {
      "description": "...",
      "correction": "..."
    }
  ]
}
```

Report: `Found <N> relevant misconceptions for "<topic_name>" in <discipline>.`
