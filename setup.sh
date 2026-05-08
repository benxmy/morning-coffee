#!/bin/bash
set -e

# Morning Coffee — Interactive Setup
# Installs the daily focus workflow for Claude Code

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$HOME/.claude/commands"
MEMORY_DIR="$HOME/.claude/projects/memory"
CONFIG_DIR="$HOME/.config/morning-coffee"

echo "========================================"
echo "  Morning Coffee — Setup"
echo "  Daily focus workflow for Claude Code"
echo "========================================"
echo ""

# Step 1: Check Claude Code is installed
if [ ! -d "$HOME/.claude" ]; then
    echo "ERROR: ~/.claude directory not found."
    echo "Claude Code must be installed first: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

echo "✓ Claude Code detected"
echo ""

# Step 2: Create commands directory if needed
if [ ! -d "$COMMANDS_DIR" ]; then
    mkdir -p "$COMMANDS_DIR"
    echo "  Created $COMMANDS_DIR"
fi

# Step 3: Install core skills
echo "Installing core skills..."
cp "$SCRIPT_DIR/skills/morning-coffee.md" "$COMMANDS_DIR/morning-coffee.md"
cp "$SCRIPT_DIR/skills/today.md" "$COMMANDS_DIR/today.md"
cp "$SCRIPT_DIR/skills/wrap-up.md" "$COMMANDS_DIR/wrap-up.md"
echo "  ✓ /morning-coffee"
echo "  ✓ /today"
echo "  ✓ /wrap-up"
echo ""

# Step 4: Create memory directory structure
echo "Setting up memory directories..."
mkdir -p "$MEMORY_DIR/daily"
if [ ! -f "$MEMORY_DIR/MEMORY.md" ]; then
    touch "$MEMORY_DIR/MEMORY.md"
    echo "  Created $MEMORY_DIR/MEMORY.md"
fi
echo "  ✓ Memory structure ready"
echo ""

# Step 5: Provider configuration
echo "----------------------------------------"
echo "PROVIDER SETUP"
echo "----------------------------------------"
echo ""
echo "Morning-coffee can pull your calendar and email to inform"
echo "your daily planning. This is optional — the core workflow"
echo "works with just your workboard."
echo ""
echo "Available providers:"
echo "  1) duo-msgraph  — Microsoft Graph via Duo plugin (Cisco/Duo users)"
echo "  2) google       — Google Workspace (community, requires gcalcli)"
echo "  3) none         — Workboard only, no calendar/email"
echo "  4) skip         — I'll configure this manually later"
echo ""
read -p "Choose a provider [1-4]: " provider_choice

case $provider_choice in
    1)
        mkdir -p "$CONFIG_DIR"
        cp "$SCRIPT_DIR/providers/duo-msgraph/commands.yaml" "$CONFIG_DIR/providers.yaml"
        echo ""
        echo "  ✓ duo-msgraph provider configured"
        echo ""
        echo "  IMPORTANT: You need the duo-msgraph plugin installed and authenticated."
        echo "  See: providers/duo-msgraph/setup.md for full instructions."
        echo "  Quick version:"
        echo "    1. Install plugin: claude plugins install duo-msgraph@duo-cc-plugins"
        echo "    2. Authenticate: run /msgraph-auth in Claude Code"
        ;;
    2)
        mkdir -p "$CONFIG_DIR"
        cp "$SCRIPT_DIR/providers/google-workspace/commands.yaml" "$CONFIG_DIR/providers.yaml"
        echo ""
        echo "  ✓ Google Workspace provider configured (stubbed)"
        echo ""
        echo "  NOTE: You'll need to install gcalcli and a Gmail CLI tool."
        echo "  See: providers/google-workspace/setup.md for details."
        echo "  Edit ~/.config/morning-coffee/providers.yaml to match your tools."
        ;;
    3)
        mkdir -p "$CONFIG_DIR"
        cp "$SCRIPT_DIR/providers/none/commands.yaml" "$CONFIG_DIR/providers.yaml"
        echo ""
        echo "  ✓ No provider configured — workboard-only mode"
        ;;
    4)
        echo ""
        echo "  Skipped. You can configure providers later by copying a"
        echo "  commands.yaml to ~/.config/morning-coffee/providers.yaml"
        ;;
    *)
        echo ""
        echo "  Invalid choice. Skipping provider setup."
        echo "  You can configure providers later."
        ;;
esac
echo ""

# Step 6: Message triage
echo "----------------------------------------"
echo "MESSAGE TRIAGE (optional)"
echo "----------------------------------------"
echo ""
echo "Morning-coffee can read a daily triage file — a pre-computed"
echo "summary of your messaging activity organized by priority."
echo ""
echo "This requires a separate triage agent that runs before your"
echo "morning planning time (e.g., 8:30 AM cron job)."
echo ""
read -p "Do you want to set up message triage? [y/N]: " triage_choice

if [[ "$triage_choice" =~ ^[Yy] ]]; then
    echo ""
    echo "  To set up message triage:"
    echo ""
    echo "  1. Clone the reference implementation:"
    echo "     git clone https://github.com/benxmy/webex-agent.git"
    echo "     (Update URL when published)"
    echo ""
    echo "  2. Configure it to run before your morning planning time"
    echo ""
    echo "  3. Add the triage path to your providers.yaml:"
    echo "     echo 'triage:' >> ~/.config/morning-coffee/providers.yaml"
    echo "     echo '  path: \"~/path/to/output/{date}-triage.md\"' >> ~/.config/morning-coffee/providers.yaml"
    echo ""
    echo "  See: integrations/webex-triage.md for full details"
    echo "  See: integrations/triage-format.md for the expected file format"
    echo ""
    echo "  TIP: You'll want to train and evolve the triage agent over time."
    echo "  Start broad, review output daily for the first week, and tune"
    echo "  your preferences based on false positives/negatives."
fi
echo ""

# Step 7: Workboard setup
echo "----------------------------------------"
echo "WORKBOARD SETUP"
echo "----------------------------------------"
echo ""
echo "The workboard is the backbone of morning-coffee — a single file"
echo "tracking all your active, parked, and dropped work."
echo ""

if [ -f "$MEMORY_DIR/workboard.md" ]; then
    echo "  ✓ Workboard already exists at $MEMORY_DIR/workboard.md"
    echo "  Skipping workboard setup."
else
    echo "How would you like to set up your workboard?"
    echo "  1) Guided setup — install /workboard-init and run it in Claude Code"
    echo "  2) Template — copy the blank template (fill in manually)"
    echo "  3) Example — copy the example workboard (edit to match your projects)"
    echo ""
    read -p "Choose [1-3]: " workboard_choice

    case $workboard_choice in
        1)
            cp "$SCRIPT_DIR/skills/workboard-init.md" "$COMMANDS_DIR/workboard-init.md"
            echo ""
            echo "  ✓ /workboard-init skill installed"
            echo "  Run '/workboard-init' in Claude Code to create your workboard interactively."
            ;;
        2)
            cp "$SCRIPT_DIR/templates/workboard.md" "$MEMORY_DIR/workboard.md"
            echo ""
            echo "  ✓ Blank template copied to $MEMORY_DIR/workboard.md"
            echo "  Edit it to add your projects."
            ;;
        3)
            cp "$SCRIPT_DIR/templates/workboard-example.md" "$MEMORY_DIR/workboard.md"
            echo ""
            echo "  ✓ Example workboard copied to $MEMORY_DIR/workboard.md"
            echo "  Edit it to replace the example projects with your own."
            ;;
        *)
            cp "$SCRIPT_DIR/templates/workboard.md" "$MEMORY_DIR/workboard.md"
            echo ""
            echo "  Copied blank template to $MEMORY_DIR/workboard.md"
            ;;
    esac
fi
echo ""

# Done
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "Installed skills:"
echo "  /morning-coffee  — Daily focus picker (run each morning)"
echo "  /today           — Quick reference for today's plan"
echo "  /wrap-up         — End-of-day review"
echo ""
echo "Next steps:"
echo "  1. Set up your workboard (if you haven't already)"
echo "  2. Run '/morning-coffee' in Claude Code tomorrow morning"
echo "  3. At end of day, run '/wrap-up' to review and carry forward"
echo ""
echo "For more information:"
echo "  - Quick start:    docs/quickstart.md"
echo "  - Full setup:     docs/full-setup-guide.md"
echo "  - Customization:  docs/customization.md"
echo ""
