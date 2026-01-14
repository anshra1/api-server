# Button System Documentation

**Status:** Draft  
**Target Audience:** Engineering & Design Interns  
**Related Components:** `AppPrimaryButton`, `AppSecondaryButton`, `AppOutlineButton`, `AppGhostButton`, `AppDestructiveButton`

---

## 1. Introduction

Our button system is built on top of Flutter's Material 3 implementation but strictly scoped to ensure consistency across the application. We use a set of specific "Atom" widgets rather than raw Flutter buttons (`ElevatedButton`, `TextButton`) to maintain a unified design language.

> [!TIP]
> **Live Example:** You can see all these buttons in action by running the example file:  
> `examples/app_buttons_example.dart`

### Core Philosophy
*   **Semantics over Style:** Use the button class that matches the *intent* of the action (e.g., `AppDestructiveButton` for delete), do not style a generic button to look like one.
*   **Restricted Customization:** We expose specific properties (`size`, `state`) and hide others (arbitrary padding, colors) to prevent "snowflake" designs.
*   **Accessibility:** All buttons handle their own disabled and loading states automatically.

---

## 2. Button Catalog & Hierarchy

Always choose the button based on the emphasis required for the action.

### 🟢 Level 1: Primary Action
**Widget:** `AppPrimaryButton`  
**Usage:** The single most important action on a screen.
*   **Rule:** **Limit to one per view** (e.g., "Save", "Submit", "Sign Up").
*   **Don't:** Use multiple primary buttons side-by-side.

### 🔵 Level 2: Secondary Action
**Widget:** `AppSecondaryButton`  
**Usage:** Important actions that are not the main goal.
*   **Usage:** "Save Draft", "Back", or alternative options.
*   **Visual:** Muted background, contrasting text.

### ⚪ Level 3: Medium Emphasis
**Widget:** `AppOutlineButton`  
**Usage:** Actions that need to be visible but not compete with the primary call-to-action.
*   **Usage:** Filters, specific secondary options.

### 📄 Level 4: Lowest Emphasis
**Widget:** `AppGhostButton`  
**Usage:** Low priority actions often used in dialogs or cards.
*   **Usage:** "Cancel", "Learn More", inline actions.
*   **Visual:** No background, no border.

### 🔴 Destructive Actions
**Widget:** `AppDestructiveButton`  
**Usage:** Actions that remove data or are irreversible.
*   **Usage:** "Delete Account", "Remove Item".
*   **Note:** Often requires a confirmation step before execution.
*   **Variant:** Can be outlined (`outlined: true`) for less visual weight.

---

## 3. Decision Tree: Which Button?

1.  **Is this the main thing the user should do on this page?**
    *   ✅ Yes: `AppPrimaryButton`
    *   ❌ No: Go to 2.

2.  **Is this a dangerous action (delete, ban)?**
    *   ✅ Yes: `AppDestructiveButton`
    *   ❌ No: Go to 3.

3.  **Does it need a solid background to stand out?**
    *   ✅ Yes: `AppSecondaryButton`
    *   ❌ No: Go to 4.

4.  **Should it have a border?**
    *   ✅ Yes: `AppOutlineButton`
    *   ❌ No: `AppGhostButton`

---

## 4. Anatomy & Properties

All buttons share a common interface. You do **not** use `AppBaseButton` directly; it is for internal system use only.

### Sizes (`AppButtonSize`)
| Size | Enum Value | Use Case |
| :--- | :--- | :--- |
| **Small** | `KitButtonSize.small` | Tables, dense lists, inside cards. |
| **Medium** | `KitButtonSize.medium` | **Default.** Forms, dialogs, standard pages. |
| **Large** | `KitButtonSize.large` | Landing pages, sticky bottom bars on mobile. |

### States (`AppButtonState`)
Buttons manage their own interaction state.
*   `enabled`: Standard clickable state.
*   `disabled`: Grayed out, `onPressed` is ignored.
*   `loading`: Shows a spinner, `onPressed` is ignored.

### Icons
*   `leading`: Icon before the text. Use for verbs (e.g., `Icons.add` + "Create").
*   `trailing`: Icon after the text. Use for navigation (e.g., "Next" + `Icons.arrow_forward`).

---

## 5. Developer Guide (How to Use)

### Standard Example
```dart
AppPrimaryButton(
  onPressed: () {
    // Handle tap
  },
  child: const Text('Submit Order'),
)
```

### Handling Loading States
Do not manually swap the child for a spinner. Use the `state` property.

```dart
AppPrimaryButton(
  // If isLoading is true, the button automatically shows a spinner
  // and disables clicks.
  state: isLoading ? AppButtonState.loading : AppButtonState.enabled, 
  onPressed: () => submitForm(),
  child: const Text('Login'),
)
```

### With Icons
```dart
AppSecondaryButton(
  onPressed: () => nav.goBack(),
  leading: const Icon(Icons.arrow_back),
  child: const Text('Back'),
)
```

### Dos and Don'ts

| ✅ Do | ❌ Don't |
| :--- | :--- |
| Use Sentence case ("Create account") | Use Title Case ("Create Account") or ALL CAPS |
| Use `AppGhostButton` for "Cancel" | Use `AppPrimaryButton` (Grey) for "Cancel" |
| Wrap buttons in `Expanded` or `SizedBox` for width | Try to force width via padding hack |

---

## 6. Icon & Link Buttons

### Icon Button
Use `AppIconButton` for icon-only actions (like in AppBars).
```dart
AppIconButton(
  icon: const Icon(Icons.notifications),
  onPressed: () {},
  tooltip: 'Notifications', // Always provide a tooltip!
)
```

### Link Button
Use `AppLinkButton` for inline links or "text-only" feel that looks like a hyperlink.
```dart
AppLinkButton(
  text: "Forgot Password?",
  onPressed: () => resetPassword(),
)
```
