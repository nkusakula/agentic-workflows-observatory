# Setup Guide

This guide walks you from a fresh clone to your first agentic workflow run.

## Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated
- A GitHub repository where you have admin permissions (so you can enable Actions and Discussions)
- An AI engine credential — at minimum, GitHub Copilot enabled on your account, or an Anthropic / OpenAI API key

## 1. Install the `gh-aw` Extension

```bash
gh extension install github/gh-aw
gh aw --version
```

## 2. Clone or Fork This Demo

```bash
gh repo clone <your-user>/agentic-workflows-observatory-demo
cd agentic-workflows-observatory-demo
```

## 3. Enable Discussions on Your Repo

The observatory workflows post to GitHub Discussions. Go to **Settings → Features → Discussions** and enable them. Create two categories:

- `Observatory` — for metrics and portfolio posts
- `Engineering` — for nightly code quality posts

## 4. Compile the Workflows

Each `.md` workflow needs to be compiled into a `.lock.yml` GitHub Actions workflow:

```bash
gh aw compile .github/workflows/metrics-collector.md
gh aw compile .github/workflows/portfolio-analyst.md
gh aw compile .github/workflows/audit-workflows.md
gh aw compile .github/workflows/issue-triage.md
gh aw compile .github/workflows/pr-quality-reviewer.md
gh aw compile .github/workflows/nightly-code-quality.md
```

You should see new `*.lock.yml` files appear next to each `.md` file.

## 5. Commit and Push

```bash
git add .github/workflows/*.lock.yml
git commit -m "Compile agentic workflows"
git push
```

## 6. Configure Your AI Engine

Set the required secret in your repo (**Settings → Secrets and variables → Actions**):

- For Copilot: typically no extra secret needed if Copilot is enabled on the account
- For Claude: `ANTHROPIC_API_KEY`
- For OpenAI: `OPENAI_API_KEY`

## 7. Trigger Your First Run

```bash
# Manually trigger the metrics collector
gh aw run metrics-collector

# Watch its progress
gh run watch
```

When it completes, check the Discussions tab of your repo — you should see a new `[metrics]` post.

## 8. Generate Some Activity

To make the observatory have something to observe, generate a little subject-agent activity:

```bash
# Open a test issue to trigger issue-triage
gh issue create --title "Help: cannot create task with empty title" --body "Steps: POST /tasks with no body. Expected 400, got 500."

# Open a test PR to trigger pr-quality-reviewer
# (make a small branch + edit + push + open PR)
```

Then wait for the next scheduled run of the observatory workflows, or trigger them manually:

```bash
gh aw run portfolio-analyst
gh aw run audit-workflows
```

## 9. Review the Outputs

- **Discussions tab** — `[metrics]`, `[portfolio]`, `[code-quality]` posts
- **Issues tab** — `[audit]` issues with the `observatory` label
- **PR comments** — from the PR quality reviewer

## Troubleshooting

| Symptom | Fix |
|---|---|
| `gh aw compile` errors on frontmatter | Check for tab characters (use spaces) and matching `---` delimiters |
| Workflow runs but produces no output | Check the agent's logs in the Actions tab; permissions may be too restrictive |
| Threat detection job fails | Inspect the agent's proposed output artifact — likely contains something suspicious |
| Discussion creation fails | Confirm the `Observatory` / `Engineering` discussion categories exist exactly as named |

See the full [gh-aw documentation](https://github.github.com/gh-aw/) for deeper troubleshooting.
