import 'package:cloud_firestore/cloud_firestore.dart';

/// Recalculates ranking using an incremental moving-average formula.
/// Reads only the provider document — O(1) Firestore reads per review.
///
/// Formula: rankingScore = (avgOverall × 0.4) + (avgQuestionnaire × 0.6)
///
/// Errors here are NON-FATAL: a ranking update failure must never surface
/// as a review-submission error to the user. The review is already saved.
/// We silently swallow failures and let the next review correct the average.
class RankingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> recalculateRanking({
    required String providerId,
    required double newOverallRating,
    required Map<String, double> newQuestionnaire,
  }) async {
    try {
      final providerDoc =
          await _db.collection('providers').doc(providerId).get();

      // Provider doc may not exist in Firestore (seed-only providers).
      // Use set(merge:true) to create it if needed instead of update().
      final data = providerDoc.exists ? (providerDoc.data() ?? {}) : {};

      final int prevTotal = (data['totalReviews'] as num?)?.toInt() ?? 0;
      final double prevAvgOverall =
          (data['averageRating'] as num?)?.toDouble() ?? 0.0;
      final double prevAvgQ =
          (data['avgQuestionnaireScore'] as num?)?.toDouble() ?? 0.0;

      // totalReviews was already incremented by submitReview's batch.
      final int newTotal = prevTotal;
      final double newAvgOverall = newTotal <= 1
          ? newOverallRating
          : ((prevAvgOverall * (newTotal - 1)) + newOverallRating) / newTotal;

      final double newQScore = newQuestionnaire.values.isEmpty
          ? 0.0
          : newQuestionnaire.values.reduce((a, b) => a + b) /
              newQuestionnaire.values.length;

      final double newAvgQ = newTotal <= 1
          ? newQScore
          : ((prevAvgQ * (newTotal - 1)) + newQScore) / newTotal;

      final double rankingScore =
          (newAvgOverall * 0.4) + (newAvgQ * 0.6);

      await _db.collection('providers').doc(providerId).set(
        {
          'averageRating':
              double.parse(newAvgOverall.toStringAsFixed(2)),
          'avgQuestionnaireScore':
              double.parse(newAvgQ.toStringAsFixed(2)),
          'rankingScore':
              double.parse(rankingScore.toStringAsFixed(2)),
        },
        SetOptions(merge: true), // safe whether doc exists or not
      );
    } catch (_) {
      // Intentionally silent — ranking update is best-effort.
      // The review is already committed; a stale ranking score is
      // acceptable until the next review corrects it.
    }
  }
}
