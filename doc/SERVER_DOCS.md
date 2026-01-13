# Server Architecture Documentation

## Overview
This is a lightweight REST API server built with **Node.js** and **Express**. It serves as a backend for a Flutter Task Manager application.
It provides persistent storage using a local JSON file (`database.json`), simulating a real database environment.

## Technical Specifications
- **Runtime:** Node.js
- **Framework:** Express.js
- **Data Persistence:** File-based (`database.json`).
- **Data Format:** JSON.
- **Port:** 3000 (default).

## Data Model (Task)
Each item in the database follows this schema:
```typescript
interface Task {
  id: string;          // UUID v4
  title: string;       // Required
  subtitle: string;    // Optional, defaults to ""
  isCompleted: boolean;// Defaults to false
  createdAt: string;   // ISO 8601 Date String
}
```

## API Endpoints

| Method | Path | Description | Request Body | Response |
| :--- | :--- | :--- | :--- | :--- |
| **GET** | `/tasks` | Retrieve all tasks. | None | `200 OK` + `Task[]` |
| **POST** | `/tasks` | Create a new task. | `{ title: string, subtitle?: string }` | `201 Created` + `Task` |
| **PUT** | `/tasks/:id` | Update task details. | Partial `Task` (e.g., `{ isCompleted: true }`) | `200 OK` + Updated `Task` |
| **DELETE** | `/tasks/:id` | Remove a task. | None | `204 No Content` |

## Persistence Logic
- **Read:** On every request, the server reads `database.json`.
- **Write:** On every modification (`POST`, `PUT`, `DELETE`), the server rewrites the entire `database.json` file.
- **Fail-safe:** If `database.json` is missing, the server creates it automatically with an empty array `[]`.

## Usage
1. **Start Server:** `node server.js`
2. **Reset Data:** Delete `database.json` and restart server.
