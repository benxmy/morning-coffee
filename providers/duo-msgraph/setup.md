# duo-msgraph Provider Setup

This provider uses the `duo-msgraph` Claude Code plugin to access Microsoft Graph (Outlook calendar and email).

## Prerequisites

- Claude Code installed
- A Microsoft 365 account (corporate or personal)
- The `duo-msgraph` plugin installed in Claude Code

## Installation

### 1. Install the duo-msgraph plugin

```bash
# From Claude Code, install the plugin:
claude plugins install duo-msgraph@duo-cc-plugins
```

Or add it manually to your Claude Code plugin configuration.

### 2. Authenticate

Run the Microsoft Graph authentication skill:

```
/msgraph-auth
```

This will walk you through the OAuth flow to connect your Microsoft 365 account. You'll need to authorize access to your calendar and email.

### 3. Verify

Test that the commands work:

```bash
# Should show today's calendar
~/.config/claude-graph/bin/msgraph calendar 1

# Should show recent unread emails
~/.config/claude-graph/bin/msgraph email recent 2 --unread --max 20
```

### 4. Install the provider

Copy the provider config to your morning-coffee configuration:

```bash
mkdir -p ~/.config/morning-coffee
cp providers/duo-msgraph/commands.yaml ~/.config/morning-coffee/providers.yaml
```

Or if you also want triage, append the triage config:

```yaml
# Add to ~/.config/morning-coffee/providers.yaml
triage:
  path: "~/Projects/webex-agent/output/{date}-triage.md"
  description: "Webex daily triage (pre-computed at 8:30am)"
```

## Troubleshooting

**"Token expired" errors**: Re-run `/msgraph-auth` to refresh your OAuth token.

**"Command not found"**: Make sure `~/.config/claude-graph/bin/` exists and contains the `msgraph` binary. The plugin creates this on install.

**No calendar events showing**: Verify your Microsoft 365 account has calendar access. Some organizations restrict Graph API access — check with your IT team.

## Token Refresh

The OAuth token expires periodically. When morning-coffee encounters a token error, it skips calendar/email gracefully. To fix, re-authenticate:

```
/msgraph-auth
```
