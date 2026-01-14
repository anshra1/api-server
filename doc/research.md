Foundations of APIs
APIs (Application Programming Interfaces) are the “waiters” of software: they take requests from clients and deliver responses from servers. In concrete terms, an API is a set of rules and protocols that allows one program to talk to another. As one guide explains, an API “is a set of protocols that enable different software components to communicate and transfer data”
. In real life, think of a restaurant: you (the client) give your order (request) to the waiter (API), the kitchen (server) prepares the meal, and the waiter brings back your food (response)
. You don’t need to know how the kitchen cooks it – you just care that you asked for a hamburger and got it. In computing, the client-server model underlies this exchange. A client (for example, a mobile app or web browser) sends a request to a server (a remote computer or cloud service) over a network. The server processes the request and sends back a response. Typically this follows a request–response pattern using a well-defined protocol
. For example, you might send “GET /users/123” to fetch user data; the server responds with the user details or an error. All communication follows a shared protocol (language) – usually HTTP for web APIs – so both sides understand each other
. APIs usually exchange data in a common format. Today most APIs use JSON (JavaScript Object Notation) because it’s lightweight, text-based, and easy for humans and machines to read and write
. JSON represents data as nested key-value pairs (objects) and lists (arrays). For instance, a user record might be { "id": 123, "name": "Alice" }. JSON was designed as a data-interchange format because its structure is simple and ubiquitous: it’s “easy for humans to read and write” and “easy for machines to parse and generate”
. Behind the scenes, APIs on the web usually use HTTP (Hypertext Transfer Protocol). HTTP is the foundational protocol of the Internet’s communication, operating a request–response model over TCP/IP
. When an app calls an API, it typically sends an HTTP request (with a method like GET or POST) to a URL, and the server returns an HTTP response (with a status code and data). HTTP is stateless, meaning each request is independent: the server doesn’t remember past requests. This fits the REST architectural style (discussed below) and keeps servers scalable
. REST (REpresentational State Transfer) is a popular style for web APIs. A REST API is not a strict standard but a set of conventions: resources (like “users” or “orders”) are identified by URLs, and standard HTTP methods (GET, POST, etc.) perform operations on them
. REST emphasizes stateless communication and a uniform interface
. For example, GET /users/123 might fetch user #123, POST /users creates a new user, etc. Because of its simplicity and compatibility with HTTP, REST has become the dominant style for web APIs
. Statelessness means each API call must contain all needed context: the server cannot rely on previous interactions to understand the request
. For example, if you make a series of queries, each request needs its own credentials or session info. This independence allows scaling: any server can handle any request. Finally, why do mobile apps need APIs? A mobile app often runs on a limited device and must fetch data (like user profiles, messages, or product listings) from a central system. Instead of bundling all data into the app, apps call backend APIs to retrieve or update data. In short, “the value is in the data – and being able to access and manage that data” is what makes an app useful
. APIs let the app communicate with powerful backend services (databases, business logic, etc.) from the phone. For example, when you scroll a news feed, the app issues API requests to load each page of posts. This separation (app UI vs. server data) makes apps lightweight and dynamic.
HTTP Deep Dive
Every API call is an HTTP request. An HTTP request has a method, URL, headers, and an optional body. The server returns an HTTP status code, its own headers, and usually a body (often JSON). Let’s cover the key pieces:
HTTP Methods (Verbs). Common methods map to CRUD actions.
GET retrieves data. Analogy: looking up information on a menu without changing anything. A GET request is read-only (it should not alter server state). For example:
GET /products/123 HTTP/1.1
Host: api.example.com
This asks for product #123. In Flutter with Dio, you’d do:
Response res = await dio.get('/products/123');
print(res.data); // JSON with product details
(GET typically has no body
.)
POST creates a new resource. Analogy: submitting a form to add an entry (like writing in a guestbook). The client sends data in the request body. Example:
POST /products HTTP/1.1
Host: api.example.com
Content-Type: application/json

{ "name": "Shoe", "color": "red" }
This tells the server to make a new product with given attributes. In Dio:
Response res = await dio.post('/products', data: {"name": "Shoe", "color": "red"});
print(res.statusCode); // e.g. 201 Created
As Postman notes, “The POST method is used to create new resources.”
PUT replaces an existing resource entirely. Analogy: rewriting a file from scratch. You send the full new state. Example:
PUT /products/123 HTTP/1.1
Host: api.example.com
Content-Type: application/json

{ "id": 123, "name": "Boot", "color": "black" }
All fields of product 123 are replaced with this data. In Dio:
await dio.put('/products/123', data: {"id": 123, "name": "Boot", "color": "black"});
(PUT is idempotent; repeating it has the same effect
.)
PATCH updates part of a resource. Analogy: editing one paragraph in a document rather than the whole document. Example:
PATCH /products/123 HTTP/1.1
Host: api.example.com
Content-Type: application/json

{ "color": "blue" }
Only the color of product 123 changes (other fields stay). In Dio:
await dio.patch('/products/123', data: {"color": "blue"});
(PATCH “enables clients to update specific properties”
.)
DELETE removes a resource. Analogy: throwing away an old file. Example:
DELETE /products/123 HTTP/1.1
Host: api.example.com
In Dio:
await dio.delete('/products/123');
This asks the server to delete product 123 (“the DELETE method is used to remove data from a database”
).
These cover the basics. (There are other methods like HEAD, OPTIONS, etc., but they’re less common for CRUD APIs.)
HTTP Headers. Headers are key-value metadata for requests and responses. They convey extra info like content type, auth tokens, caching rules, etc. For example, an API call might include an Authorization: Bearer <token> header or a Content-Type: application/json header. Headers “let the client and the server pass additional information with a message”
. In Dio, headers are set via Options, e.g.:
await dio.get('/secure-data',
  options: Options(headers: {'Authorization': 'Bearer $token'}),
);
The server might reply with headers too (like Content-Type or Cache-Control).
Request Body. Methods like POST, PUT, PATCH usually carry a JSON body. The body contains the data you’re sending (e.g. new object fields). In Dio, you pass a Dart Map or JSON string to data:. For example:
Response res = await dio.post(
  '/orders',
  data: {'item': 'Book', 'quantity': 2},
);
This JSON becomes the request body. GET and DELETE typically don’t use a body (GET shouldn’t have one in RESTful practice).
Status Codes. When the server responds, it includes an HTTP status code indicating the result. Here are common ones with analogies:
200 OK: Success. The request was understood and carried out
. (Analogy: The waiter returns with exactly what you asked for.)
201 Created: Success and a new resource was created
. (Analogy: You ordered a custom cake and the bakery confirms it’s made a new cake.)
400 Bad Request: The server could not process the request because the client sent bad data (e.g. malformed JSON)
. (Analogy: You gave the waiter an order with gibberish on it.)
401 Unauthorized: Authentication is required or has failed
. (Analogy: You tried to enter a secure area without showing your ID card.)
403 Forbidden: The request was valid but the server refuses to fulfill it (you lack permission)
. (Analogy: You have a library card (authenticated) but the librarian says you still can’t borrow a restricted book.)
404 Not Found: The requested resource doesn’t exist
. (Analogy: You ask for the blue t-shirt, but it’s not in stock.)
500 Internal Server Error: The server encountered an unexpected condition
. (Analogy: The kitchen caught on fire and can’t fulfill your order.)
You should always check the status code. In Dio, response.statusCode gives this. For example, after a POST you might expect a 201. In code you can write:
if (res.statusCode == 201) {
  print("Created!");
} else {
  print("Error: ${res.statusCode}");
}
Path vs. Query Parameters. URLs can include path parameters (part of the path) or query parameters (after ?). By convention, path parameters identify specific resources (e.g. /users/123), whereas query parameters filter, sort, or paginate a collection (e.g. /users?role=admin&limit=10). As explained on StackOverflow, path params identify which resource(s) you want, while query params specify how to narrow down or modify the result
. For example:
Path param: GET /cars/456 — fetch car #456.
Query param: GET /cars?color=blue — fetch all blue cars (filter).
In Dio you pass query params as a map:
await dio.get('/cars', queryParameters: {'color': 'blue', 'sortBy': 'year'});
Idempotency. An operation is idempotent if doing it multiple times has the same effect as doing it once. In HTTP, GET, PUT, DELETE (and HEAD) are idempotent: repeating them won’t create duplicate effects. POST is not idempotent (calling it twice usually creates two resources)
. For example, PUT /items/1 with the same data will replace item #1 every time (no additional change). Dio calls follow these rules: using .get() or .delete() can be retried safely; repeating a .post() might create duplicates, so be careful.
Pagination, Filtering, Sorting. When an API could return many items (e.g. thousands of products), it usually paginates results. Think of it like book pages. You might request GET /items?page=2&size=20 to get the second page of 20 items. The response might include metadata (like total count or next-page links). In Dio:
final res = await dio.get('/items', queryParameters: {'page': 2, 'size': 20});
List items = res.data['results'];
Relatedly, filtering lets you narrow results by criteria (e.g. ?status=active), and sorting lets you specify order (e.g. ?sort=-date for descending). These help the client ask for exactly the data it needs. As one API guide notes, implementing pagination, sorting, and filtering “enhances a REST API’s performance by optimizing the server load” and lets clients retrieve precisely the data they need
.
In summary, an HTTP API call looks something like this:
GET /products?page=1&size=10&sort=price%20asc HTTP/1.1
Host: api.example.com
Accept: application/json
Authorization: Bearer <ACCESS_TOKEN>
and the server might respond:
HTTP/1.1 200 OK
Content-Type: application/json

{
  "results": [ { "id": 1, "name": "Shoes", "price": 49.99 }, /*...*/ ],
  "page": 1, "totalPages": 5
}
Where each part (method, status code, headers, JSON body) follows the rules above.
Using Dio in Flutter
To call APIs in Flutter, we can use the Dio package, a powerful HTTP client for Dart/Flutter. Dio builds on basic HTTP functionality by adding features like global configuration, interceptors, cancellation tokens, file uploading/download, and more
. (The standard http package is simpler but lacks some of these advanced features.) For example, with Dio you can set a base URL once, or intercept every request to add headers automatically
. To get started, add dio: ^5.x.x to your pubspec.yaml and import it:
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 10),
));
This creates a Dio instance with a base URL and timeouts. (You could do the same with http, but you’d have to manually set headers on each request; Dio lets you configure them globally
.) Making requests: Use Dio’s methods to make API calls. Example GET and POST:
// GET request
try {
  Response res = await dio.get('/users/123');
  print('User data: ${res.data}');
} on DioException catch (e) {
  print('Error: ${e.response?.statusCode}');
}

// POST request with JSON body
try {
  Response res = await dio.post('/users', data: {
    'name': 'Alice',
    'email': 'alice@example.com'
  });
  print('Created user: ${res.data}');
} on DioException catch (e) {
  print('Error: ${e.response?.statusCode}');
}
Dio automatically serializes the Dart map into JSON when sending, and parses JSON responses into res.data. Parsing responses: After a call, res.data holds the decoded response. You can convert it into your own model classes. For example, if the API returns { "id": 123, "name": "Alice" }, you might write:
class User {
  final int id;
  final String name;
  User.fromJson(Map<String, dynamic> json) 
      : id = json['id'], name = json['name'];
}

// Then, given a Dio response:
User user = User.fromJson(res.data);
Often developers use code-generation (e.g. json_serializable or freezed) to generate .fromJson() code, but you can do it manually for learning. The key is: use a repository or service class (not UI code) to parse JSON into app models
. Error handling: Dio throws exceptions on non-2xx status codes (by default). These are DioExceptions containing rich info
. You should catch them with try/catch. The exception object includes the error type (timeout, response error, etc.) and the server’s response if any. For example:
try {
  await dio.get('/secret-data');
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    print('Unauthorized! Need to login again.');
  } else {
    print('Request error: ${e.message}');
  }
}
Dio’s structured DioException lets you inspect e.type (connection timeout vs. server error) and e.response. This is more convenient than the bare Exception from http
. Timeouts and Cancellation: Dio lets you set timeouts (as above). If a request exceeds the timeout, Dio throws a DioExceptionType.connectionTimeout. You can catch that to retry or show an error. You can also cancel requests. Create a CancelToken, pass it to the call, and later call .cancel() to abort:
CancelToken cancelToken = CancelToken();
dio.get('/reports', cancelToken: cancelToken).catchError((e) {
  if (CancelToken.isCancel(e)) print('Request cancelled');
});

// Later, to cancel:
cancelToken.cancel('User navigated away');
Cancellation is useful if the user navigates away from a screen and you want to stop the network call. The http package doesn’t support this. In summary, Dio adds convenience and power: global base URLs, interceptors (see next section), automatic JSON encoding/decoding, and structured errors
. The trade-off is a tiny bit of overhead, but in real apps the difference is negligible
. For a small app that just fetches one or two resources, http might suffice; but for most production apps with auth, token refresh, file uploads, etc., Dio is preferred
.
Architecture & Best Practices
When building a Flutter app that uses APIs, don’t call APIs directly from your UI widgets. Instead, use a layered architecture (often based on MVVM or Clean Architecture) to separate concerns
. A typical structure splits the app into:
UI Layer (presentation): Flutter widgets (Views) and their ViewModels or controllers. This layer handles displaying data and user interactions.
Data Layer: This includes Repositories and Services. Repositories are the “sources of truth” for data: they fetch data from external sources and provide it to the domain/UI. Services (sometimes called Data Sources) are responsible for the low-level API or database calls. For example, you might have a WeatherRepository interface with a method Future<Weather> getWeather(String city). Its implementation HttpWeatherRepository would use Dio to call the weather API and parse the JSON into a Weather model
. Your UI then calls the repository, not Dio directly. This way, the UI doesn’t know about HTTP or JSON – it just gets Dart objects. As one guide emphasizes, “if your widgets work directly with key-value pairs from a REST API … you’re doing it wrong.” Keeping API logic out of the UI makes code easier to test and maintain
. Repositories also allow mapping between DTOs and domain models
. A DTO (Data Transfer Object) is the raw JSON shape, while a Model/Entity is your app’s internal representation. For instance, a UserDTO might have fields exactly as the API returns, but you might convert it to a User model class used in your UI. This mapping ensures your app isn’t tightly coupled to the API schema. For example:
class UserDTO { final int id; final String name; /*...*/ }
class User { final int id; final String fullName; /*...*/ }

// In repository:
User fromDto(UserDTO dto) {
  return User(id: dto.id, fullName: dto.name);
}
Domain/Business Layer (optional): In more complex apps, you might add use-cases or interactors here, but for many Flutter apps the separation into UI (views/viewmodels) and data (repos/services) is sufficient.
The Flutter documentation provides a helpful visualization of this architecture. For each feature, your Views interact with ViewModels, which talk to Repositories, which in turn call Services (API clients)【84†】. Below is a simplified diagram (click to expand): 
https://docs.flutter.dev/app-architecture/guide
Figure: Flutter MVVM architecture. The UI (View and ViewModel) lives in the UI layer, while Repositories and Services are in the data layer
. In practice, your project’s folder structure might reflect these layers. For example:
lib/
  data/
    models/          # DTOs or models generated from JSON
    services/        # API client classes (wrapping Dio calls)
    repositories/    # Repository implementations
  domain/            # (Optional) Entities and use-cases
  presentation/
    viewmodels/      # ChangeNotifiers, Cubits, or whatever state mgmt
    views/           # Flutter widget screens/pages
  main.dart
Each data layer object has a clear role: Services call the network, Repositories process and cache data, and provide methods for the app. The UI layer only deals with high-level objects and state. This clean separation (“separation of concerns”) helps your app scale and makes testing easier
. Another best practice is to initialize your repositories (and Dio instance) once, often using dependency injection or a provider package. For instance, using the GetIt package, you might register:
GetIt.I.registerLazySingleton<Dio>(() => Dio(BaseOptions(baseUrl: apiBase)));
GetIt.I.registerLazySingleton<UserRepository>(
  () => HttpUserRepository(dio: GetIt.I<Dio>())
);
Then throughout the app you can use GetIt.I<UserRepository>() to get the same instance. This avoids recreating clients and lets you manage things like token refresh in one place
. In summary, don’t call APIs directly in widget build methods. Use repositories and models to abstract away network and JSON parsing. Keep UI, logic, and data separate
. This clean architecture makes your code cleaner, more testable, and easier to maintain.
Authentication & Security
Most real APIs require authentication and enforce authorization. In simple terms, authentication verifies “who you are” (identity), and authorization checks “what you are allowed to do”
. A common analogy is a library: Authentication is checking your ID at the door; authorization is checking your library card to see which sections you can enter
. So a user might be authenticated (username/password OK) but still unauthorized to access certain data (e.g. admin-only reports)
. In modern APIs, this often works via tokens. A typical flow: the user logs in (providing credentials), the server verifies them and returns an access token (often a JWT). The app then includes this token in the Authorization: Bearer <token> header on subsequent requests. The server verifies the token to authenticate each request
. Because the token is digitally signed (as in JWT), the server can trust it hasn’t been tampered with
. The advantage is stateless authentication: the server doesn’t need to keep a session – it just checks the token. JWT (JSON Web Token) is a common token format. It’s a compact string of three Base64 parts (header, payload, signature)
. A JWT contains claims (like user ID, expiration, roles). When you send a JWT in a request, the server can read the payload (it’s just base64) and check the signature to ensure it’s valid. In practice, after login you’d store the JWT and attach it on each call:
dio.options.headers['Authorization'] = 'Bearer $accessToken';
If the JWT includes an expiration (exp claim), then once it expires the server will reject it (usually with 401). To avoid forcing the user to log in too often, many APIs use both access tokens and refresh tokens. The access token is short-lived (e.g. 15 minutes) and is used for most requests
. The refresh token is long-lived but can only be used to obtain a new access token – it usually cannot access data by itself
. Analogy: the access token is like a one-day visitor pass; the refresh token is a longer-term credential that lets you get a new daily pass when needed. When the access token expires, the app automatically calls a “refresh” endpoint with the refresh token to get a fresh access token. In Dio, you’d typically catch a 401 Unauthorized, and in an interceptor trigger the token-refresh logic (see next section). For example:
// Pseudocode interceptor for token refresh
dio.interceptors.add(InterceptorsWrapper(
  onError: (err, handler) async {
    if (err.response?.statusCode == 401) {
      // Access token expired – attempt refresh
      await authService.refreshToken(); // get new tokens
      // Retry the original request with new token
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer ${authService.accessToken}';
      final cloneReq = await dio.fetch(options);
      return handler.resolve(cloneReq);
    }
    return handler.next(err);
  }
));
Other auth methods include API keys (a simple secret key the app sends with each request) or Basic auth (username/password in header), but tokens/JWT are most common for mobile apps. OAuth2 is a broader framework often used for third-party logins (Google, Facebook, etc.) – we won’t detail it here, but know that it results in access/refresh tokens as well. When using Dio, attach tokens like so on login:
Future<void> login(String user, String pass) async {
  final res = await dio.post('/login', data: {'user': user, 'pass': pass});
  authService.accessToken = res.data['access_token'];
  authService.refreshToken = res.data['refresh_token'];
  dio.options.headers['Authorization'] = 'Bearer ${authService.accessToken}';
}
Then on every call, the Authorization header goes out automatically. For security, never store tokens in plain local storage unencrypted. (For example, use the flutter_secure_storage package.) But on the network side, Dio makes it easy to add headers globally
.
Interceptors & Middleware
Dio’s interceptors are one of its most powerful features
. Interceptors let you hook into every request/response/error. This is like middleware on the client side. Typical uses include:
Logging: Easily log all API calls. For example:
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    print("REQUEST[${options.method}] => PATH: ${options.path}");
    return handler.next(options);
  },
  onResponse: (res, handler) {
    print("RESPONSE[${res.statusCode}] <= PATH: ${res.requestOptions.path}");
    return handler.next(res);
  },
  onError: (err, handler) {
    print("ERROR[${err.response?.statusCode}] <= ${err.message}");
    return handler.next(err);
  }
));
This automatically logs every request and response (URL, status, etc.), which is invaluable for debugging. The [Dio documentation and articles] show how interceptors can add auth tokens or log responses
.
Authentication tokens: As shown above, interceptors can attach or refresh tokens on requests. For example, before sending a request you might automatically add the Authorization header if an access token is available. You can use an interceptor’s onRequest to insert options.headers['Authorization'] = 'Bearer $token'; on every call
.
Retry logic: If a network call fails due to timeout or a 500 error, you can automatically retry it. This isn’t built-in, but you can write an interceptor that checks for certain error types and re-executes the request. (Libraries like dio_retry can help implement exponential backoff retries.)
Error normalization: APIs often return error bodies with codes and messages. An error interceptor can transform DioExceptions into your own error classes or extract the message. For instance, if your API always returns {"error": "something went wrong"}, you could parse that here and throw a custom exception.
Token refresh logic: As mentioned, an onError interceptor can catch 401 Unauthorized, pause all outgoing requests, perform a refresh-token API call, update the stored token, and then retry the failed requests
. This is a common pattern: it centralizes error handling so that your UI code never sees the raw 401 (it just sees its original request succeed with a new token, or fail definitively if refresh also fails).
In all these examples, the code lives in one place (the interceptor) instead of scattered around your app. This aligns with how real production apps handle cross-cutting concerns. For example, the Dio vs http guide notes that with http you’d need to manually wrap each call to handle logging or tokens, but Dio lets you do it globally with interceptors
.
Production Concerns
When deploying real apps, several additional considerations arise:
Rate Limiting. APIs often enforce limits on how many requests a client can make per minute/hour. If you exceed the limit, the server may return HTTP 429 Too Many Requests. To handle this, respect any Retry-After header and back off. On the client side, avoid aggressive polling. For example, don’t fetch the same data every second; cache it or use websockets if needed. Rate limiting protects both API stability and fairness
.
Caching. To improve performance and offline capability, you can cache certain API responses. For instance, use Dio’s caching interceptor or manually store data in a local database (e.g. Hive or SQLite). Simple example: after a successful GET, save the JSON to local storage. On app startup or offline mode, serve from cache. Also respect Cache-Control headers from the server if provided.
Offline Handling. Mobile apps should handle no-network scenarios gracefully. Check connectivity (using the connectivity_plus plugin) and show an error or cached data if offline. If a request fails due to no connection, you might queue it and retry when back online.
Retries & Backoff. On transient failures (e.g. a timeout), implement retry logic with exponential backoff to avoid spamming the server. For example: wait 1 second and retry, then 2s, then 4s, up to a limit. This can be done manually or with interceptor libraries.
API Versioning. As APIs evolve, it’s common to version them (e.g. /v1/, /v2/ in the URL). Your Dio base URL might include the version. For example: baseUrl: 'https://api.example.com/v1'. If a breaking change occurs, the server might retire the old version and your app would need updating.
Feature Flags. Sometimes backend teams introduce new features behind flags. Your app could query an endpoint that returns which features to enable. Implementing this often means storing the flags and checking them in code to show/hide functionality.
Overall, production-grade apps focus on resilience: handle errors, allow retries, cache wisely, and fail gracefully. For example, a loading indicator and “retry” button is essential in the UI when a network call fails.
Full Example: Flutter App with Dio
Let’s sketch a simple example app flow to tie it all together. Suppose we’re building a “Task Manager” app.
Login Screen: The user enters email/password. We call:
final res = await dio.post('/login', data: {
  'email': email,
  'password': password
});
final token = res.data['token'];
dio.options.headers['Authorization'] = 'Bearer $token';
If the server returns a JWT, we store it (securely) and attach it for future calls. We then navigate to the main screen.
Main Screen (List of Tasks): On init, the app fetches tasks:
Future<List<Task>> fetchTasks(int page) async {
  Response res = await dio.get('/tasks', queryParameters: {'page': page});
  // Parse JSON to Task models
  return (res.data['items'] as List).map((json) => Task.fromJson(json)).toList();
}
We show a loading indicator while waiting. Once data arrives, we display a scrollable list. If there are more pages (from pagination), we call fetchTasks(page+1) as the user scrolls (infinite scroll). For each task, the Task model was created from JSON in the repository, keeping UI unaware of raw JSON.
CRUD Operations: The user can tap to create, edit, or delete tasks. For example, on “Add Task”:
await dio.post('/tasks', data: {'title': newTitle, 'dueDate': '2025-01-01'});
On success (201), we refresh the list. On “Delete” we do:
await dio.delete('/tasks/$taskId');
Errors (like 400) show an error dialog. Success shows a toast or updates the UI.
Token Refresh: Behind the scenes, suppose the user’s token expires. The next API call returns 401. Our Dio error interceptor kicks in, calls /refresh with the refresh token, updates dio.options.headers, and retries the failed request. The UI might seamlessly continue (or navigate to login if refresh fails).
Error UI: Throughout, we show progress spinners while loading. If a call fails irrecoverably (network error or 400), we display an error message and a “Try again” button. For example:
if (error) {
  return Column(
    children: [
      Text('Failed to load tasks.'),
      ElevatedButton(onPressed: loadTasks, child: Text('Retry')),
    ],
  );
}
Architecture Decisions: In this app, we never put Dio calls in the widget code directly. Instead, the widget calls a TaskRepository.getTasks(page), which uses Dio internally. This keeps widgets clean. We might have:
class TaskRepository {
  final Dio dio;
  TaskRepository({required this.dio});

  Future<List<Task>> getTasks(int page) async {
    final res = await dio.get('/tasks', queryParameters: {'page': page});
    return (res.data['items'] as List).map((t) => Task.fromJson(t)).toList();
  }
}
The widget just awaits this getTasks and updates state.
Folder Structure and DI: Our main.dart sets up GetIt or Provider to provide Dio, TaskRepository, and perhaps AuthService. The UI layer gets the repository injected, not knowing about Dio.
This example app follows everything we’ve covered: HTTP methods for CRUD, status codes for success/error, JSON parsing to models, Dio for networking with interceptors for auth, a clean architecture with repository pattern, loading and error states in the UI, and pagination in the list. By separating concerns and using Dio’s features, we build an app that’s maintainable and ready for production.
