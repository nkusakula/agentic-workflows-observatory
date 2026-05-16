#!/usr/bin/env pwsh
# seed-demo-data.ps1
# Creates realistic labels, issues, and PRs to simulate a team using the TaskFlow API.
# Run from the repo root: pwsh scripts/seed-demo-data.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "🌱 Seeding demo data for agentic-workflows-observatory..." -ForegroundColor Cyan

# ── Labels ──────────────────────────────────────────────────────────────────

$labels = @(
    @{ name="type:bug";           color="d73a4a"; description="Something isn't working" }
    @{ name="type:feature";       color="a2eeef"; description="New feature request" }
    @{ name="type:docs";          color="0075ca"; description="Documentation improvement" }
    @{ name="type:question";      color="d876e3"; description="Further information is requested" }
    @{ name="type:performance";   color="e4e669"; description="Performance concern" }
    @{ name="area:api";           color="f9d0c4"; description="HTTP API surface" }
    @{ name="area:db";            color="f9d0c4"; description="Database / persistence" }
    @{ name="area:auth";          color="f9d0c4"; description="Authentication / authorization" }
    @{ name="area:ci";            color="f9d0c4"; description="CI / build / tooling" }
    @{ name="priority:high";      color="b60205"; description="Blocks users or causes data loss" }
    @{ name="priority:medium";    color="fbca04"; description="Significant friction, workarounds exist" }
    @{ name="priority:low";       color="0e8a16"; description="Minor impact" }
    @{ name="needs-info";         color="e4e669"; description="More information needed" }
    @{ name="good-first-issue";   color="7057ff"; description="Good for newcomers" }
    @{ name="review:ready";       color="0e8a16"; description="PR passes basic quality checks" }
    @{ name="review:needs-tests"; color="d93f0b"; description="Code changes without test changes" }
    @{ name="review:needs-description"; color="fbca04"; description="PR description is missing or thin" }
    @{ name="review:large-pr";    color="e4e669"; description="500+ lines changed; consider splitting" }
    @{ name="observatory";        color="1d76db"; description="Created by an observatory workflow" }
    @{ name="audit";              color="5319e7"; description="Created by the audit meta-agent" }
    @{ name="needs-triage";       color="e4e669"; description="Not yet triaged" }
)

Write-Host "  Creating labels..." -ForegroundColor Yellow
foreach ($l in $labels) {
    gh label create $l.name --color $l.color --description $l.description --force 2>$null
}
Write-Host "  ✅ Labels created" -ForegroundColor Green

# ── Issues ──────────────────────────────────────────────────────────────────

Write-Host "  Creating issues..." -ForegroundColor Yellow

gh issue create `
    --title "500 error when POST /tasks body is missing Content-Type header" `
    --body @"
## Bug Report

**What happened:**
Sending a POST /tasks request without setting Content-Type: application/json causes a 500 Internal Server Error instead of a helpful 400 Bad Request.

**Steps to reproduce:**
``````bash
curl -X POST http://localhost:3000/tasks -d '{"title":"Buy milk"}'
# Missing Content-Type header -> 500
``````

**Expected:** 400 Bad Request with a clear error message.
**Actual:** 500 Internal Server Error with no body.

**Environment:** Node.js 20, macOS 14
"@ `
    --label "type:bug,area:api,priority:high"

gh issue create `
    --title "Add due date support to tasks" `
    --body @"
## Feature Request

It would be useful to set a due date when creating or updating a task.

**Proposed API change:**
``````json
POST /tasks
{
  "title": "Submit expense report",
  "dueDate": "2026-05-20T17:00:00Z"
}
``````

The field should be optional and default to null. PATCH /tasks/:id should also support updating dueDate.

**Use case:** Our team uses TaskFlow for sprint tracking and needs to tie tasks to sprint deadlines.
"@ `
    --label "type:feature,area:api,priority:medium"

gh issue create `
    --title "How do I filter tasks by completion status?" `
    --body @"
## Question

I want to list only incomplete tasks. Is there a query parameter for that?

I tried GET /tasks?done=false but it returns all tasks regardless.

Looking at the source code I do not see any filtering logic - is this on the roadmap or am I missing something?
"@ `
    --label "type:question,needs-info,priority:low"

gh issue create `
    --title "PATCH /tasks/:id silently ignores unknown fields" `
    --body @"
## Bug Report

When I send a PATCH with an unrecognized field, the API returns 200 OK but silently drops the field with no warning.

**Example:**
``````bash
curl -X PATCH http://localhost:3000/tasks/1 \
  -H 'Content-Type: application/json' \
  -d '{"assignee": "alice"}'
# Returns 200 OK, but assignee is not stored and no warning is given
``````

This is confusing for API consumers who may think their data was saved when it wasn't. At minimum, unknown fields should be called out in the response.
"@ `
    --label "type:bug,area:api,priority:medium"

gh issue create `
    --title "GET /tasks response time degrades with large task lists" `
    --body @"
## Performance Issue

We've been using TaskFlow in a load test environment and noticed that GET /tasks response time scales linearly with the number of tasks in the in-memory store.

**Benchmarks:**
| Tasks  | Median response time |
|--------|---------------------|
| 100    | 2ms                 |
| 1,000  | 18ms                |
| 10,000 | 190ms               |

We'd appreciate either pagination support (?limit= / ?offset=) or at least documentation confirming this is intentional and what the recommended scale ceiling is.
"@ `
    --label "type:performance,area:api,priority:medium"

gh issue create `
    --title "API endpoint documentation missing from README" `
    --body @"
## Documentation Request

The README explains how to start the server but doesn't document the API endpoints, request/response schemas, or error codes.

Could we add an API Reference section (or a separate docs/API.md) covering:
- GET /health
- GET /tasks
- POST /tasks (request body schema, validation rules)
- PATCH /tasks/:id (which fields are patchable)
- Error response format

Happy to contribute a draft if the maintainers can confirm the intended schema.
"@ `
    --label "type:docs,good-first-issue,priority:low"

Write-Host "  ✅ Issues created" -ForegroundColor Green

# ── Pull Requests ────────────────────────────────────────────────────────────

Write-Host "  Creating PRs..." -ForegroundColor Yellow
$originalBranch = git branch --show-current
$serverPath = "src/server.js"

# PR 1: feat/add-due-date
git checkout -q -b feat/add-due-date

$content = Get-Content $serverPath -Raw
$content = $content -replace `
    'const task = \{ id: nextId\+\+, title: body\.title, done: false \};', `
    'const task = { id: nextId++, title: body.title, done: false, dueDate: body.dueDate || null };'
$content = $content -replace `
    'if \(typeof body\.title === "string"\) task\.title = body\.title;', `
    "if (typeof body.title === `"string`") task.title = body.title;`n    if (typeof body.dueDate !== `"undefined`") task.dueDate = body.dueDate;"
Set-Content $serverPath $content

git add $serverPath
git -c user.email="nkusakula@github.com" -c user.name="nkusakula" commit -q -m "feat: add dueDate field to task creation and updates"
git push -q -u origin feat/add-due-date

gh pr create `
    --title "feat: add dueDate field to tasks" `
    --body @"
## Summary

Adds optional dueDate field to tasks, resolving #2.

## Changes
- POST /tasks now accepts an optional dueDate (ISO 8601 string or null)
- PATCH /tasks/:id now supports updating dueDate
- New tasks default to dueDate: null

## Testing
Manually tested with:
``````bash
curl -X POST http://localhost:3000/tasks \
  -H 'Content-Type: application/json' \
  -d '{"title":"Sprint planning","dueDate":"2026-05-20T09:00:00Z"}'
``````

Closes #2
"@ `
    --label "review:needs-tests,area:api"

git checkout -q $originalBranch

# PR 2: fix/body-validation
git checkout -q -b fix/body-validation

$content = Get-Content $serverPath -Raw
$content = $content -replace `
    'if \(!body\.title\) return send\(res, 400, \{ error: "title required" \}\);', `
    "if (!body.title || typeof body.title !== `"string`" || body.title.trim() === `"`") {`n      return send(res, 400, { error: `"title must be a non-empty string`" });`n    }"
Set-Content $serverPath $content

git add $serverPath
git -c user.email="nkusakula@github.com" -c user.name="nkusakula" commit -q -m "fix: improve input validation for POST /tasks"
git push -q -u origin fix/body-validation

gh pr create `
    --title "fix: improve input validation for POST /tasks" `
    --body @"
## Summary

Improves error handling for malformed requests to POST /tasks, addressing #1.

## Problem
Previously !body.title would pass for an empty string after trimming, and provided no useful message when body was malformed.

## Changes
- Validates that title is a non-empty string (not just truthy)
- Returns 400 with a more descriptive error message

Fixes #1
"@ `
    --label "review:ready,area:api"

git checkout -q $originalBranch

# PR 3: docs/api-reference
git checkout -q -b docs/api-reference

@"
# TaskFlow API Reference

Base URL: ``http://localhost:3000``

---

## GET /health

Health check. Returns 200 OK when the server is running.

**Response**
``````json
{ "status": "ok" }
``````

---

## GET /tasks

Returns all tasks.

**Response**
``````json
{
  "tasks": [
    { "id": 1, "title": "Buy milk", "done": false, "dueDate": null }
  ]
}
``````

---

## POST /tasks

Create a new task.

**Request body**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | Yes | Task title (non-empty) |
| dueDate | string (ISO 8601) | No | Optional due date |

**Response** 201 Created
``````json
{ "id": 1, "title": "Buy milk", "done": false, "dueDate": null }
``````

**Errors**
| Status | Reason |
|--------|--------|
| 400 | title is missing or empty |

---

## PATCH /tasks/:id

Update an existing task.

**Request body** (all fields optional)
| Field | Type | Description |
|-------|------|-------------|
| title | string | New title |
| done | boolean | Completion status |
| dueDate | string or null | New due date |

**Response** 200 OK - the updated task.

**Errors**
| Status | Reason |
|--------|--------|
| 404 | Task not found |

---

## Error Format

All errors return JSON:
``````json
{ "error": "description of the problem" }
``````
"@ | Set-Content "docs/API.md"

git add "docs/API.md"
git -c user.email="nkusakula@github.com" -c user.name="nkusakula" commit -q -m "docs: add API reference documentation"
git push -q -u origin docs/api-reference

gh pr create `
    --title "docs: add API reference documentation" `
    --body @"
## Summary

Adds docs/API.md with full endpoint reference, closing #6.

Covers all four endpoints with request/response schemas and error codes.

Closes #6
"@ `
    --label "review:ready,type:docs,good-first-issue"

git checkout -q $originalBranch

# ── Done ─────────────────────────────────────────────────────────────────────

$issueCount = (gh issue list --state open --json number | ConvertFrom-Json).Count
$prCount    = (gh pr list --state open --json number | ConvertFrom-Json).Count

Write-Host ""
Write-Host "🎉 Demo data seeded! Your repo now has:" -ForegroundColor Cyan
Write-Host "   • $issueCount open issues" -ForegroundColor White
Write-Host "   • $prCount open PRs" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "   gh aw compile .github/workflows/metrics-collector.md" -ForegroundColor White
Write-Host "   gh aw run metrics-collector" -ForegroundColor White
