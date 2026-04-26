import 'package:cloud_firestore/cloud_firestore.dart';

/// Recalculates ranking using an incremental formula — reads only the
/// stored provider document, not all reviews. This is O(1) Firestore reads
/// instead of O(n) reads for every new review submission.
///
/// Formula: rankingScore = (newAvgOverall * 0.4) + (newAvgQuestionnaire * 0.6)
///
/// NOTE: In production, move this logic to a Cloud Function triggered on
/// review creation to remove client write access to ranking fields entirely.
class RankingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> recalculateRanking({
    required String providerId,
    required double newOverallRating,
    required Map<String, double> newQuestionnaire,
  }) async {
    final providerDoc =
        await _db.collection('providers').doc(providerId).get();
    if (!providerDoc.exists) return;

    final data = providerDoc.data()!;
    final int prevTotal = (data['totalReviews'] as num?)?.toInt() ?? 0;
    final double prevAvgOverall =
        (data['averageRating'] as num?)?.toDouble() ?? 0.0;
    final double prevAvgQuestionnaire =
        (data['avgQuestionnaireScore'] as num?)?.toDouble() ?? 0.0;

    // Incremental moving average — no need to fetch all reviews
    final int newTotal = prevTotal; // totalReviews was already incremented by submitReview batch
    final double newAvgOverall = newTotal <= 1
        ? newOverallRating
        : ((prevAvgOverall * (newTotal - 1)) + newOverallRating) / newTotal;

    final double newQuestionnaireScore = newQuestionnaire.values.isEmpty
        ? 0.0
        : newQuestionnaire.values.reduce((a, b) => a + b) /
            newQuestionnaire.values.length;

    final double newAvgQuestionnaire = newTotal <= 1
        ? newQuestionnaireScore
        : ((prevAvgQuestionnaire * (newTotal - 1)) + newQuestionnaireScore) /
            newTotal;

    final double rankingScore =
        (newAvgOverall * 0.4) + (newAvgQuestionnaire * 0.6);

    await _db.collection('providers').doc(providerId).update({
      'averageRating': double.parse(newAvgOverall.toStringAsFixed(2)),
      'avgQuestionnaireScore':
          double.parse(newAvgQuestionnaire.toStringAsFixed(2)),
      'rankingScore': double.parse(rankingScore.toStringAsFixed(2)),
    });
  }
}
