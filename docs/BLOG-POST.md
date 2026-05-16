# You're Running AI Agents. But Who's Watching Them?

There's a moment every engineering team hits when they've fully bought into automation: the pipelines are green, the bots are busy, and then someone asks — *"Is any of this actually working?"*

Silence.

Not because nothing is happening. Plenty is happening. Agents are triaging issues, drafting PRs, running overnight analysis jobs. But the team has no real visibility into which agents are delivering value, which are burning tokens on noise, and which quietly started hallucinating last Tuesday. The automation is a black box, and black boxes don't stay trustworthy for long.

This is the engineering blind spot of the agentic era — and it's exactly the problem that **GitHub Agentic Workflows**' metrics and analytics patterns are built to solve.

---

## The Scenario: A Team Running Blind

Imagine a platform engineering team at a mid-size SaaS company. Over three months, they've onboarded a handful of AI agents into their GitHub repository: one that triages incoming issues, one that reviews PRs for adherence to contribution guidelines, and one that runs nightly code quality analysis. The team likes the idea in principle, but the reality is murky:

- The issue triage agent seems active, but nobody is sure if its labels are actually accurate or just confident-sounding
- The nightly code quality agent creates discussions — but they've noticed the reports are getting longer and less specific over time
- API costs on the team's AI budget have ticked up 40% in six weeks. Nobody knows which agent is responsible

What they need isn't more agents doing more things. They need **observability** — the same thing they demand from their production systems, applied to their AI automation layer.

---

## Enter the Observatory: Three Workflows That Watch Everything Else

GitHub Agentic Workflows includes a pattern category that flips the model: instead of agents acting on your repository, these agents *analyze the agents acting on your repository*. Think of it as your monitoring stack, but for AI.

Three workflows form the core of this "observatory":

### 1. The Metrics Collector — Your Daily Vital Signs

The Metrics Collector runs on a schedule and sweeps through recent workflow runs across the repository. It tracks performance across the entire agent ecosystem — how many runs succeeded, how many produced output that was actually used, response times, token counts per workflow, and trend lines over time. Each day it posts a structured discussion thread: not a wall of logs, but a synthesized summary with highlights and anomalies called out.

This is the equivalent of your daily deployment health dashboard — except it covers your AI layer, not just your servers.

### 2. The Portfolio Analyst — Finding the Expensive Underperformers

This is where it gets interesting. The Portfolio Analyst runs weekly and asks a different question: *across all active workflows, where is effort being wasted?*

It cross-references token usage against outcomes. An agent that uses 10,000 tokens per run and consistently produces PRs with a 70% merge rate looks very different from one using 15,000 tokens per run with outputs that get silently ignored. The Portfolio Analyst surfaces these disparities and flags optimization opportunities — sometimes recommending a simpler prompt, sometimes flagging a workflow for retirement.

In real-world deployments at GitHub Next's "Peli's Agent Factory" (over 100 production agentic workflows running in the `github/gh-aw` repository), this exact pattern caught a workflow that was dramatically over-consuming tokens relative to its actual impact. The team would never have found it manually — there's simply too much activity to audit by hand.

### 3. The Audit Workflow — A Meta-Agent That Keeps Everyone Honest

The Audit Workflow is the most architecturally interesting of the three. It's a meta-agent: an AI agent whose job is to analyze the behavior, output quality, and failure patterns of all other agents.

It reads logs, inspects the artifacts produced by other workflows, checks whether outputs are being acted on or ignored, and surfaces patterns — like an agent whose suggestions have been systematically rejected, or one whose output quality has degraded over the past two weeks without any configuration change. When it finds issues, it opens GitHub issues. When those issues are actionable enough, downstream agents can pick them up and propose fixes.

In practice, this creates a self-correcting feedback loop: agents generate outputs, the Audit Workflow evaluates those outputs, findings become issues, and agents propose improvements — with humans reviewing and approving every step.

---

## The "Aha Moment" in Practice

Back to our platform engineering team. They install the three workflows:

```bash
gh extension install github/gh-aw

gh aw add-wizard https://github.com/github/gh-aw/blob/v0.45.5/.github/workflows/metrics-collector.md
gh aw add-wizard https://github.com/github/gh-aw/blob/v0.45.5/.github/workflows/portfolio-analyst.md
gh aw add-wizard https://github.com/github/gh-aw/blob/v0.45.5/.github/workflows/audit-workflows.md
```

Two weeks later, the Portfolio Analyst's weekly report surfaces something striking: the nightly code quality agent accounts for 58% of all AI spend — more than all other workflows combined. Cross-referenced with outcome data, the Metrics Collector shows its discussion posts have had zero follow-up actions from the team in five weeks. The Audit Workflow, independently, has flagged that the agent's prompts have grown progressively more verbose with each run, likely due to accumulated context drift.

This is not a crisis. It's a data-driven conversation the team can now actually have — one that leads to a prompt revision, a token budget cap in the frontmatter, and a 40% reduction in monthly AI spend within two weeks. No one had to dig through logs. No one had to write a custom analytics script.

---

## Why This Works: The Architecture Behind the Observability

What makes this safe to run at scale is the same layered security model underpinning all of GitHub Agentic Workflows. Each of these observatory workflows:

- **Runs read-only** — the agent reads workflow logs, discussions, and run metadata, but has no write access to the repository
- **Produces safe outputs** — any action (opening an issue, posting a discussion) goes through a structured artifact reviewed by a separate scoped write job
- **Passes through threat detection** — an AI-powered scan validates the proposed output before anything is written
- **Operates inside a network firewall** — a Squid proxy with a domain allowlist ensures the agent can't phone home to unexpected endpoints

The result is observability infrastructure you can trust to run unattended — not because you assume it'll never go wrong, but because the blast radius of anything going wrong is strictly bounded.

---

## The Broader Pattern: Continuous AI Needs Continuous Observability

We've spent years learning that you can't run production software responsibly without monitoring. Metrics, traces, alerts, dashboards — these aren't luxuries, they're the cost of operating at scale with confidence.

The same principle applies to AI agents. As teams move from one or two experimental automations to a real fleet of agentic workflows, the question shifts from *"can we automate this?"* to *"is our automation actually working, and at what cost?"* Without an observatory layer, that question has no answer.

GitHub Agentic Workflows, developed by GitHub Next and Microsoft Research, treats this as a first-class concern — not something to bolt on later, but a set of reusable, remixable workflows ready to deploy alongside your agents from day one.

---

## Try It Yourself

A complete reference implementation of everything described in this post is available in [this repository](../README.md), including:

- Three observatory workflows (metrics, portfolio, audit) — ready to drop into your repo
- Three subject workflows (issue triage, PR review, nightly code scan) for the observatory to observe
- A minimal sample app (TaskFlow API) for realistic context
- Step-by-step setup guide

```bash
# Install the CLI extension
gh extension install github/gh-aw

# Clone the demo
gh repo clone nkusakula/agentic-workflows-observatory
cd agentic-workflows-observatory-demo

# Compile and push
gh aw compile .github/workflows/*.md
git add .github/workflows/*.lock.yml && git commit -m "Compile workflows" && git push

# Trigger your first observatory run
gh aw run metrics-collector
```

**→ Documentation & Quick Start:** [github.github.com/gh-aw](https://github.github.com/gh-aw)

---

*GitHub Agentic Workflows is developed by GitHub Next and Microsoft Research as part of the [Continuous AI](https://githubnext.com/projects/continuous-ai) initiative.*
