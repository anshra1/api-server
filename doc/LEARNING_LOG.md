w# Learning Log & Progress Tracker

## 1. Concepts Mastered (What we have learned)

### Backend & API Fundamentals
- **Node.js Server:** Built a simple REST API using Express.js.
- **Data Persistence:** Implemented a file-based database (`database.json`) to save data across server restarts.
- **REST Verb Semantics:**
    - `GET`: Fetching data.
    - `POST`: Creating new resources.
    - `PUT`: Updating existing resources (idempotent).
    - `DELETE`: Removing resources.
- **Connectivity:** Addressed the difference between `localhost` (iOS/Web) and `10.0.2.2` (Android Emulator).

### Flutter Networking (The "Scripting" Phase)
- **Dio Library:** Used for making HTTP requests (simpler than default `http`).
- **Raw JSON Handling:** Initially used `Map<String, dynamic>` to manipulate data, understanding its flexibility and its risks (typos, runtime errors).
- **Basic State Handling:** Managed loading states (`bool _isLoading`) and error messages manually with `setState`.

### Clean Architecture (The "Engineering" Phase)
- **Separation of Concerns:**
    - **UI Layer:** (Widgets) only cares about *displaying* data.
    - **Service Layer:** (`ApiService`) only cares about *fetching* data.
    - **Data Layer:** (`TaskModel`) only cares about *structuring* data.
- **Strong Typing:** Replaced loose JSON maps with a dedicated `Task` class (factory constructors, `toJson`). This prevents "stringly typed" errors.

## 2. Current Focus (What we are learning right now)

### Advanced State Management (Cubit/BLoC)
- **Moving away from `setState`:** Solved the problem of mixing UI rendering logic with business logic.
- **Cubit Pattern:**
    - **State:** Defining strict states (`TaskInitial`, `TaskLoading`, `TaskLoaded`, `TaskError`) so the UI can't be in an "undefined" state.
    - **Cubit:** A class that functions as the "brain," holding the data and exposing functions to modify it (`loadTasks`, `addTask`).
- **Reactive UI:** Using `BlocBuilder` to automatically rebuild the UI when the state changes, without manual `setState` calls.
- **Optimistic UI:** Updating the local list *before* the server responds to make the app feel instant (and reverting if it fails).

## 3. Agent's Understanding of the Project
You are currently transitioning from a "Junior Developer" workflow (making it work in one file) to a "Senior Developer" workflow (making it scalable, maintainable, and robust).

The project is a **Task Manager** app that serves as a playground for these concepts.
- **Current Status:** The app works with a real backend, uses Clean Architecture, and is powered by Cubit.
- **Next Logical Steps:**
    1.  **UX Polish:** Creating a dedicated Form Screen for adding tasks (instead of hardcoded "New Task" strings).
    2.  **Filtering:** Implementing "Show Completed Only" using Cubit logic.
    3.  **Authentication:** (Future) Securing the API.

## 4. Glossary of Terms
- **Serialization:** Converting an Object (Task) to a String (JSON) for transport.
- **Deserialization:** Converting a String (JSON) back to an Object (Task).
- **Singleton:** Ensuring a class has only one instance (often used for Services, though we are using Dependency Injection via Provider here).
- **Optimistic Update:** Assuming a network request will succeed and updating the UI immediately to improve perceived performance.
