# Customization

Morning-coffee is plain markdown — you can edit the skill files directly to change behavior.

## Common Customizations

### Change the Number of Focus Items

In `~/.claude/commands/morning-coffee.md`, step 6 says "pick 2-3 focus items." Change this to whatever works for you:

```markdown
6. **Ask to pick 1-2 focus items for today.**
```

or

```markdown
6. **Ask to pick up to 5 focus items for today.**
```

### Disable Deep Work Time Prompt

If you don't want the deep work question every morning, remove or comment out step 7 in `morning-coffee.md`:

```markdown
<!-- 7. **Protect deep work time.** ... -->
```

### Change "Deep Work" to Something Else

Maybe you want to protect exercise time, learning time, or something else:

```markdown
7. **Protect learning time.** Always ask:
   > "Do you want to block any time for reading/learning today?"
```

### Change Workboard Categories

Edit your `workboard.md` to use whatever categories make sense:

```markdown
## Active — Engineering
## Active — Management
## Active — Learning
## Active — Home
```

The skill reads whatever categories exist — it doesn't enforce a specific set.

### Modify the Daily Plan Format

Edit step 10 in `morning-coffee.md` to change what gets written to the daily plan file. Add sections, remove sections, change the format.

### Change the Tone

The `## Tone` section at the bottom of each skill controls voice and style. Edit to match your preference:

```markdown
## Tone
Be encouraging and supportive. Celebrate small wins. Use emoji occasionally.
```

or

```markdown
## Tone
Be extremely brief. Bullet points only. No questions — just show the data and let me decide.
```

### Add Context Routing to Different File Paths

If you organize project memory files differently, update step 4 in `morning-coffee.md` to match your structure.

### Skip the Status Scan

If you find the stalled/waiting/quick-wins scan noisy, remove step 5 or make it conditional:

```markdown
5. **Status scan** (only show if there are items stalled > 5 days):
```

## Adding Data Sources

### Custom Triage

You can add any data source by writing a script that:
1. Outputs a markdown file in the [triage format](../integrations/triage-format.md)
2. Runs on a schedule before your morning planning

Examples:
- Slack digest (via Slack API)
- GitHub notifications summary
- Jira ticket updates
- Customer support queue

### Additional Provider Keys

Add custom keys to `providers.yaml`:

```yaml
calendar:
  command: "..."
email:
  command: "..."
tasks:
  command: "jira-cli sprint current --format text"
  description: "Current sprint tasks from Jira"
github:
  command: "gh api notifications --jq '.[].subject.title'"
  description: "GitHub notifications"
```

Then modify the morning-coffee skill to check for and use these keys in step 2.

## Advanced: Companion Skills

The daily trio works standalone, but you can extend the ecosystem:

### /yap — Activity Logging

A simple skill that appends timestamped notes to `~/yap-log.md`. When `/wrap-up` runs, it checks this file for context about what you actually did.

```markdown
---
name: yap
description: Log what you're doing right now.
user-invocable: true
allowed-tools:
  - Bash(date *)
  - Edit(~/yap-log.md)
---
# /yap
Append a timestamped entry to ~/yap-log.md with whatever was said.
```

### /cos — Chief of Staff

A cross-project status check that reads the workboard and helps route incoming work, track follow-ups, and give status updates. Useful between morning-coffee and wrap-up when new things come in.

### /prep — Meeting Prep

Pulls context about a person before a 1:1: recent messages, email threads, what you're working on together. Uses the same provider system for email lookups.

## Tips

- **Start minimal**: Use workboard-only mode for a week before adding providers
- **Tune gradually**: Adjust the skill text based on what feels right after a few days
- **The workboard is everything**: If you keep it accurate, the skills work well. If it's stale, they won't help.
- **Don't over-engineer**: If something in the skill isn't useful for you, delete it. These are your tools.
