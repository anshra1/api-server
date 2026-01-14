# Package Guide for Interns

Welcome to the **Solearium** project! This document outlines the key libraries and tools we use, explaining *what* they are and *why* we chose them. Understanding this stack will help you navigate the codebase and contribute effectively.

## 🏗️ Architecture & State Management

### **Bloc (`bloc`, `flutter_bloc`)**
*   **What:** The core State Management library we use. It separates business logic from the UI using the **B**usiness **Lo**gic **C**omponent pattern.
*   **Why:** It makes our state predictable, easy to test, and cleanly separated from the UI widgets.
*   **Intern Tip:** You'll see `BlocProvider` and `BlocBuilder` everywhere. Logic goes in `Events` (inputs) and `States` (outputs).

### **Dependency Injection (`get_it`, `flutter_getit`)**
*   **What:** A Service Locator. It allows us to access core services (like API clients or Database instances) anywhere in the app without passing them down the widget tree manually.
*   **Why:** It simplifies code, improves testing (we can swap real services for mocks), and manages singletons efficiently.

## 🌐 Networking & Data

### **Dio (`dio`, `dio_smart_retry`)**
*   **What:** A powerful HTTP client for Dart. `dio_smart_retry` automatically retries failed network requests.
*   **Why:** `http` (the default package) is too basic. Dio gives us interceptors (global error handling/logging), request cancellation, and simpler file uploads.

### **Retrofit (`retrofit`, `retrofit_generator`)**
*   **What:** A type-safe REST client generator that works on top of **Dio**.
*   **Why:** Instead of writing manual HTTP calls like `dio.get('/users')`, we define an interface `getUsers()` and Retrofit generates the API code for us. It reduces boilerplate and typos.

### **Connectivity Plus (`connectivity_plus`)**
*   **What:** Checks if the device has an internet connection (WiFi/Mobile Data).
*   **Why:** To show offline UI states or pause background syncs when the user loses internet.

## 💾 Local Storage & Database

### **ObjectBox (`objectbox`, `objectbox_flutter_libs`)**
*   **What:** A super-fast NoSQL database for local storage.
*   **Why:** It performs significantly better than SQLite for Flutter apps and handles large datasets smoothly. We use it to cache data so the app works offline.

### **Flutter Secure Storage (`flutter_secure_storage`)**
*   **What:** Key-value storage that is encrypted (Keychain on iOS, Keystore on Android).
*   **Why:** **Never** store sensitive data like User Auth Tokens or Passwords in plain text (SharedPreferences/ObjectBox). Always use this package.

## 🛠️ Utilities & Functional Programming

### **fpdart (`fpdart`)**
*   **What:** Functional programming library (inspired by TypeScript's `fp-ts`).
*   **Why:** We use it mainly for `Either<L, R>` types to handle errors. Instead of throwing exceptions (which can be missed), functions return `Right(success)` or `Left(failure)`, forcing us to handle errors explicitly.

### **Equatable (`equatable`)**
*   **What:** Helper for value equality.
*   **Why:** By default, Dart compares objects by reference (memory location). `Equatable` allows us to compare objects by their *data*. Essential for Bloc states to trigger UI updates only when data actually changes.

### **UUID (`uuid`)**
*   **What:** Generates unique IDs.
*   **Why:** Useful for creating temporary IDs for new items before they are synced to the backend.

### **Intl (`intl`)**
*   **What:** Internationalization and Localization.
*   **Why:** Handles date formatting (e.g., "Jan 12, 2026") and number formatting properly for different user regions.

## 🔍 Logging & Monitoring

### **Talker (`talker`, `talker_flutter`, etc.)**
*   **What:** An advanced logging system.
*   **Why:** It gives us a pretty UI console *inside* the app to view logs, network requests, and Bloc transitions in real-time. Much better than staring at the messy terminal output.

### **Firebase (`firebase_core`, `firebase_crashlytics`)**
*   **What:** Google's backend platform. We specifically use **Crashlytics**.
*   **Why:** If the app crashes on a user's phone, this reports the exact line of code that failed so we can fix it.

## 🚀 Navigation

### **GoRouter (`go_router`)**
*   **What:** A declarative routing package.
*   **Why:** Handles complex navigation scenarios like deep linking (opening the app from a web URL), redirects (kicking unauthenticated users to login), and nested navigation bars better than default Flutter routing.

## 🛠️ Build & Environment Management

### **Flutter Flavorizr (`flutter_flavorizr`)**
*   **What:** CLI tool to automate build flavors (Dev, Staging, Prod).
*   **Why:** It generates all the complex Android (Gradle) and iOS (Schemes/Xcconfig) setup for us. It also handles creating different App Icons and App Names for each environment (e.g., "Solearium Dev" vs "Solearium").

## ⚙️ Code Generation (The "Magic" Part)

*   **Freezed (`freezed_annotation`, `freezed`)**: Generates immutable data classes and "unions". It prevents bugs by ensuring you can't accidentally modify data and forcing you to handle all cases in switch statements.
*   **JSON Serializable (`json_annotation`, `json_serializable`)**: Automatically converts our Dart objects to JSON (for sending to APIs) and back.
*   **Flutter Gen (`flutter_gen`)**: Generates a strictly typed class for Assets. Instead of typing string paths like `'assets/logo.png'` (which can typo), you use `Assets.logo.image()`.

## 🧪 Testing & Quality Control (Dev Dependencies)

*   **Mocktail (`mocktail`)**: Lets us create "fake" versions of our classes to test logic in isolation.
*   **Faker (`faker`)**: Generates fake data (names, emails) for testing UI without a real backend.
*   **Bloc Test (`bloc_test`)**: Specialized library for testing Blocs easily.
*   **Very Good Analysis (`very_good_analysis`)**: Strict linting rules. If you see a blue/yellow squiggly line in your code, this package is telling you to follow our coding standards!