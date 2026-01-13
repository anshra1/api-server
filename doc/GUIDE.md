# Step-by-Step Guide: Building and Consuming Your Local API

This guide walks you through setting up a local Node.js server, testing it with Postman, and preparing to connect it to your Flutter application.

## Phase 1: Server Setup (Backend)

### Step 1: Initialize the Project
We need to create a `package.json` file to manage our dependencies.
*   **Command:** `npm init -y`
*   **What it does:** Creates a default configuration file for a Node.js project.

### Step 2: Install Dependencies
We need a few libraries to make the server work efficiently.
*   **Command:** `npm install express cors body-parser uuid`
*   **Breakdown:**
    *   `express`: The web framework to handle API requests.
    *   `cors`: Allows your Flutter app (running on a different "origin") to talk to this server.
    *   `body-parser`: Helps read JSON data sent from your app.
    *   `uuid`: Generates unique IDs for your data items.

### Step 3: Create the Server Code
We will create a file named `server.js`. This file will contain:
*   The "Database" (a simple variable in code).
*   The logic for `GET`, `POST`, `PUT`, and `DELETE` requests.
*   The command to start listening on port 3000.

### Step 4: Run the Server
*   **Command:** `node server.js`
*   **Output:** You should see "Server running on http://localhost:3000".

---

## Phase 2: Testing with Postman

Before writing any Flutter code, you must verify the API works.

### Step 1: Create a Collection
Open Postman and create a new collection named "Flutter Practice API".

### Step 2: Test "Get All Tasks"
*   **Method:** `GET`
*   **URL:** `http://localhost:3000/tasks`
*   **Expected Result:** An empty list `[]` (since we haven't added anything yet).

### Step 3: Test "Create Task"
*   **Method:** `POST`
*   **URL:** `http://localhost:3000/tasks`
*   **Body:** Select "Raw" -> "JSON"
    ```json
    {
      "title": "Learn API",
      "subtitle": "Understand GET and POST"
    }
    ```
*   **Expected Result:** The task object you just created, with a new `id`.

---

## Phase 3: Flutter Integration

### Step 1: Android Emulator Configuration
If you use the Android Emulator, `localhost` refers to the emulator itself, not your computer.
*   **Solution:** Use the special IP `10.0.2.2` instead of `localhost`.
*   **URL:** `http://10.0.2.2:3000/tasks`

### Step 2: iOS Simulator / Web
*   **iOS/Web:** You can continue using `http://localhost:3000/tasks`.

### Step 3: Physical Device
If testing on a real phone:
1.  Ensure phone and computer are on the same Wi-Fi.
2.  Find your computer's local IP (e.g., `192.168.1.5`).
3.  Use `http://192.168.1.5:3000/tasks`.

---

**Ready to start? Let the AI know to execute Phase 1!**
