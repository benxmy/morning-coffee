---
name: workboard-init
description: One-time bootstrapping skill. Interviews you about your active projects and generates a populated workboard.
user-invocable: true
allowed-tools:
  - Write(~/.claude/projects/memory/workboard.md)
  - Bash(date *)
---

# /workboard-init — Workboard Bootstrapping

This is a one-time setup skill to create your initial workboard. After running this, you'll maintain the workboard through daily use of `/morning-coffee` and `/wrap-up`.

## Steps

1. **Explain the workboard format** briefly:
   > "I'm going to help you set up your workboard — a single file that tracks all your active, parked, and dropped work. Each item gets a name, state, next step, blocker, and who you're waiting on. This becomes the backbone of your daily planning."

2. **Ask about categories.** Default categories are Work, Tools, and Personal. Ask:
   > "I'll organize your projects into categories. The defaults are **Work**, **Tools/Side Projects**, and **Personal**. Want to use these, or customize them?"

3. **Interview for active work.** For each category, ask:
   > "What are you actively working on right now in [category]? List as many as come to mind — we'll prioritize later."

   For each item mentioned, follow up with:
   - What's the current state? (one sentence)
   - What's the single next step to move it forward?
   - Is anything blocking you? (person, decision, dependency)
   - Are you waiting on anyone?

   Don't ask all four at once — let the conversation flow naturally. If someone gives a quick answer, that's fine. If they elaborate, capture the detail.

4. **Ask about parked work:**
   > "Anything you've consciously set aside for now? Things you'll come back to but aren't actively working on?"

   For each: capture the reason it's parked and when to revisit.

5. **Ask about dropped work** (optional):
   > "Anything you've decided to stop doing entirely? Sometimes it helps to record these so they don't creep back in."

6. **Generate the workboard.** Write to `~/.claude/projects/memory/workboard.md` using this format:

   ```markdown
   # Workboard

   Last reviewed: YYYY-MM-DD

   ## How to use this file
   - **Next step** = the single most important action to move this forward
   - **Blocker** = what's preventing progress (empty = unblocked, just needs time)
   - **Waiting on** = person/team who needs to act before you can proceed
   - Review with `/morning-coffee` daily. Update as things change.
   - Move items to Parked or Dropped when you consciously decide to defer.

   ---

   ## Active — [Category]

   ### [Project Name]
   - **State**: [current state]
   - **Next step**: [specific next action]
   - **Waiting on**: [person/team or —]
   - **Blocker**: [what's blocking or None]

   ...

   ## Parked
   - **[Project]** | reason: [why parked] | revisit: [when]

   ## Dropped
   - **[Project]** | reason: [why dropped] | dropped: YYYY-MM-DD
   ```

7. **Confirm and close:**
   > "Here's your workboard. Take a look — anything to add or change? Once you're happy with it, you're all set to run `/morning-coffee` tomorrow morning."

## Tone

Conversational and efficient. This should take 5-10 minutes, not 30. Don't over-interview — if someone gives brief answers, that's enough to populate the workboard. They can always refine it later.
