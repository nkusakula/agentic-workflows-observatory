# Architecture

This demo is intentionally structured around two layers of agents — the *observatory* (agents that watch) and the *subjects* (agents that act).

## Two-Layer Diagram

```
                  ┌─────────────────────────────────────┐
                  │           Observatory               │
                  │  (read-only; observes the others)   │
                  ├─────────────────────────────────────┤
                  │  📊 Metrics Collector  (daily)      │
                  │  💰 Portfolio Analyst  (weekly)     │
                  │  🔍 Audit Workflows    (weekly)     │
                  └────────────────┬────────────────────┘
                                   │ reads
                                   ▼
                  ┌─────────────────────────────────────┐
                  │            Subject Agents           │
                  │   (act on the repo via safe-outputs)│
                  ├─────────────────────────────────────┤
                  │  🏷️  Issue Triage      (on issue)   │
                  │  👀 PR Quality Reviewer (on PR)     │
                  │  🌙 Nightly Code Quality (daily)    │
                  └────────────────┬────────────────────┘
                                   │ acts on
                                   ▼
                  ┌─────────────────────────────────────┐
                  │          TaskFlow API               │
                  │     (the sample repository)         │
                  └─────────────────────────────────────┘
```

## How a Single Workflow Run Flows Through the Security Model

Every agent in this repo — observatory or subject — runs the same way:

```
┌──────────────────────────────────────────────────────┐
│  Trigger (cron, issue, PR, manual)                   │
│       │                                              │
│       ▼                                              │
│  ┌─────────────────────────────────────────┐         │
│  │  Isolated container                     │         │
│  │  • Read-only GitHub token               │         │
│  │  • Network firewall (Squid + allowlist) │         │
│  │  • No write secrets                     │         │
│  │  → AI Agent executes the markdown body  │         │
│  └──────────────┬──────────────────────────┘         │
│                 │                                    │
│                 ▼                                    │
│         Proposed Output (artifact)                   │
│                 │                                    │
│                 ▼                                    │
│         Threat Detection (AI-powered scan)           │
│                 │                                    │
│        ✓ safe / ✗ suspicious                         │
│                 │                                    │
│                 ▼                                    │
│         Write Job (scoped write token)               │
│         → applies issue / comment / discussion       │
└──────────────────────────────────────────────────────┘
```

## Why Separate Observatory from Subjects?

Two reasons:

1. **Separation of concerns.** Subject agents are optimized to act quickly on specific events. Observatory agents are optimized to read broadly and reason over patterns. Mixing the two produces agents that are mediocre at both.

2. **Trust and auditability.** When a subject agent misbehaves, you want a separate, independent layer to catch it — not an internal self-check inside the same agent. The observatory layer is structurally biased toward skepticism of the subject layer.

## Workflow-to-Workflow Communication

The observatory agents do not directly modify subject agents. The communication channel is *humans*:

```
Audit Workflows  →  opens GitHub issue  →  human reviews  →  human (or downstream agent) updates subject agent's prompt
```

This deliberate friction is a feature, not a limitation. It keeps humans in the loop on every meaningful change to the agent fleet's configuration.

## Tunable Parameters

Each workflow's behavior can be tuned through:

- **Frontmatter** (triggers, permissions, safe-outputs limits) — requires `gh aw compile` after changes
- **Markdown body** (the agent's instructions) — takes effect on the next run, no recompile needed
- **Secrets and environment variables** — configured in repo settings

## Extending This Demo

Ideas for extending the observatory:

- **Cost tracker workflow** — pulls token usage from your AI engine's billing API and joins it with workflow run data
- **SLO monitor** — defines per-workflow service-level objectives and alerts on breaches
- **Cross-repo observatory** — uses a Personal Access Token to observe multiple repositories from a central audit repo
