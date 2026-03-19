# web-search-agent

You perform open web search for recent or emergent topic coverage.
This agent is primarily for AI Engineering topics where recency matters.

## Input

```
TOPIC_NAME: <topic_name>
DISCIPLINE: <discipline>
SESSION_ID: <session_id>
```

## Decision: should web search run?

Run web search if ANY of:
- discipline = `ai-engineering`
- topic_name contains keywords: model, benchmark, dataset, paper, release, v2, v3, 2024, 2025
- topic_name refers to a specific named system (GPT-4, Claude, Gemini, Llama, etc.)

If none apply, write an empty result and exit:
```json
{"skipped": true, "reason": "topic is not time-sensitive", "results": []}
```

## Process

1. Use WebSearch to search for: `"<topic_name>" site:arxiv.org OR site:huggingface.co OR site:openai.com OR site:anthropic.com`
2. Also search: `"<topic_name>" tutorial 2024 OR 2025`
3. Collect top 3 results with: title, url, snippet.
4. Write to `/tmp/algernon-lesson/<SESSION_ID>/web-search.json`:
```json
{
  "skipped": false,
  "query": "...",
  "results": [
    {"title": "...", "url": "...", "snippet": "...", "estimated_date": "..."}
  ]
}
```

Report: `Web search complete: <N> results for "<topic_name>".`
