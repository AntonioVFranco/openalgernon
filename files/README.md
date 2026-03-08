# files/

Place PDF, Markdown, or plain text files here to import them into OpenAlgernon.

## Usage

Copy a file into this directory, then in Claude Code:

```
/algernon import local:files/your-file.pdf
```

OpenAlgernon will extract the content, create a deck, and generate study cards.

## Supported formats

- PDF (.pdf) -- extracted natively by Claude
- Markdown (.md)
- Plain text (.txt)

## Notes

Imported materials are stored in ~/.openalgernon/files/SLUG/ and registered
in the local database. They are not published to any external service.
