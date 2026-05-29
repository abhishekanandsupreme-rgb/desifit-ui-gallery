# Firestore Security Rules Specification

This document defines the Cloud Firestore security rules for the DesiFit application. These rules enforce authentication, verify data ownership, prevent path traversal/injection attacks, and validate the schemas of incoming writes.

> [!IMPORTANT]
> To prevent unauthorized writes and protect user privacy, Firestore rules must require that the authenticated user's UID matches the wildcard segment of the collection path (`request.auth.uid == userId`). Guest/unauthenticated users must be blocked from writing to or reading from Firestore.

---

## 1. Firebase Security Rules (`firestore.rules`)

Deploy the following rules configuration to your GCP/Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function isValidUidFormat(uid) {
      // Prevents path traversal and injection via UID verification
      return uid.matches('^[a-zA-Z0-9_\\-]+$');
    }

    // Rules for user documents
    match /users/{userId} {
      allow read, write: if isOwner(userId) && isValidUidFormat(userId);

      // Rules for user meal logs
      match /meals/{mealId} {
        allow read, write: if isOwner(userId) 
          && isValidUidFormat(userId)
          && isValidUidFormat(mealId)
          && isValidMealSchema(request.resource.data);
      }

      // Rules for user workout logs
      match /workouts/{workoutId} {
        allow read, write: if isOwner(userId) 
          && isValidUidFormat(userId)
          && isValidUidFormat(workoutId)
          && isValidWorkoutSchema(request.resource.data);
      }
    }

    // Schema Validation Helpers
    function isValidMealSchema(meal) {
      return meal.title is string 
        && meal.title.trim().size() > 0 
        && meal.title.size() <= 100
        && meal.slot is string 
        && meal.slot in ['Breakfast', 'Lunch', 'Dinner', 'Snack']
        && (meal.cost is int || meal.cost is float)
        && meal.cost >= 0
        && (meal.protein is int || meal.protein is float)
        && meal.protein >= 0
        && meal.timestamp is string;
    }

    function isValidWorkoutSchema(workout) {
      return workout.name is string 
        && workout.name.trim().size() > 0
        && workout.setsCompleted is int 
        && workout.setsCompleted >= 0
        && workout.repsCompleted is int 
        && workout.repsCompleted >= 0
        && workout.difficulty is string
        && workout.difficulty in ['Beginner', 'Medium', 'Hard']
        && workout.timestamp is string;
    }
  }
}
```

---

## 2. Security Design Principles

### Path Traversal & Injection Prevention
By requiring `isValidUidFormat(userId)` (alphanumeric, underscores, and hyphens), we ensure that the wildcard identifiers do not contain `.` or `/` sequences. This locks users into their partitioned subcollections under `/users/{userId}` and prevents them from accessing sibling document spaces.

### Authentication Enforcement
The database operates under a default-deny posture. Any reads or writes that do not match the specific `/users/{userId}` patterns are rejected. Guest sessions (`guest_user`) are prevented from triggering Firestore reads/writes on the client side, keeping database transaction costs minimal and eliminating error log noise.

### Client-Side Pre-Validation
To reduce database load and provide instantaneous feedback, DesiFit replicates these rules in the client codebase using the `FirestoreRulesChecker` utility:
* **Meal Check**: [lib/core/auth/firestore_rules_checker.dart](file:///c:/Users/asus/Downloads/stitch_desifit_ui_design/desifit/lib/core/auth/firestore_rules_checker.dart#L3-L49)
* **Workout Check**: [lib/core/auth/firestore_rules_checker.dart](file:///c:/Users/asus/Downloads/stitch_desifit_ui_design/desifit/lib/core/auth/firestore_rules_checker.dart#L51-L89)

---

## 3. Schema Constraints Reference

| Collection | Field | Type | Rules / Constraints |
| --- | --- | --- | --- |
| **meals** | `title` | String | Must not be empty, max 100 characters. |
| | `slot` | String | One of: `Breakfast`, `Lunch`, `Dinner`, `Snack` |
| | `cost` | Number | Must be `>= 0.0` (Rupees) |
| | `protein` | Number | Must be `>= 0.0` (Grams) |
| | `timestamp` | String | ISO 8601 formatted date-time string |
| **workouts** | `name` | String | Must not be empty |
| | `setsCompleted` | Integer | Must be `>= 0` |
| | `repsCompleted` | Integer | Must be `>= 0` |
| | `difficulty` | String | One of: `Beginner`, `Medium`, `Hard` |
| | `timestamp` | String | ISO 8601 formatted date-time string |
