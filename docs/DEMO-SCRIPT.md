# 🎬 End-to-End Demo Script

> **The Story**: You're the tech lead of a small SaaS platform team. Your repo has been running AI agents for a few weeks. The agents are busy — but are they actually helping? This demo walks through exactly how the observatory uncovers a hidden cost problem and helps the team fix it.

---

## 🗺️ The Story in Three Acts

```
Act 1 — The Agents Are Running
  └── Issues are triaged, PRs are reviewed, nightly scans are running

Act 2 — The Observatory Wakes Up
  └── Metrics Collector posts daily vitals
  └── Portfolio Analyst flags a hidden cost problem
  └── Audit Workflow opens a specific, evidence-backed issue

Act 3 — The Team Fixes It
  └── Tighten the offending workflow's prompt
  └── Recompile and push
  └── Next week's portfolio report shows costs down 40%
```

---

## 🧰 Before You Start

```bash
gh extension install github/gh-aw
gh repo clone nkusakula/agentic-workflows-observatory
cd agentic-workflows-observatory
```

Verify everything looks good:
```bash
gh issue list     # should show 6 open issues
gh pr list        # should show 3 open PRs
```

---

## Act 1 — The Agents Are Running

### What to show

The subject agents have already been at work. Open the **Issues** tab on GitHub and point out:

| Issue | What the triage agent did |
|-------|--------------------------|
| `500 error on POST /tasks` | Labelled `type:bug`, `priority:high`, `area:api` |
| `Add due date support` | Labelled `type:feature`, `priority:medium`, `area:api` |
| `How to filter by done status?` | Labelled `type:question`, `needs-info`, `priority:low` |
| `PATCH silently ignores unknown fields` | Labelled `type:bug`, `priority:medium`, `area:api` |
| `GET /tasks slow with large lists` | Labelled `type:performance`, `priority:medium` |
| `API docs missing from README` | Labelled `type:docs`, `priority:low` |

Open the **Pull Requests** tab and show the PR Quality Reviewer comments on each PR.

### The "before" state — costs are rising

> *"We've had three agents running for two weeks. Issue triage looks great. PR reviews are helpful. But our AI API bill crept up 40% last month and nobody knows why."*

---

## Act 2 — The Observatory Wakes Up

### Step 1: Run the Metrics Collector

```bash
gh aw run metrics-collector
gh run watch
```

When it completes, open **Discussions → Observatory**. You'll see a `[metrics]` post with a per-workflow table. Point out:

- Issue Triage: ✅ 6 runs, high outcome rate (humans responded to labeled issues)
- PR Quality Reviewer: ✅ 3 runs, comments were acted on
- **Nightly Code Quality: ⚠️ 14 runs, 0 human follow-up actions in 5 days**

> *"The scanner is active — but nobody's reading its reports."*

### Step 2: Run the Portfolio Analyst

```bash
gh aw run portfolio-analyst
gh run watch
```

Open **Discussions → Observatory** for the `[portfolio]` post. The key table should look like:

| Workflow | Cost share | Outcome rate | Quadrant |
|----------|-----------|--------------|---------|
| issue-triage | 18% | 83% | ⭐ High value, low cost |
| pr-quality-reviewer | 24% | 100% | ⭐ High value, low cost |
| **nightly-code-quality** | **58%** | **0%** | **🚨 High cost, low value** |

> *"The nightly scanner is consuming 58% of total AI spend. Its output is being completely ignored. This is the culprit."*

The Portfolio Analyst suggests: reduce frequency, tighten the prompt, add a token budget cap.

### Step 3: Run the Audit Workflow

```bash
gh aw run audit-workflows
gh run watch
```

Open **Issues** and filter by label `audit`. You should see an issue titled something like:

> **[audit] Nightly Code Quality outputs growing progressively longer week-over-week**

The Audit Workflow has:
- Found that discussion posts from this agent have grown from ~300 words to ~900 words over 2 weeks
- Linked to specific runs as evidence
- Hypothesized context drift in the prompt
- Suggested: cap findings at 5, rotate focus area, enforce a word limit

> *"This is the 'who watches the agents?' moment. A meta-agent caught what no human would have noticed."*

---

## Act 3 — The Team Fixes It

### The Fix: Tighten the Workflow

Open `.github/workflows/nightly-code-quality.md`. The existing prompt already has good constraints. For the demo, show making them more explicit:

```bash
# Open the workflow in your editor
code .github/workflows/nightly-code-quality.md
```

Point to the `## Constraints` section — it already caps findings at 5 and enforces a 500-word limit. Explain that the Audit Workflow's finding would lead you to also:

1. Change `schedule: daily` → `schedule: weekly` (reduce frequency)
2. Add `max-tokens: 2000` to frontmatter (add a hard token cap)

### Recompile and Push

```bash
gh aw compile .github/workflows/nightly-code-quality.md
git add .github/workflows/nightly-code-quality.lock.yml
git commit -m "fix: reduce nightly scanner frequency and cap token usage"
git push
```

### The Payoff

> *"Next Monday, the Portfolio Analyst runs again. The nightly scanner's cost share drops from 58% to 18%. Total fleet cost is down ~40%. The team didn't need to write a billing script, dig through logs, or guess. Three plain-English markdown files told them exactly where to look."*

---

## 🎯 Key Takeaways to Land

1. **Natural language is the new YAML** — all six workflows are plain markdown, no YAML job definitions
2. **The observatory pattern is reusable** — drop these three files into any repo that already runs agents
3. **Guardrails make it safe** — every output went through read-only execution → threat detection → scoped write job
4. **Agents watching agents is the unlock** — human review time is finite; meta-agents scale observability

---

## 📎 Quick Reference

| Command | What it does |
|---------|-------------|
| `gh aw run metrics-collector` | Trigger daily metrics post |
| `gh aw run portfolio-analyst` | Trigger weekly cost/value analysis |
| `gh aw run audit-workflows` | Trigger meta-agent audit |
| `gh run watch` | Watch the current run live |
| `gh aw compile <file.md>` | Recompile after frontmatter changes |

**→ Full setup guide:** [`docs/SETUP.md`](SETUP.md)  
**→ Architecture deep-dive:** [`docs/ARCHITECTURE.md`](ARCHITECTURE.md)
