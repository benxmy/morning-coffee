# Providers

Providers connect morning-coffee to your calendar, email, and other data sources. They're simple YAML files that map a data source to a shell command.

## How It Works

Morning-coffee reads `~/.config/morning-coffee/providers.yaml` at runtime. For each key present, it runs the associated command and incorporates the output. Missing keys are silently skipped — the core workflow (workboard + focus picks) always works without any providers.

## Provider YAML Schema

```yaml
# ~/.config/morning-coffee/providers.yaml
# All keys are optional. Only include what you have configured.

calendar:
  command: "shell command that outputs today's meetings as readable text"
  description: "Human-readable name for this source"

email:
  command: "shell command that outputs recent/unread emails as readable text"
  description: "Human-readable name for this source"

triage:
  path: "absolute/path/to/{date}-triage.md"
  description: "Pre-computed message triage file"
```

The `{date}` placeholder in `triage.path` is replaced with today's date in `YYYY-MM-DD` format.

## Available Providers

| Provider | Directory | Calendar | Email | Notes |
|----------|-----------|----------|-------|-------|
| duo-msgraph | `duo-msgraph/` | Yes | Yes | Microsoft Graph via Duo plugin — default for Cisco/Duo users |
| none | `none/` | — | — | Explicit workboard-only mode |
| google-workspace | `google-workspace/` | Stubbed | Stubbed | Community contribution welcome |

## Writing Your Own Provider

1. Create a directory under `providers/` with your provider name
2. Add a `commands.yaml` with the calendar/email commands for your tool
3. Add a `setup.md` with installation and authentication instructions
4. Test: run your commands in a terminal and verify they produce readable text output

The skill doesn't parse structured data — it reads the text output naturally. As long as your command produces human-readable meeting times or email summaries, it will work.

## Testing Your Provider

```bash
# Test calendar command
eval "$(yq '.calendar.command' ~/.config/morning-coffee/providers.yaml)"

# Test email command
eval "$(yq '.email.command' ~/.config/morning-coffee/providers.yaml)"

# Test triage file exists
date_str=$(date '+%Y-%m-%d')
triage_path=$(yq '.triage.path' ~/.config/morning-coffee/providers.yaml | sed "s/{date}/$date_str/")
cat "$triage_path"
```

(You don't need `yq` installed — these are just verification examples. The skill reads the YAML directly.)
