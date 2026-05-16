# API Reference

This document provides detailed information about the TaskFlow API endpoints, request/response schemas, and error handling.

## Base URL

```
http://localhost:3000
```

## Authentication

Currently, the API does not require authentication. This may change in future versions.

## Endpoints

### Health Check

Check if the server is running and healthy.

**Endpoint:** `GET /health`

**Response:**
```json
{
  "status": "ok"
}
```

**Status Codes:**
- `200` - Success

---

### List All Tasks

Retrieve all tasks in the system.

**Endpoint:** `GET /tasks`

**Response:**
```json
{
  "tasks": [
    {
      "id": 1,
      "title": "Example task",
      "done": false
    }
  ]
}
```

**Status Codes:**
- `200` - Success

---

### Create a New Task

Add a new task to the system.

**Endpoint:** `POST /tasks`

**Request Body:**
```json
{
  "title": "String (required) - The title of the task"
}
```

**Validation Rules:**
- `title` is required
- `title` must be a non-empty string
- `title` will be trimmed of whitespace

**Response:**
```json
{
  "id": 2,
  "title": "Example task",
  "done": false
}
```

**Status Codes:**
- `201` - Created (success)
- `400` - Bad Request (missing or invalid title)

**Error Response Format:**
```json
{
  "error": "title required"
}
```

---

### Update a Task

Partially update an existing task by ID.

**Endpoint:** `PATCH /tasks/:id`

**Path Parameters:**
- `id` (number, required) - The unique identifier of the task to update

**Request Body:**
```json
{
  "title": "String (optional) - New title for the task",
  "done": "Boolean (optional) - Whether the task is completed"
}
```

**Patchable Fields:**
- `title` - Updates the task title (string)
- `done` - Marks task as completed or incomplete (boolean)

**Response:**
```json
{
  "id": 1,
  "title": "Updated task title",
  "done": true
}
```

**Status Codes:**
- `200` - Success (task updated)
- `404` - Not Found (task with specified ID doesn't exist)

**Error Response Format:**
```json
{
  "error": "not found"
}
```

---

## Error Handling

All errors return consistent JSON response objects with an `error` field.

### Error Response Format
```json
{
  "error": "Error message describing what went wrong"
}
```

### Common Error Scenarios

#### 400 Bad Request
- **Cause:** Missing required fields or invalid data format
- **Example:** Missing `title` field in POST /tasks
- **Response:** `{"error": "title required"}`

#### 404 Not Found
- **Cause:** Requested resource doesn't exist
- **Example:** Non-existent task ID in PATCH /tasks/:id
- **Response:** `{"error": "not found"}`

#### 405 Method Not Allowed
- **Cause:** HTTP method not supported for endpoint
- **Example:** PUT /tasks (not implemented)
- **Response:** `{"error": "not found"}` (current server implementation)

#### 500 Internal Server Error
- **Cause:** Unexpected server errors
- **Example:** JSON parsing errors, server crashes
- **Response:** Server error with stack trace in development

## Data Types

### Task Object
```json
{
  "id": "number - Unique identifier for the task",
  "title": "string - The task title",
  "done": "boolean - Completion status"
}
```

### ID Parameter
- **Type:** number
- **Range:** Positive integers starting from 1
- **Auto-increment:** New tasks get the next available ID

### Title Field
- **Type:** string
- **Constraints:** Non-empty, whitespace-trimmed
- **Max length:** Not enforced (server stores as-is)

### Done Field
- **Type:** boolean
- **Values:** `true` (completed) or `false` (pending)
- **Default:** `false` for new tasks

## Examples

### Create and Complete a Task

```bash
# Create a new task
curl -X POST http://localhost:3000/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Complete API documentation"}'

# Response:
# {"id": 1, "title": "Complete API documentation", "done": false}

# Mark task as completed
curl -X PATCH http://localhost:3000/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"done": true}'

# Response:
# {"id": 1, "title": "Complete API documentation", "done": true}
```

### Error Handling Example

```bash
# Try to create task without title
curl -X POST http://localhost:3000/tasks \
  -H "Content-Type: application/json" \
  -d '{}'

# Response:
# {"error": "title required"}

# Try to update non-existent task
curl -X PATCH http://localhost:3000/tasks/999 \
  -H "Content-Type: application/json" \
  -d '{"done": true}'

# Response:
# {"error": "not found"}
```

## Rate Limiting

Currently, no rate limiting is implemented. This may be added in future versions to prevent abuse.

## Versioning

This is version 1.0 of the API. Future versions will maintain backward compatibility where possible.

## Changelog

### v1.0 (Current)
- Initial API implementation
- Basic CRUD operations for tasks
- Health check endpoint
- Error handling with consistent response format