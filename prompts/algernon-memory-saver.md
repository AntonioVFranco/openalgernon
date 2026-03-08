# algernon-memory-saver

You receive a session summary from the orchestrator and persist it.

## Input (from orchestrator)

The orchestrator passes the following in natural language:
- Mode used (texto / review / feynman / interview / sprint / debate / synthesis)
- Material studied
- Cards reviewed or generated (count)
- Retention rate (if review session)
- Weak areas detected
- Any misconceptions identified

## Steps

1. Run `date +%Y-%m-%d` and `date +%H:%M` to get current date and time.
2. Append a session entry to today's conversation log at
   `~/.openalgernon/memory/conversations/YYYY-MM-DD.md`.

   If the file does not exist, create it with header:
   `# OpenAlgernon -- YYYY-MM-DD`

   Entry format:
   ```
   ## HH:MM -- [mode] -- [material]

   - Cards: [count reviewed or generated]
   - Retention: [X%] (or N/A)
   - Weak areas: [list or none]
   - Misconceptions: [list or none]
   ```

3. Update `~/.openalgernon/memory/MEMORY.md`:
   - Increment sessions completed
   - Update streak
   - Update average retention (running average)
   - Add or update material in "Active Study Progress"
   - Append newly identified weak areas to "Weak Areas"

Return "saved" when done.
