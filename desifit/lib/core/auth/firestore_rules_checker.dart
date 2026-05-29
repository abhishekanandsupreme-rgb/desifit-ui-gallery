class FirestoreRulesChecker {
  /// Simulates Firestore Security Rules client-side check for path safety and data schema validation.
  /// Returns null if valid, or a String error message if invalid.
  static String? validateMealWrite({
    required String authUid,
    required String pathUserId,
    required String mealId,
    required String title,
    required String slot,
    required double cost,
    required double protein,
  }) {
    // Rule: request.auth != null
    if (authUid.trim().isEmpty || authUid == 'guest_user') {
      return 'Authentication required. Guests cannot write to Firestore.';
    }

    // Rule: request.auth.uid == userId
    if (authUid != pathUserId) {
      return 'Permission Denied: Authenticated UID does not match target path user segment.';
    }

    // UID structure check to prevent path injection
    final uidRegExp = RegExp(r'^[a-zA-Z0-9_\-]+$');
    if (!uidRegExp.hasMatch(pathUserId)) {
      return 'Invalid path user segment format (potential path injection).';
    }

    if (!uidRegExp.hasMatch(mealId)) {
      return 'Invalid meal document ID format.';
    }

    // Data schema validation
    if (title.trim().isEmpty) {
      return 'Validation Error: Meal title cannot be empty.';
    }

    if (title.length > 100) {
      return 'Validation Error: Meal title cannot exceed 100 characters.';
    }

    final validSlots = {'Breakfast', 'Lunch', 'Dinner', 'Snack'};
    if (!validSlots.contains(slot)) {
      return 'Validation Error: Invalid meal slot "$slot". Must be one of $validSlots.';
    }

    if (cost < 0) {
      return 'Validation Error: Meal cost cannot be negative.';
    }

    if (protein < 0) {
      return 'Validation Error: Protein amount cannot be negative.';
    }

    return null; // Valid
  }

  static String? validateWorkoutWrite({
    required String authUid,
    required String pathUserId,
    required String workoutId,
    required String name,
    required int setsCompleted,
    required int repsCompleted,
    required String difficulty,
  }) {
    // Rule: request.auth != null
    if (authUid.trim().isEmpty || authUid == 'guest_user') {
      return 'Authentication required. Guests cannot write to Firestore.';
    }

    // Rule: request.auth.uid == userId
    if (authUid != pathUserId) {
      return 'Permission Denied: Authenticated UID does not match target path user segment.';
    }

    // UID structure check to prevent path injection
    final uidRegExp = RegExp(r'^[a-zA-Z0-9_\-]+$');
    if (!uidRegExp.hasMatch(pathUserId)) {
      return 'Invalid path user segment format (potential path injection).';
    }

    if (!uidRegExp.hasMatch(workoutId)) {
      return 'Invalid workout document ID format.';
    }

    // Data schema validation
    if (name.trim().isEmpty) {
      return 'Validation Error: Workout name cannot be empty.';
    }

    if (setsCompleted < 0) {
      return 'Validation Error: Sets completed cannot be negative.';
    }

    if (repsCompleted < 0) {
      return 'Validation Error: Reps completed cannot be negative.';
    }

    final validDifficulties = {'Beginner', 'Medium', 'Hard'};
    if (!validDifficulties.contains(difficulty)) {
      return 'Validation Error: Invalid difficulty level. Must be one of $validDifficulties.';
    }

    return null; // Valid
  }
}
