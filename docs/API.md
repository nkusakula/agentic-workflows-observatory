# TaskFlow API Reference

Base URL: `http://localhost:3000`

---

## GET /health

Health check. Returns 200 OK when the server is running.

**Response**
```json
{ "status": "ok" }
```

---

## GET /tasks

Returns all tasks.

**Response**
```json
{
  "tasks": [
    { "id": 1, "title": "Buy milk", "done": false, "dueDate": null }
  ]
}
```

---

## POST /tasks

Create a new task.

**Request body**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | Yes | Task title (non-empty) |
| dueDate | string (ISO 8601) | No | Optional due date |

**Response** 201 Created
```json
{ "id": 1, "title": "Buy milk", "done": false, "dueDate": null }
```

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
```json
{ "error": "description of the problem" }
```
