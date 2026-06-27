// A/B Test: Stats Bar Visibility Experiment
//
// Hypothesis: Showing aggregate platform stats (doctor count, pharmacy count,
// total reviews) on the home screen builds social proof and increases
// tap-through rates on provider cards.
//
// Control   (A): HomeStatsBar visible  — current behaviour
// Treatment (B): HomeStatsBar hidden   — cleaner layout
//
// Assignment is DETERMINISTIC: same userId always maps to the same variant.
// This avoids the "flickering" UX where a user sees different layouts on
// different sessions, and makes the assignment testable without mocking.

/// The two arms of the stats-bar experiment.
enum AbVariant {
  /// Control arm — stats bar is shown (baseline behaviour).
  control,

  /// Treatment arm — stats bar is hidden (lean layout).
  treatment,
}

class AbTestService {
  AbTestService._(); // static-only class — no instances needed

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns the variant assigned to [userId].
  ///
  /// Assignment algorithm:
  ///   userId.hashCode % 2 == 0  →  control
  ///   userId.hashCode % 2 != 0  →  treatment
  ///
  /// Properties:
  ///   - Deterministic: same input always produces same output.
  ///   - ~50/50 split over any large population of user IDs.
  ///   - Pure Dart: no Firebase, no I/O, no state.
  static AbVariant assignVariant(String userId) {
    return userId.hashCode.isEven ? AbVariant.control : AbVariant.treatment;
  }

  /// Convenience: returns true when [userId] is in the control arm.
  static bool isControl(String userId) =>
      assignVariant(userId) == AbVariant.control;

  /// Convenience: returns true when [userId] is in the treatment arm.
  static bool isTreatment(String userId) =>
      assignVariant(userId) == AbVariant.treatment;
}
