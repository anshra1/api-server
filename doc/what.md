1. Advanced Serialization (No more manual parsing)
  Writing json['title'] manually is slow and dangerous (typos cause
  crashes).
   * What to learn: `freezed` and `json_serializable`.
   * The Skill: Automating the conversion of JSON to Dart classes.
   * Why: It handles null safety, default values, and list
     conversions automatically. If the API changes, your code
     generation fails at compile time (good!) instead of crashing at
     runtime (bad!).

  2. Client Generators (Retrofit)
  Instead of writing dio.get('/tasks') manually in every function,
  define an interface.
   * What to learn: `retrofit` (for Dart).
   * The Skill: You define an abstract class:

   1     @GET("/tasks")
   2     Future<List<Task>> getTasks();
      And the library writes the actual HTTP request code for you.
   * Why: It keeps your API logic clean, readable, and consistent.

  3. Robust Error Handling (UI Mapping)
  The server sends 401 Unauthorized or 422 Unprocessable Entity.
  Your user doesn't speak HTTP codes.
   * The Skill: Mapping Server Errors to UI States.
       * Network Exceptions: "Please check your internet
         connection."
       * 401: Trigger a "Session Expired" dialog and redirect to
         Login.
       * 422 (Validation): If the server says {"field": "email",
         "error": "invalid"}, highlight the specific Email Textbox
         in Red.
   * What to practice: Creating a custom Failure class in Dart to
     categorize these errors.

  4. Interceptors (The Middleman)
  You need to do things on every request (like adding the token) or
  every response (like checking for errors).
   * What to learn: Dio Interceptors.
   * Key Use Cases:
       * Auth Interceptor: Automatically getting the token from
         Secure Storage and adding Authorization: Bearer xyz to the
         header.
       * Token Refresh: If a request fails with 401, automatically
         pause the request, refresh the token, and retry the
         original request transparently (the user never knows!).
       * Logger: logging requests/responses to the console (pretty
         printing JSON) so you can debug easily.

  5. Caching & Offline-First
  Mobile devices lose connection constantly (elevators, tunnels).
   * The Skill: The "Stale-While-Revalidate" strategy.
       1. Show data from the Local Database (Isar, Hive, SQFLite)
          immediately.
       2. Fetch new data from API in the background.
       3. Update the UI and save new data to the Local DB.
   * What to learn: flutter_bloc (HydratedBloc) or
     dio_cache_interceptor.

  6. Optimistic UI Updates
  When a user "Likes" a post or "Deletes" a task, don't wait 2
  seconds for the server to say "OK".
   * The Skill:
       1. Update the Flutter UI instantly (turn the heart red).
       2. Send the API request in the background.
       3. If the API fails, rollback the UI change and show an error
          toast.
   * Why: This makes your app feel incredibly fast and responsive
     ("Native feel").

  7. Debugging Network Traffic
  Sometimes print() isn't enough. You need to see exactly what is
  leaving the phone.
   * What to learn:
       * DevTools Network Tab: The built-in Flutter tool.
       * Proxy Tools: Charles Proxy, Proxyman, or Fiddler.
   * The Skill: Routing your phone's traffic through your computer
     to inspect headers, cookies, and exact JSON payloads.