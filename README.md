# 🔭 Agentic Workflows Observatory Demo

> A reference repository that demonstrates **GitHub Agentic Workflows** with a focus on the *observatory pattern* — agents that monitor other agents.

This demo accompanies the blog post **"You're Running AI Agents. But Who's Watching Them?"** and shows how to combine *subject agents* (agents that act on a repo) with *observatory agents* (agents that measure and audit them) to keep an AI automation fleet healthy, cost-efficient, and trustworthy.

---

## 🎯 What This Repo Demonstrates

This demo simulates a small SaaS team that has adopted AI agents to automate repository maintenance — and then layered an **observability stack** on top to keep those agents accountable.

```
┌─────────────────────────────────────────────────────────┐
│                  The Observatory                        │
│                                                         │
│  📊 Metrics Collector    💰 Portfolio Analyst           │
│  🔍 Audit Workflows                                     │
└──────────────────────────┬──────────────────────────────┘
                           │ watches
                           ▼
┌─────────────────────────────────────────────────────────┐
│                  Subject Agents                         │
│                                                         │
│  🏷️  Issue Triage   👀 PR Quality Reviewer             │
│  🌙 Nightly Code Quality Scanner                        │
└──────────────────────────┬──────────────────────────────┘
                           │ acts on
                           ▼
┌─────────────────────────────────────────────────────────┐
│           Sample App: TaskFlow API                      │
│      (a minimal Node.js app for realistic context)      │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```
.
├── .github/workflows/        # All agentic workflow definitions (.md)
│   ├── metrics-collector.md       🔭 Observatory: daily metrics
│   ├── portfolio-analyst.md       🔭 Observatory: cost/value analysis
│   ├── audit-workflows.md         🔭 Observatory: meta-agent auditor
│   ├── issue-triage.md            🤖 Subject: auto-labels issues
│   ├── pr-quality-reviewer.md     🤖 Subject: reviews PRs
│   └── nightly-code-quality.md    🤖 Subject: nightly analysis
├── src/                      # Sample TaskFlow API (Node.js)
├── docs/
│   ├── SETUP.md              # Step-by-step install + first run
│   ├── BLOG-POST.md          # The accompanying narrative blog post
│   ├── ARCHITECTURE.md       # How observatory + subject agents interact
│   └── COPILOT-DEMO.md       # Copilot CLI & Chat demo walkthrough
├── LICENSE
└── README.md
```

---

## 🚀 Quick Start

```bash
# 1. Install the gh-aw extension
gh extension install github/gh-aw

# 2. Clone this demo
gh repo clone <your-user>/agentic-workflows-observatory-demo
cd agentic-workflows-observatory-demo

# 3. Compile the agentic workflows
gh aw compile .github/workflows/metrics-collector.md
gh aw compile .github/workflows/portfolio-analyst.md
gh aw compile .github/workflows/audit-workflows.md
gh aw compile .github/workflows/issue-triage.md
gh aw compile .github/workflows/pr-quality-reviewer.md
gh aw compile .github/workflows/nightly-code-quality.md

# 4. Push the compiled lock files
git add .github/workflows/*.lock.yml
git commit -m "Compile agentic workflows"
git push

# 5. Trigger your first run
gh aw run metrics-collector
```

Full walkthrough: [`docs/SETUP.md`](docs/SETUP.md)

---

## 🧩 Meet the Agents

### 🔭 Observatory Agents (the watchers)

| Agent | Schedule | Purpose |
|-------|----------|---------|
| **Metrics Collector** | Daily | Sweeps recent runs, tracks success rates, token usage, response times. Posts a discussion. |
| **Portfolio Analyst** | Weekly | Cross-references token cost vs. outcome value. Flags wasteful agents. |
| **Audit Workflows** | Weekly | Meta-agent that analyzes all other agents' outputs for drift, hallucinations, and ignored suggestions. |

### 🤖 Subject Agents (the watched)

| Agent | Trigger | Purpose |
|-------|---------|---------|
| **Issue Triage** | `issues.opened` | Reads incoming issues and applies labels + priority. |
| **PR Quality Reviewer** | `pull_request.opened` | Reviews PRs against contribution guidelines. |
| **Nightly Code Quality** | Daily at 02:00 UTC | Scans for code smells and posts a discussion. |

---

## 🔐 Security Model

Every workflow in this repo follows the GitHub Agentic Workflows security model:

1. **Read-only agent execution** — agents cannot write to GitHub directly
2. **Zero secrets in the agent process** — credentials live only in scoped write jobs
3. **Containerized + network firewall** — Squid proxy + domain allowlist
4. **Safe outputs** — structured artifacts reviewed before any write
5. **AI-powered threat detection** — scans every proposed output

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the layered diagram.

---

## 🤖 Copilot CLI & Copilot Chat

This demo also showcases how **Copilot CLI** and **Copilot Chat** complement the autonomous agentic workflows with interactive, human-in-the-loop AI assistance:

| Surface | Mode | Example |
|---------|------|---------|
| **Copilot CLI** (`gh copilot suggest/explain`) | Terminal | "Suggest a command to list failed workflow runs from this week" |
| **Copilot Chat** (`@workspace` in VS Code) | IDE | "Explain how the observatory agents detect token overspend" |
| **Agentic Workflows** (`.md` in `.github/workflows/`) | Autonomous | Runs on schedule/events, posts findings to Discussions & Issues |

Full walkthrough with live demo script: [`docs/COPILOT-DEMO.md`](docs/COPILOT-DEMO.md)

---

## 📖 The Story

If you'd like the narrative version — the "why this matters" arc — read [`docs/BLOG-POST.md`](docs/BLOG-POST.md).

---

## 📚 Further Reading

- [GitHub Agentic Workflows documentation](https://github.github.com/gh-aw/)
- [Peli's Agent Factory](https://github.github.com/gh-aw/blog/2026-01-12-welcome-to-pelis-agent-factory/) — 100+ production agentic workflows
- [Continuous AI initiative](https://githubnext.com/projects/continuous-ai)

---

## 📝 License

MIT — see [`LICENSE`](LICENSE).

> Built as a demo for the Microsoft Developer Blog post on agentic workflows.  
> Inspired by patterns from GitHub Next and Microsoft Research.  
> GitHub: [nkusakula/agentic-workflows-observatory](https://github.com/nkusakula/agentic-workflows-observatory)
