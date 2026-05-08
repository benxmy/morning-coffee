# Triage File Format Specification

Morning-coffee expects a markdown file with the following structure. The file should be generated daily by your triage agent.

## File Location

Configured in `~/.config/morning-coffee/providers.yaml` under `triage.path`. The `{date}` placeholder is replaced with `YYYY-MM-DD`.

Example: `~/Projects/webex-agent/output/2026-05-07-triage.md`

## Required Structure

```markdown
# Daily Triage — YYYY-MM-DD

## Blocked on You
- [space/channel name] Summary of what needs your action. Who's waiting.

## Decisions Made Without You
- [space/channel name] Summary of what was decided. How it affects your work.

## Opportunities
- [space/channel name] Something worth engaging with proactively. Why it matters.

## FYI
- [space/channel name] Informational only, no action needed. Brief context.
```

## Section Definitions

### Blocked on You
Messages where someone is explicitly waiting for your response, input, or action. These are the most urgent — someone can't proceed without you.

**Examples:**
- Direct questions addressed to you
- Review requests pending your approval
- People waiting for information only you can provide

### Decisions Made Without You
Things that were decided in spaces you're in, that affect your active work, but happened without your input. Important for awareness — you may want to weigh in or adjust your plans.

**Examples:**
- Architecture decisions in a project you own
- Timeline changes announced by leadership
- Scope changes to features you're building

### Opportunities
Places where your input would be valuable but isn't explicitly requested. Proactive engagement that could help your projects or relationships.

**Examples:**
- Someone asking a question you're uniquely qualified to answer
- A discussion about a topic you're the expert on
- A new initiative that aligns with your goals

### FYI
Context that's good to know but requires no action. Background information that might inform your day.

**Examples:**
- Status updates from teams you follow
- General announcements
- Social/culture messages that are nice to know

## Rules

1. Each section can have zero or more items
2. Empty sections should still have the heading (so the parser works consistently)
3. Items should be one line each — concise, not verbose
4. Include the source (space/channel name) in brackets at the start
5. Include who's involved when relevant
6. The date in the heading must match the filename date

## Optional Extensions

You can add additional sections if your triage agent surfaces them:

```markdown
## Deadlines Today
- [source] Specific deadlines or due dates mentioned

## Follow-ups Due
- [source] Things you committed to that are now due
```

Morning-coffee will read and incorporate any additional sections it finds, even if they're not in the base spec.
