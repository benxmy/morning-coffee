# Architecture

How morning-coffee works under the hood.

## Design Principles

1. **Workboard as backbone** — everything flows from a single project tracking file
2. **Graceful degradation** — every external source is optional; the core always works
3. **Provider abstraction** — calendar/email integrations are pluggable
4. **Daily loop** — plan → execute → review → carry forward
5. **Human in the loop** — the skill suggests, you decide

## Data Flow

```
                    ┌─────────────────────┐
                    │   providers.yaml    │
                    │  (calendar, email,  │
                    │   triage config)    │
                    └────────┬────────────┘
                             │
                             ▼
┌──────────┐     ┌──────────────────────┐     ┌──────────────┐
│workboard │────▶│   /morning-coffee    │────▶│ daily/       │
│   .md    │     │                      │     │ YYYY-MM-DD.md│
└──────────┘     │ 1. Read workboard    │     └──────┬───────┘
                 │ 2. Pull providers    │            │
┌──────────┐     │ 3. Show day-at-glance│            │
│MEMORY.md │────▶│ 4. Status scan       │            ▼
│(reminders│     │ 5. Pick focuses      │     ┌──────────────┐
└──────────┘     │ 6. Write daily plan  │     │   /today     │
                 └──────────────────────┘     │ (read-only)  │
                             │                └──────────────┘
                             │                       │
                             ▼                       ▼
                 ┌──────────────────────┐     ┌──────────────┐
                 │  workboard.md        │◀────│  /wrap-up    │
                 │  (Last reviewed      │     │              │
                 │   updated)           │     │ Compare plan │
                 └──────────────────────┘     │ vs actual    │
                                              │ Update board │
                                              └──────────────┘
```

## File Responsibilities

### workboard.md
- **Owner**: User (maintained via `/morning-coffee` and `/wrap-up`)
- **Purpose**: Single source of truth for all project state
- **Format**: Markdown with structured items (state, next step, blocker, waiting-on)
- **Updated by**: `/wrap-up` (item states), `/morning-coffee` (last reviewed date)

### providers.yaml
- **Owner**: User (set up once, rarely changed)
- **Purpose**: Maps data sources to shell commands
- **Location**: `~/.config/morning-coffee/providers.yaml`
- **Read by**: `/morning-coffee` at runtime
- **Missing = workboard-only mode**

### daily/YYYY-MM-DD.md
- **Owner**: `/morning-coffee` (creates), `/wrap-up` (appends)
- **Purpose**: Today's plan — focus items, meeting notes, triage summary
- **Read by**: `/today`, `/wrap-up`
- **One per day**, never modified by morning-coffee after creation

### MEMORY.md
- **Owner**: User and `/wrap-up`
- **Purpose**: Specific and general reminders
- **Read by**: `/morning-coffee` (surfaces due reminders)
- **Updated by**: `/wrap-up` (adds carry-forwards, removes completed)

## Provider Resolution

```
/morning-coffee starts
    │
    ├── Read ~/.config/morning-coffee/providers.yaml
    │   ├── File exists?
    │   │   ├── Yes → parse YAML
    │   │   │   ├── calendar key exists? → run command → use output
    │   │   │   ├── email key exists? → run command → use output
    │   │   │   └── triage key exists? → read file at path → use contents
    │   │   │
    │   │   │   (any command fails → skip that source, continue)
    │   │   │
    │   │   └── No keys → workboard-only mode
    │   │
    │   └── No → workboard-only mode (no error)
    │
    └── Continue with whatever context is available
```

## The Daily Loop

### Morning (5-10 minutes)
1. Run `/morning-coffee`
2. Review the day at a glance
3. Pick 2-3 focus items
4. Commit to deep work time
5. Start working

### During the Day
- Run `/today` anytime to recall your plan
- The plan file is a static reference — no re-processing

### End of Day (2-3 minutes)
1. Run `/wrap-up`
2. Mark items: done / partial / didn't get to it
3. Capture unplanned work
4. Decide on carry-forwards
5. Workboard updated automatically

### Between Days
- Workboard carries state forward
- MEMORY.md holds specific reminders for future dates
- Triage agent generates tomorrow's file overnight/early morning

## Extension Points

### Adding a new provider
1. Create `providers/your-provider/commands.yaml`
2. Create `providers/your-provider/setup.md`
3. User copies commands.yaml to `~/.config/morning-coffee/providers.yaml`

### Adding a new triage source
1. Generate a markdown file matching [triage-format.md](../integrations/triage-format.md)
2. Configure the path in providers.yaml under `triage.path`
3. Morning-coffee reads it — doesn't care how it was generated

### Adding a new data source (beyond calendar/email/triage)
The skill reads providers.yaml. To add a new source type:
1. Add a new key to providers.yaml (e.g., `tasks:`)
2. Modify the morning-coffee skill to check for and use the new key
3. The graceful-skip pattern means old configs still work

## Why Not a Plugin?

This is distributed as skills + config rather than a Claude Code plugin because:
- Skills are plain markdown — easy to read, modify, and understand
- No build step or dependency management
- Users can customize the workflow by editing the skill files directly
- The provider system handles external tool integration without plugin APIs
- It's easier to share and fork
