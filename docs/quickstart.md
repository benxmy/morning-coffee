# Quick Start

Get morning-coffee running in 5 minutes.

## 1. Clone and Install

```bash
git clone https://github.com/benxmy/morning-coffee.git
cd morning-coffee
./setup.sh
```

Follow the prompts. For the fastest setup:
- Provider: choose `3` (none) — you can add calendar/email later
- Triage: choose `N` — optional, add later
- Workboard: choose `1` (guided) to run `/workboard-init`, or `2` (template) to fill in manually

## 2. Set Up Your Workboard

If you chose the guided option:

```
# In Claude Code:
/workboard-init
```

This interviews you about your active projects and generates your workboard. Takes about 5 minutes.

If you chose the template, edit the `workboard.md` file the setup script created (the path is printed during setup — it looks like `~/.claude/projects/-Users-<you>/memory/workboard.md`) and add your projects following the format.

## 3. Run Your First Morning Coffee

```
# In Claude Code:
/morning-coffee
```

On the first run, Claude Code will ask you to approve some tool permissions (reading your workboard, running date commands, etc.). This is normal — the skill declares what it needs in its `allowed-tools` header, and Claude Code confirms with you before granting access.

If you configured a calendar/email provider, you'll also be prompted to approve running those commands (e.g., `msgraph calendar 1`). Once approved, these permissions persist for the session.

It will:
- Read your workboard
- Show a status scan (stalled items, things waiting)
- Ask you to pick 2-3 focus items
- Ask about deep work time
- Write a daily plan

## 4. During the Day

```
/today
```

Quick reference for what you committed to.

## 5. End of Day

```
/wrap-up
```

Reviews what you planned vs what happened, captures carry-forwards, updates the workboard.

## Next Steps

- **Add calendar/email**: See [providers/](../providers/) to configure a provider
- **Add message triage**: See [integrations/webex-triage.md](../integrations/webex-triage.md)
- **Full setup guide**: See [full-setup-guide.md](./full-setup-guide.md) for the complete workflow
- **Customize**: See [customization.md](./customization.md) for tweaking behavior
