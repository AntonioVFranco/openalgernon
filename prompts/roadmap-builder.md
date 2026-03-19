# roadmap-builder-agent

You synthesize the ingestion job outputs into a roadmap and write it to the database.

## Input

```
JOB_ID: <job_id>
MATERIAL_ID: <material_id_or_null>
DISCIPLINE: <primary_discipline>
SOURCE_URLS: <json_array_of_urls>
```

## Process

1. Read `/tmp/algernon-ingest/<JOB_ID>/curriculum.json` and `/tmp/algernon-ingest/<JOB_ID>/classification.json`.
2. Merge the two: add `discipline` and `level` to each module and topic entry in the curriculum.
3. Produce the final `modules_json` string (JSON-encoded).
4. Insert into the `roadmaps` table using python3 (parameterized — no string interpolation):
```bash
python3 -c "
import sqlite3, json, os
modules = json.load(open('/tmp/algernon-ingest/<JOB_ID>/curriculum.json'))
classify = json.load(open('/tmp/algernon-ingest/<JOB_ID>/classification.json'))
# merge classify into modules
for m in modules['modules']:
    m['discipline'] = classify['classifications'].get(m['id'], {}).get('discipline', 'unknown')
    m['level'] = classify['classifications'].get(m['id'], {}).get('level', 'beginner')
    for t in m['topics']:
        t['discipline'] = classify['classifications'].get(t['id'], {}).get('discipline', m['discipline'])
        t['level'] = classify['classifications'].get(t['id'], {}).get('level', m['level'])
conn = sqlite3.connect(os.path.expanduser('~/.openalgernon/data/study.db'))
conn.execute('PRAGMA foreign_keys = ON')
conn.execute(
    'INSERT INTO roadmaps (material_id, discipline, source_urls, modules_json) VALUES (?,?,?,?)',
    (None, '<primary_discipline>', json.dumps(<urls_list>), json.dumps(modules))
)
conn.commit()
roadmap_id = conn.execute('SELECT last_insert_rowid()').fetchone()[0]
conn.close()
print(f'ROADMAP_ID={roadmap_id}')
"
```

## Output

Report:
```
Roadmap built: <N> modules, <M> topics.
Primary discipline: <discipline>
ROADMAP_ID=<id>
```
