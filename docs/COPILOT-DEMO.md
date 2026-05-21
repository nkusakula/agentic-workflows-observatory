# Copilot CLI & Copilot Chat Demo

This document demonstrates how **GitHub Copilot CLI** and **GitHub Copilot Chat** complement the agentic workflows in this repository — giving developers interactive AI assistance alongside the automated agent layer.

---

## 🖥️ Copilot CLI (`gh copilot`)

Copilot CLI brings AI assistance directly into your terminal. It's ideal for quick explanations, command suggestions, and exploratory debugging — all without leaving your shell.

### Installation

```bash
# Copilot CLI ships as a gh extension
gh extension install github/gh-copilot
gh copilot --version
```

### Suggesting Commands

Use `gh copilot suggest` when you know *what* you want to do but not the exact syntax:

```bash
# "How do I list all workflow runs that failed in the last week?"
gh copilot suggest "list failed GitHub Actions runs from the past 7 days"
# → gh run list --status failure --created ">$(date -d '7 days ago' +%Y-%m-%d)"

# "How do I find which agent used the most tokens?"
gh copilot suggest "search discussions for the highest token-usage entry in Observatory category"

# "How do I trigger a specific agentic workflow?"
gh copilot suggest "manually trigger the metrics-collector agentic workflow"
# → gh aw run metrics-collector
```

### Explaining Commands

Use `gh copilot explain` to understand unfamiliar commands or pipeline steps:

```bash
# Explain what the compile step does
gh copilot explain "gh aw compile .github/workflows/metrics-collector.md"
# → Explains: compiles the markdown workflow definition into a .lock.yml
#   GitHub Actions workflow with the agentic security model baked in

# Explain a complex git command
gh copilot explain "git log --oneline --since='1 week ago' -- .github/workflows/"
# → Lists commits from the past week that touched workflow files

# Explain a jq pipeline from the metrics output
gh copilot explain "gh api repos/:owner/:repo/actions/runs --jq '.workflow_runs[] | select(.conclusion==\"failure\") | .name'"
```

### Real Scenarios in This Repo

```bash
# Scenario 1: You want to check observatory health
gh copilot suggest "check if metrics-collector workflow ran successfully today"

# Scenario 2: You want to understand token spend
gh copilot suggest "get the total billable minutes for all workflow runs this month"

# Scenario 3: Debug a failing agent
gh copilot suggest "show logs for the most recent failed run of issue-triage"

# Scenario 4: Quick API testing of the sample app
gh copilot suggest "curl command to create a new task in a REST API on localhost:3000"
# → curl -X POST http://localhost:3000/tasks -H "Content-Type: application/json" -d '{"title":"Test task"}'
```

---

## 💬 Copilot Chat (IDE & CLI)

Copilot Chat provides conversational AI within VS Code (or your IDE) and via `gh copilot chat` in the terminal. It has full context of your workspace and can reason about code, workflows, and architecture.

### In VS Code — Workspace-Aware Assistance

Open this repo in VS Code with GitHub Copilot Chat enabled. Example prompts:

#### Understanding the Architecture

```
@workspace How do the observatory agents communicate findings back to the team?
```
> Copilot Chat reads `docs/ARCHITECTURE.md` and explains the workflow-to-human-to-agent feedback loop.

```
@workspace What security boundaries prevent the metrics-collector from modifying the repo?
```
> Explains the read-only token, network firewall, safe-outputs pattern from the lock.yml.

#### Working with the Sample App

```
@workspace Add a DELETE /tasks/:id endpoint to server.js
```
> Generates the handler following the existing patterns (uses `send()`, `tasks.delete()`, returns 204).

```
@workspace Write a test for the PATCH /tasks/:id endpoint that verifies partial updates
```
> Produces a test using the same testing patterns from `server.test.js`.

#### Analyzing Workflow Definitions

```
@workspace Explain the frontmatter in issue-triage.md and what each field controls
```
> Breaks down triggers, model selection, token budgets, safe-output declarations.

```
@workspace What would happen if I increased the token budget in nightly-code-quality.md?
```
> Explains cost implications and references the Portfolio Analyst's role in catching overspend.

### In the Terminal — Quick Questions Without Context Switching

```bash
# Ask about the project
gh copilot chat "What's the difference between observatory and subject agents in this repo?"

# Get help writing a new workflow
gh copilot chat "Write a frontmatter block for a new agentic workflow that runs on PR comments"

# Understand an error
gh copilot chat "The issue-triage agent labeled an issue as 'bug' but it's clearly a feature request. How would the audit-workflows agent catch this?"
```

---

## 🔄 How They Work Together

The three Copilot surfaces complement each other and the agentic workflows:

```
┌─────────────────────────────────────────────────────────────────┐
│                     Developer Workflow                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Copilot Chat (IDE)     Copilot CLI (Terminal)    Agentic WFs  │
│  ─────────────────      ──────────────────────    ───────────  │
│  • Explore codebase     • Suggest commands        • Automated  │
│  • Generate code        • Explain pipelines       • Scheduled  │
│  • Reason about arch    • Quick one-off queries   • Event-driven│
│  • Refactor & test      • Debug in context        • Observable │
│                                                                 │
│  ◄── Interactive ──►    ◄── Interactive ──►     ◄── Autonomous │
│      (human-in-loop)        (human-in-loop)         (unattended)│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

| Capability | Copilot Chat | Copilot CLI | Agentic Workflows |
|-----------|-------------|-------------|-------------------|
| Trigger | Human asks | Human asks | Event/schedule |
| Context | Full workspace | Current shell | Defined in workflow `.md` |
| Output | Code, explanations | Commands, explanations | Issues, comments, discussions |
| Best for | Deep reasoning, code gen | Quick commands, exploration | Repeatable automation |

---

## 🎯 Demo Script (Live Presentation)

Use this sequence to demonstrate all three in a live demo:

```bash
# 1. Show Copilot CLI — suggest a command to check agent health
gh copilot suggest "list the most recent agentic workflow runs and their status"

# 2. Show Copilot CLI — explain what an agentic workflow compile does
gh copilot explain "gh aw compile .github/workflows/issue-triage.md"

# 3. Switch to VS Code — use Copilot Chat
#    Ask: "@workspace Summarize what the observatory agents track and how often"
#    Ask: "@workspace Add a priority field to the task model in server.js"

# 4. Show the agentic workflow in action
gh issue create --title "Bug: tasks API returns 500 on malformed JSON" \
  --body "POST /tasks with body '{invalid' causes unhandled error"
# → issue-triage agent labels it automatically

# 5. Show the observatory watching
gh aw run metrics-collector
# → Posts a discussion summarizing today's agent activity
```

---

## 📝 Key Takeaways

1. **Copilot CLI** is your terminal co-pilot — it helps you *discover* and *understand* commands without memorizing syntax.
2. **Copilot Chat** is your workspace-aware reasoning partner — it helps you *build*, *refactor*, and *understand* code in context.
3. **Agentic Workflows** are your autonomous agents — they act *on your behalf* on a schedule or in response to events.
4. Together, they form a spectrum from **interactive** (human-driven) to **autonomous** (event-driven), with observability tying it all together.
