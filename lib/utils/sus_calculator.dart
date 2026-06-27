// SUS (System Usability Scale) score calculator.
//
// The SUS is a 10-item Likert questionnaire.
// Each item is rated 1–5 (Strongly Disagree → Strongly Agree).
//
// Scoring formula:
//   Odd  items (1,3,5,7,9): contribution = response − 1
//   Even items (2,4,6,8,10): contribution = 5 − response
//   SUS score = sum of all contributions × 2.5  →  range 0–100
//
// Interpretation bands (Bangor et al., 2008):
//   ≥ 80.3  → A  Excellent
//   ≥ 68.0  → B  Good       (industry average is ~68)
//   ≥ 51.0  → C  OK
//   ≥ 25.0  → D  Poor
//   <  25.0 → F  Awful

class SusCalculator {
  SusCalculator._(); // static-only utility

  // ── Public API ────────────────────────────────────────────────────────────

  /// Calculates the SUS score for one participant.
  ///
  /// [responses] — exactly 10 integers, each in the inclusive range [1..5].
  /// Returns a score in [0.0 .. 100.0].
  ///
  /// Throws [ArgumentError] if the list does not contain exactly 10 items
  /// or if any response is outside [1..5].
  static double calculate(List<int> responses) {
    if (responses.length != 10) {
      throw ArgumentError(
          'SUS requires exactly 10 responses; got ${responses.length}.');
    }
    for (int i = 0; i < responses.length; i++) {
      if (responses[i] < 1 || responses[i] > 5) {
        throw ArgumentError(
            'Response at index $i is ${responses[i]}; must be in range [1..5].');
      }
    }

    int sum = 0;
    for (int i = 0; i < 10; i++) {
      final itemNumber = i + 1; // 1-based
      if (itemNumber.isOdd) {
        sum += responses[i] - 1; // odd items: shift down by 1
      } else {
        sum += 5 - responses[i]; // even items: invert the scale
      }
    }
    return sum * 2.5;
  }

  /// Calculates the mean SUS score across all participants.
  ///
  /// [allResponses] — one inner list per participant (each must be 10 items).
  /// Throws [ArgumentError] if [allResponses] is empty.
  static double averageScore(List<List<int>> allResponses) {
    if (allResponses.isEmpty) {
      throw ArgumentError('Cannot average an empty participant list.');
    }
    final scores = allResponses.map(calculate).toList();
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Returns the letter grade and label for a [score].
  ///
  /// Based on Bangor et al. (2008) adjective rating scale.
  static String grade(double score) {
    if (score >= 80.3) return 'A — Excellent';
    if (score >= 68.0) return 'B — Good';
    if (score >= 51.0) return 'C — OK';
    if (score >= 25.0) return 'D — Poor';
    return 'F — Awful';
  }
}
