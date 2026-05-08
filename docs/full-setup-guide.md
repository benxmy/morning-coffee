# Full Setup Guide

This guide replicates the original author's complete daily workflow: Microsoft Graph for calendar/email, Webex triage agent with LaunchD scheduling, SessionStart hook for morning prompting, and the full skill ecosystem.

## Prerequisites

- macOS (for LaunchD scheduling; adapt to cron/systemd for Linux)
- Claude Code installed
- Microsoft 365 account (for calendar/email)
- Webex account (for message triage)
- AWS account with Bedrock access (for the triage agent's LLM calls) — or direct Anthropic API key

## Step 1: Base Installation

```bash
git clone https://github.com/benxmy/morning-coffee.git
cd morning-coffee
./setup.sh
```

Choose provider `1` (duo-msgraph) during setup.

## Step 2: Microsoft Graph (Calendar + Email)

### Install the duo-msgraph Plugin

```bash
# In Claude Code:
claude plugins install duo-msgraph@duo-cc-plugins
```

### Authenticate

```
# In Claude Code:
/msgraph-auth
```

Follow the OAuth flow. You'll need to authorize access to your calendar and email.

### Verify

```bash
# Test calendar
~/.config/claude-graph/bin/msgraph calendar 1

# Test email
~/.config/claude-graph/bin/msgraph email recent 2 --unread --max 20
```

Both should return readable text output.

## Step 3: Webex Triage Agent

### Clone the Reference Implementation

```bash
cd ~/Projects
git clone https://github.com/benxmy/webex-agent.git
cd webex-triage-agent
```

### Configure

```bash
cp .env.example .env
# Edit .env with your credentials:
#   WEBEX_CLIENT_ID=your-client-id
#   WEBEX_CLIENT_SECRET=your-client-secret
#   AWS_PROFILE=your-profile (if using Bedrock)
#   ANTHROPIC_API_KEY=your-key (if using direct API)
```

### Set Up OAuth

```bash
python scripts/oauth.py
# Follow the Webex OAuth flow to get initial tokens
```

### Configure Preferences

Edit `preferences.md` to set:
- Which spaces to monitor
- Priority levels for different spaces
- Keywords that escalate
- People whose messages always matter

### Schedule with LaunchD (macOS)

Create `~/Library/LaunchAgents/com.morning-coffee.triage.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.morning-coffee.triage</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/YOUR_USERNAME/Projects/webex-triage-agent/scripts/run_summary.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>8</integer>
        <key>Minute</key>
        <integer>30</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/morning-coffee-triage.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/morning-coffee-triage.log</string>
    <key>TimeOut</key>
    <integer>400</integer>
</dict>
</plist>
```

Load it:

```bash
launchctl load ~/Library/LaunchAgents/com.morning-coffee.triage.plist
```

### Add Triage to Provider Config

```bash
echo '' >> ~/.config/morning-coffee/providers.yaml
echo 'triage:' >> ~/.config/morning-coffee/providers.yaml
echo '  path: "~/Projects/webex-triage-agent/output/{date}-triage.md"' >> ~/.config/morning-coffee/providers.yaml
echo '  description: "Webex daily triage (pre-computed at 8:30am)"' >> ~/.config/morning-coffee/providers.yaml
```

### Train the Agent

See [integrations/webex-triage.md](../integrations/webex-triage.md) for guidance on tuning your triage preferences over the first few weeks.

## Step 4: SessionStart Hook (Optional)

Add a hook to Claude Code settings that prompts you to run `/morning-coffee` when you start a session in the morning.

Edit `~/.claude/settings.json` and add to the `hooks` section:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "echo 'Morning session detected. Want to run /morning-coffee?'",
        "conditions": {
          "timeRange": "06:00-12:00"
        }
      }
    ]
  }
}
```

(The exact hook format depends on your Claude Code version and configuration.)

## Step 5: Workboard Init

If you haven't set up your workboard yet:

```
/workboard-init
```

Or copy the template and fill it in manually:

```bash
cp templates/workboard-example.md ~/.claude/projects/memory/workboard.md
# Edit to match your actual projects
```

## Step 6: Verify the Full Workflow

### Morning Test

```
/morning-coffee
```

You should see:
- Workboard status scan
- Calendar events (if msgraph is working)
- Email summary (if msgraph is working)
- Triage summary (if the agent ran today)
- Focus item suggestions

### Day Reference

```
/today
```

Should display the plan you just created.

### End of Day

```
/wrap-up
```

Should show your focus items and ask how they went.

## Complete File Layout

After full setup, your filesystem looks like:

```
~/.claude/
├── commands/
│   ├── morning-coffee.md
│   ├── today.md
│   ├── wrap-up.md
│   └── workboard-init.md (optional, can remove after use)
├── projects/
│   └── memory/
│       ├── workboard.md
│       ├── MEMORY.md
│       └── daily/
│           └── YYYY-MM-DD.md (created daily)
└── settings.json (SessionStart hook)

~/.config/
└── morning-coffee/
    └── providers.yaml

~/Projects/
└── webex-triage-agent/
    ├── scripts/
    ├── output/
    │   └── YYYY-MM-DD-triage.md (generated daily at 8:30am)
    └── preferences.md

~/Library/LaunchAgents/
└── com.morning-coffee.triage.plist
```

## Troubleshooting

**Calendar/email not showing**: Run `~/.config/claude-graph/bin/msgraph calendar 1` manually. If it fails with a token error, re-run `/msgraph-auth`.

**Triage file not generated**: Check `/tmp/morning-coffee-triage.log` for errors. Common issues: expired Webex OAuth token, AWS credentials expired.

**"No plan set for today"**: You need to run `/morning-coffee` first — it creates the daily plan file that `/today` reads.

**Workboard not found**: Ensure `~/.claude/projects/memory/workboard.md` exists. Run `/workboard-init` or copy a template.
