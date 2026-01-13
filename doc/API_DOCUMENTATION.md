# API Documentation - Task Manager

**Base URL:** `http://localhost:3000`

This API is designed for learning Flutter integration. It mimics a simple task management backend.

## Endpoints

### 1. Get All Tasks
Fetch the list of all tasks.
- **URL:** `/tasks`
- **Method:** `GET`
- **Response (200 OK):**
  ```json
  [
    {
      "id": "unique-id-1",
      "title": "Learn API",
      "subtitle": "Understand GET and POST",
      "isCompleted": false,
      "createdAt": "2023-10-27T10:00:00.000Z"
    }
  ]
  ```

### 2. Create a Task
Add a new task to the list.
- **URL:** `/tasks`
- **Method:** `POST`
- **Headers:** `Content-Type: application/json`
- **Body:**
  ```json
  {
    "title": "Buy Milk",
    "subtitle": "2 packets of full cream milk"
  }
  ```
- **Response (201 Created):** Returns the created object with its new `id`.

### 3. Update a Task
Update details of a specific task (e.g., mark as done).
- **URL:** `/tasks/:id` (Replace `:id` with the actual ID)
- **Method:** `PUT`
- **Headers:** `Content-Type: application/json`
- **Body:** (Send only fields you want to update)
  ```json
  {
    "isCompleted": true
  }
  ```
- **Response (200 OK):** Returns the updated object.

### 4. Delete a Task
Remove a task from the list.
- **URL:** `/tasks/:id`
- **Method:** `DELETE`
- **Response (204 No Content):** Empty response body.

---

## Connection Guide for Flutter

| Platform | Base URL |
| :--- | :--- |
| **Android Emulator** | `http://10.0.2.2:3000` |
| **iOS Simulator** | `http://localhost:3000` |
| **Web Browser** | `http://localhost:3000` |
| **Physical Device** | `http://<YOUR_PC_IP>:3000` |
