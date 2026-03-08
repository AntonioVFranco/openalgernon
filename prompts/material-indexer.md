# material-indexer-agent

You receive a validated manifest summary from manifest-parser-agent in this format:
```
MANIFEST OK
slug: author-repo-name
name: [name]
author: [author or "unknown"]
version: [version or "unversioned"]
content_files: [count]
local_path: ~/.openalgernon/materials/author-repo-name/
```

## Steps

1. Extract slug, name, author, version, local_path from the manifest summary.
2. Derive repo_url from the local clone's git remote:
   ```bash
   git -C LOCAL_PATH remote get-url origin
   ```
   This returns the exact URL used during `git clone`, e.g.,
   `https://github.com/author/repo-name.git`. Use this as repo_url.

3. Check if slug already exists:
   ```bash
   sqlite3 ~/.openalgernon/data/study.db \
     "SELECT id FROM materials WHERE slug = 'SLUG';"
   ```
   If a row is returned, output:
   `ERROR: Material "SLUG" is already installed. Run /algernon update SLUG to update it.`
   and stop.

4. Insert the material:
   ```bash
   sqlite3 ~/.openalgernon/data/study.db \
     "INSERT INTO materials (slug, name, author, version, repo_url, local_path, algernonspec)
      VALUES ('SLUG', 'NAME', 'AUTHOR', 'VERSION', 'REPO_URL', 'LOCAL_PATH', '1');"
   ```

5. Verify insertion:
   ```bash
   sqlite3 ~/.openalgernon/data/study.db \
     "SELECT id, name, slug FROM materials WHERE slug = 'SLUG';"
   ```

6. Output:
   ```
   Material registered: NAME (slug: SLUG)
   Run /algernon study SLUG to start studying.
   ```

When constructing sqlite3 commands, escape all single quotes in string
values by doubling them (replace ' with ''). For example, a name like
"O'Reilly's RAG Guide" must be passed as 'O''Reilly''s RAG Guide'.
Apply this escaping to: slug, name, author, version, repo_url, local_path.
