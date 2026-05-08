---
name: morning-coffee
description: Daily focus picker. Reads your workboard, pulls today's calendar and recent emails, helps you pick 2-3 things to focus on today, flags stalled work, and protects time for deep work.
user-invocable: true
allowed-tools:
  - Read(~/.claude/projects/*/memory/workboard.md)
  - Read(~/.claude/projects/*/memory/MEMORY.md)
  - Read(~/.claude/projects/*/memory/*.md)
  - Read(~/.config/morning-coffee/*)
  - Edit(~/.claude/projects/*/memory/workboard.md)
  - Edit(~/.claude/projects/*/memory/*.md)
  - Write(~/.claude/projects/*/memory/daily/*.md)
  - Bash(date *)
  - Bash(cat ~/.config/morning-coffee/*)
  - Bash(~/.config/claude-graph/bin/msgraph *)
  - Bash(gcalcli *)
  - Bash(gmail-cli *)
---

# /morning-coffee — Daily Focus Picker

Arguments passed: `$ARGUMENTS`

## Path Resolution

Your memory files live at `~/.claude/projects/<project-slug>/memory/` where `<project-slug>` is derived from your home directory (e.g., `-Users-jane` on macOS, `-home-jane` on Linux). The setup script creates these directories automatically. Throughout this skill, paths reference this location — Claude Code resolves the correct project slug at runtime.

## Provider Setup

Before starting, check if `~/.config/morning-coffee/providers.yaml` exists. If it does, read it to get available provider commands. If it doesn't exist, proceed in workboard-only mode (skip calendar, email, and triage steps gracefully).

Provider YAML format:
```yaml
calendar:
  command: "shell command that returns today's meetings"
email:
  command: "shell command that returns recent emails"
triage:
  path: "path/to/{date}-triage.md"
```

## Steps

1. **Read the workboard** at `~/.claude/projects/<project-slug>/memory/workboard.md`.
   Also read MEMORY.md for any specific reminders due today.

2. **Get today's date and pull external context** — run all available providers in parallel:

   **Always run:**
   - `date '+%Y-%m-%d (%A)'`

   **Run if configured in providers.yaml:**
   - Calendar provider command (today's meetings)
   - Email provider command (recent emails)

   If any provider command fails (token expired, not configured), skip gracefully — these are additive, not required.

   **Message triage** — if `triage.path` is configured in providers.yaml:
   Read the file at that path (replace `{date}` with today's YYYY-MM-DD).
   If the file doesn't exist or is from a previous day, say "Message triage not yet available" and continue without it.

   The triage contains prioritized groups: Blocked on You, Decisions Made Without You, Opportunities, and FYI.

3. **Show the day at a glance** — before diving into the workboard, show what today looks like:

   **Calendar** (skip if no provider configured):
   - List today's meetings in a compact table: time, duration, subject
   - Flag meetings that need prep (1:1s, external stakeholders, presentations)
   - Note free blocks > 1 hour — these are where focus work happens
   - If the day is meeting-heavy (>4 hours of meetings), call that out explicitly

   **Email** (skip if no provider configured):
   - Scan for anything that needs action today:
     - Direct requests or questions addressed to you
     - Emails from leadership (flag as high-priority context)
     - Meeting follow-ups or pre-reads for today's meetings
   - Summarize in 2-3 bullets max — just the ones that matter for today's decisions
   - If nothing notable, just say "Inbox is clean" and move on

   **Message Triage** (skip if no triage file available):
   - Show the triage output organized by priority:
     - **Blocked on You** — people waiting for your response (most urgent)
     - **Decisions Made Without You** — things decided that affect your work
     - **Opportunities** — where your input could help proactively
     - **FYI** — context only, no action needed
   - Keep it compact — show the space/channel name, who's involved, and what's needed
   - If triage returned nothing or failed, just say "Messages are quiet" and move on

4. **Route triage context to projects** (optional — only if triage data exists AND project memory files exist):
   Check whether any triage items relate to active workboard projects. For each match:
   - Read the project's memory file
   - Append a dated context note with the relevant signal
   - Use `Edit` to append under a `## Recent Context` section (create if it doesn't exist)
   - Keep entries concise: one line per item, dated, with the source and key info

   Example:
   ```
   ## Recent Context
   - 2026-05-04: [Team Chat] Alice shared updated slides — review before Friday deadline
   - 2026-05-04: [DM - Bob] Still no response on the API question — 5 days waiting
   ```

5. **Show a quick status scan** — go through every Active workboard item and flag:
   - **Stalled**: anything where the "next step" hasn't changed in 3+ days, or where a blocker has been sitting unresolved
   - **Waiting**: items blocked on other people — remind to follow up
   - **Quick wins**: items where the next step is small and concrete (< 30 min)

6. **Ask to pick 2-3 focus items for today.** Frame it as:
   > "Here's what's on your board. What do you want to focus on today?"

   Then list the active items grouped by category, showing just the name and next step for each.

   After listing, offer a suggestion based on:
   - What has external stakeholders waiting (highest priority)
   - What aligns with today's meetings (prep that would be useful before a call)
   - What's been stalled longest
   - What fits in the free blocks between meetings
   - What's a quick win that would feel good to clear

7. **Protect deep work time.** Always ask:
   > "Do you want to block any time for deep work today?"

   Don't make this optional or an afterthought — treat it like a real commitment. If the calendar has a good free block, suggest it specifically.

8. **Surface any due reminders** from MEMORY.md's Specific Reminders section (date matches today).

9. **Update the workboard** — set `Last reviewed: YYYY-MM-DD` at the top.

10. **Save the plan** — once focus items are confirmed, write them to
   `~/.claude/projects/<project-slug>/memory/daily/YYYY-MM-DD.md` (using today's date).
   Format:
   ```
   # Today's Plan — YYYY-MM-DD (Day)

   ## Meetings
   - HH:MM — Subject (note if prep needed)
   ...

   ## Focus Items
   1. **Item** — brief context
   2. **Item** — brief context
   ...

   ## Triage Summary
   - Blocked: ...
   - Decisions: ...
   - Opportunities: ...

   ## Email Follow-ups
   - Brief description of any emails needing action

   ## Context Routed to Projects
   - <project> — <what was added>
   ```

## Tone

Be direct and practical, like a good chief of staff. Don't be overly cheerful or add filler. Help see the landscape clearly and make a decision. If the board is overloaded, say so plainly — "You have 15 active items. That's a lot. Want to park some of these?" If the day is packed with meetings, be honest — "You have 5 hours of meetings today. Realistically you'll get one focus block."

## If `$ARGUMENTS` contains a message

Treat it as pre-declared focus items. Log them, update the workboard's last-reviewed date, and confirm the plan for the day. Still pull calendar and emails if available, still flag anything stalled or waiting.
