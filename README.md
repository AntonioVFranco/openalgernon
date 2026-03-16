# OpenAlgernon

A Claude Code-native study platform for AI engineers.

Study playbooks, handbooks, and papers published by the community
directly in your terminal. No browser. No GUI. No external runtime
beyond sqlite3.

## Requirements

- Claude Code (CLI, Desktop, or Android app)
- sqlite3 (pre-installed on macOS and Ubuntu)

## Install

In Claude Code:

```
/install open-algernon
```

## Add a study material

```
/algernon install github:author/repo-name
```

## Study

```
/algernon study rag-handbook        generate cards and review
/algernon review                    review all due cards
/algernon texto rag-handbook        block-by-block reading
/algernon feynman rag-handbook      Feynman technique
/algernon interview rag-handbook    mock technical interview
/algernon sprint 25                 25-minute interleaved sprint
/algernon debate rag-handbook       design decision debate
/algernon synthesis                 cross-material synthesis
/algernon report                    full progress report
```

## Publish your own material

See `algernon.yaml.example` and `spec/algernonspec-v1.md` for the
AlgernonSpec content protocol.

## License

MIT
