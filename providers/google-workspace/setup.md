# Google Workspace Provider Setup

> **Status: Community Contribution** — This provider is stubbed out with example commands. The exact CLI tools and authentication flow will depend on your setup.

## Approach

Any CLI tool that can output your Google Calendar events and Gmail messages as readable text will work. The skill doesn't parse structured data — it reads the output naturally.

## Suggested Tools

### Calendar: gcalcli

```bash
# Install
pip install gcalcli

# Authenticate (one-time OAuth flow)
gcalcli init

# Test
gcalcli agenda --nocolor --nodeclined $(date '+%Y-%m-%d') $(date '+%Y-%m-%d')
```

### Email: Options

- **gmail-cli** — lightweight CLI for Gmail
- **mutt/neomutt** — can output unread mail summaries
- **Google Apps Script** — deploy a script that outputs to a local file
- **Custom script** — use the Gmail API directly with a Python/Node script

## Installation

Once your CLI tools are working:

```bash
mkdir -p ~/.config/morning-coffee
cp providers/google-workspace/commands.yaml ~/.config/morning-coffee/providers.yaml
```

Edit the commands in `providers.yaml` to match your actual installed tools and flags.

## Contributing

If you get this working well, please submit a PR with:
- Your verified `commands.yaml`
- Updated `setup.md` with exact installation steps
- Any helper scripts needed
