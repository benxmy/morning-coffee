# Webex Triage Integration

Morning-coffee can consume a pre-computed daily triage file that summarizes your messaging activity (Webex, Slack, Teams, etc.) into prioritized action categories.

## How It Works

A separate agent/script runs on a schedule (e.g., 8:30 AM weekdays) and:
1. Fetches messages from your configured spaces/channels
2. Triages them into priority categories using an LLM
3. Writes a markdown file to a known location

Morning-coffee reads this file at plan time. If the file doesn't exist or is stale, it's skipped gracefully.

## Configuration

Add the triage path to your `~/.config/morning-coffee/providers.yaml`:

```yaml
triage:
  path: "~/Projects/webex-agent/output/{date}-triage.md"
  description: "Webex daily triage (pre-computed at 8:30am)"
```

The `{date}` placeholder is replaced with today's `YYYY-MM-DD`.

## Expected File Format

See [triage-format.md](./triage-format.md) for the full specification.

## Reference Implementation

The reference implementation is a Python-based Webex triage agent:
- **Repository**: [webex-agent](https://github.com/benxmy/webex-agent)
- **Runtime**: Python 3.10+, runs via LaunchD (macOS) or cron (Linux)
- **LLM**: Uses Claude (via Bedrock or direct API) for triage decisions
- **Schedule**: 8:30 AM weekdays via LaunchD plist

## Training & Evolving Your Triage Agent

The triage agent is something you'll want to tune over time. Here's how:

### Initial Setup (Week 1)

1. Start with broad defaults — monitor all your active spaces/channels
2. Run the agent and review its output each morning
3. Note false positives (things marked "Blocked on You" that aren't really) and false negatives (important things missed)

### Preferences File

The reference implementation uses a `preferences.md` file to shape its decisions:

```markdown
# Triage Preferences

## High-Priority Spaces
- Project Alpha (any message from leads = Blocked on You)
- Customer Support Escalation (always surface)

## Low-Priority / Ignore
- Social/water-cooler channels
- Automated bot messages
- Weekly newsletter digests

## Keywords That Escalate
- "waiting on you", "need your input", "blocker"
- Your name mentioned directly

## People Who Escalate
- Your manager
- Skip-level leadership
- External customers/partners
```

### Tuning (Weeks 2-4)

- Review triage output for 5 minutes each morning
- Ask yourself: "Did it miss anything important? Did it flag anything I don't care about?"
- Update `preferences.md` based on patterns:
  - Spaces that are always noise → add to ignore list
  - People whose messages are always important → add to escalation list
  - Keywords that trigger false positives → exclude them

### Ongoing Evolution

- **Monthly review**: Is the triage still useful? Are the categories right?
- **Seasonal changes**: Projects end, new ones start — update space lists
- **Wrap-up integration**: Consider adding a weekly "is my triage working?" check to your `/wrap-up` routine
- **New channels**: When you join a new space, decide its priority level and update preferences

### Building Your Own

If you don't use Webex, you can build a triage agent for any messaging platform. The requirements:
1. Fetch messages from your platform's API (Slack, Teams, Discord, etc.)
2. Send them through an LLM with your preferences for prioritization
3. Write the output in the [expected format](./triage-format.md)
4. Schedule it to run before your morning planning time

The morning-coffee skill doesn't care how the file is generated — only that it exists and follows the format.
