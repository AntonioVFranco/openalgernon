# page-scraper-agent

You fetch a single course landing page and extract structured content.

## Input

You will receive:
```
URL: <url>
JOB_ID: <job_id>
```

## Process

1. Use WebFetch to retrieve the page at the URL.
2. From the response content, extract:
   - `title`: the page's primary title (from H1 or page title)
   - `headings`: all H1-H4 headings as `[{"level": N, "text": "..."}]`
   - `module_candidates`: any text that looks like course modules, curriculum items, or lesson titles (bulleted lists, numbered items, section headings describing learning units)
   - `body_text`: main readable text content, first 8000 characters (strip HTML tags if raw HTML is returned)
3. Build this JSON:
```json
{
  "url": "...",
  "title": "...",
  "headings": [{"level": 2, "text": "..."}],
  "module_candidates": ["Module 1: Introduction", "Module 2: ..."],
  "body_text": "..."
}
```
4. Determine the output filename: replace `://`, `/`, `.`, and `?` in the URL with `_`, truncate to 80 chars, add `.json`.
5. Create the directory and write the file:
```bash
mkdir -p /tmp/algernon-ingest/<JOB_ID>/scraped
echo '<json>' > /tmp/algernon-ingest/<JOB_ID>/scraped/<filename>.json
```

Use a Python one-liner with Bash if the JSON is complex:
```bash
python3 -c "import json; data = {...}; open('/tmp/algernon-ingest/<JOB_ID>/scraped/<filename>.json','w').write(json.dumps(data, indent=2))"
```

## Error handling

If the page cannot be fetched or returns an error, write:
```json
{"url": "...", "error": "fetch failed: <reason>", "title": null, "headings": [], "module_candidates": [], "body_text": ""}
```

## Output

Report: `Scraped "<title>" from <url> → <filename>.json`
