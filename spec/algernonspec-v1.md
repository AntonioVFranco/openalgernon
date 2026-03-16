# AlgernonSpec v1

AlgernonSpec is the community content protocol for OpenAlgernon.
It defines how engineers package and distribute study materials
compatible with the OpenAlgernon study platform.

## Required Fields

| Field         | Type   | Description                                      |
|---------------|--------|--------------------------------------------------|
| algernonspec  | string | Protocol version. Must be "1".                   |
| name          | string | Human-readable material name.                    |
| content       | array  | List of content items (see below).               |

## Optional Fields

| Field       | Type   | Description                                           |
|-------------|--------|-------------------------------------------------------|
| author      | string | Author name or GitHub handle.                         |
| version     | string | Semantic version of this material (e.g., "1.0.0").   |
| description | string | One-sentence description.                             |
| tags        | array  | List of topic tags (lowercase strings).               |
| license     | string | SPDX license identifier (e.g., "CC-BY-4.0").         |
| cards       | object | Card generation configuration (see below).            |
| study       | object | Default study configuration (see below).              |

## Content Item Fields

Each item in the `content` array:

| Field | Type   | Description                                |
|-------|--------|--------------------------------------------|
| title | string | Section or chapter title.                  |
| path  | string | Relative path from repo root to the file.  |
| type  | string | Content type. Currently only "text".       |

Content files must be plain Markdown (.md) or plain text (.txt).
PDF support is not provided in v1.

## Cards Configuration

When the `cards` block is present, all four sub-fields are required.

```yaml
cards:
  distribution: [50, 30, 20]   # % split: flashcard / dissertative / argumentative
  levels: ["N1", "N2", "N3"]   # learning levels to generate (allowed: N1, N2, N3)
  focus: ["term1", "term2"]    # key concepts to emphasize in card generation
  difficulty: "intermediate"   # beginner | intermediate | advanced
```

## Study Configuration

When the `study` block is present, both sub-fields are required.

```yaml
study:
  default_mode: "texto"   # texto | review | feynman | interview
  language: "english"     # language of the material content
```

## Slug Generation

The installation slug is derived from the GitHub path:
`github:author/repo-name` becomes slug `author-repo-name`.
The slug must be unique within the user's OpenAlgernon installation.

## Validation Rules

1. `algernonspec` must equal `"1"`.
2. `name` must be a non-empty string.
3. `content` must be a non-empty array.
4. Each content item `type` must be `"text"` (the only supported type in v1).
5. Each content `path` must exist in the repository.
6. `cards.distribution` must sum to 100.
7. `cards.levels` must be a non-empty array containing only values from: `"N1"`, `"N2"`, `"N3"`.
8. `cards.difficulty` must be one of: `beginner`, `intermediate`, `advanced`.
9. `study.default_mode` must be one of: `texto`, `review`, `feynman`, `interview`.
