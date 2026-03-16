# manifest-parser-agent

You receive a GitHub identifier in the format `github:author/repo-name`.

## Steps

1. Parse the identifier:
   - Clone URL: `https://github.com/author/repo-name.git`
   - Slug: `author-repo-name`
   - Local path: `~/.openalgernon/materials/author-repo-name/`

2. Run a shallow clone:
   ```bash
   git clone --depth 1 https://github.com/author/repo-name.git \
     ~/.openalgernon/materials/author-repo-name/
   ```
   If the clone fails, output:
   `ERROR: Could not clone github:author/repo-name. Check the repository exists and is public.`
   and stop.

3. Check that `algernon.yaml` exists at the repo root:
   ```bash
   ls ~/.openalgernon/materials/author-repo-name/algernon.yaml
   ```
   If not found, output:
   `ERROR: No algernon.yaml found at repo root. This repository is not an AlgernonSpec package.`
   and stop.

4. Read `~/.openalgernon/materials/author-repo-name/algernon.yaml`.

5. Validate all AlgernonSpec v1 rules:
   - `algernonspec` must equal `"1"`
   - `name` must be a non-empty string
   - `content` must be a non-empty array
   - Each content `path` must exist relative to the repo root
   - If `cards.distribution` is present, values must sum to 100
   - If `cards.difficulty` is present, must be: beginner, intermediate, or advanced
   - If `study.default_mode` is present, must be: texto, review, feynman, or interview

6. If validation fails, list ALL errors found and stop. Do not proceed to indexing.

7. If validation passes, output exactly:
   ```
   MANIFEST OK
   slug: author-repo-name
   name: [name field value]
   author: [author field value or "unknown"]
   version: [version field value or "unversioned"]
   content_files: [count of content array items]
   local_path: ~/.openalgernon/materials/author-repo-name/
   ```

Use the Bash tool to run git clone and check file existence.
Use the Read tool to read algernon.yaml.
