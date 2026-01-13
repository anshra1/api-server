# Project Plan: Task Manager API for Flutter Practice

## 1. Project Goal
Create a lightweight, local REST API server to simulate a real-world backend. This allows the user (a Flutter developer) to practice:
- HTTP requests (`GET`, `POST`, `PUT`, `DELETE`).
- JSON serialization/deserialization.
- Handling loading states and errors.
- Testing API endpoints with Postman.

## 2. Technical Stack
- **Backend Environment:** Node.js (Runtime).
- **Framework:** Express.js (Minimalist web framework).
- **Database:** In-memory array (Data resets on server restart, keeping it simple).
- **Tools:** Postman (for verification).

## 3. Data Model
**Entity: Task**
```json
{
  "id": "string (uuid)",
  "title": "string",
  "subtitle": "string",
  "isCompleted": "boolean",
  "createdAt": "ISO 8601 Date String"
}
```

## 4. API Endpoints Specification
Base URL: `http://localhost:3000`

### A. List All Tasks
- **Method:** `GET`
- **Path:** `/tasks`
- **Response:** `200 OK` - Array of Task objects.

### B. Get Single Task
- **Method:** `GET`
- **Path:** `/tasks/:id`
- **Response:** 
  - `200 OK` - Single Task object.
  - `404 Not Found` - If ID doesn't exist.

### C. Create Task
- **Method:** `POST`
- **Path:** `/tasks`
- **Body:** 
  ```json
  {
    "title": "Buy groceries",
    "subtitle": "Milk, Eggs, Bread"
  }
  ```
- **Response:** `201 Created` - The created Task object (with generated `id`).

### D. Update Task
- **Method:** `PUT`
- **Path:** `/tasks/:id`
- **Body:** (Partial updates allowed)
  ```json
  {
    "isCompleted": true
  }
  ```
- **Response:** `200 OK` - The updated Task object.

### E. Delete Task
- **Method:** `DELETE`
- **Path:** `/tasks/:id`
- **Response:** `204 No Content`.

## 5. Implementation Roadmap
1.  **Environment Setup:** Initialize Node.js project and install `express`, `cors` (to allow requests from Flutter web/emulator), and `uuid`.
2.  **Server Logic:** Implement `server.js` containing the in-memory database and route handlers.
3.  **Verification:** User tests endpoints using Postman.
4.  **Flutter Integration:** User connects their Flutter app to `http://localhost:3000`.

## 6. Next Steps for AI Agent
- Initialize the project structure.
- Install necessary dependencies.
- Write the `server.js` code.
- Start the server.
