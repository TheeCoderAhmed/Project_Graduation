import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String providerId;
  final String userId;
  final String userName;
  final double overallRating;
  final String comment;
  final Map<String, double> questionnaire;
  final bool isVerified;
  final Timestamp? createdAt;

  ReviewModel({
    required this.reviewId,
    required this.providerId,
    required this.userId,
    required this.userName,
    required this.overallRating,
    required this.comment,
    required this.questionnaire,
    this.isVerified = false,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    // Parse questionnaire safely — Firestore can store numeric values as
    // either int or double. Any malformed entry is clamped to 0.0 rather
    // than throwing a TypeError that crashes the whole list load.
    Map<String, double> questionnaire = {};
    try {
      final raw = map['questionnaire'];
      if (raw is Map) {
        for (final entry in raw.entries) {
          final v = entry.value;
          if (v is num) {
            // Clamp to valid 0–5 range so the star widget never receives
            // out-of-range values from corrupt documents.
            questionnaire[entry.key.toString()] =
                (v.toDouble()).clamp(0.0, 5.0);
          }
          // Non-numeric values are silently dropped rather than crashing.
        }
      }
    } catch (_) {
      // If the entire questionnaire field is malformed, default to empty
      // so the review card renders without the breakdown section.
      questionnaire = {};
    }

    // Parse overallRating safely — default to 0.0 rather than throwing.
    double overallRating = 0.0;
    try {
      final raw = map['overallRating'];
      if (raw is num) {
        overallRating = raw.toDouble().clamp(0.0, 5.0);
      }
    } catch (_) {}

    return ReviewModel(
      reviewId: id,
      providerId: map['providerId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString().trim().isEmpty == true
          ? 'Anonymous'
          : (map['userName']?.toString() ?? 'Anonymous'),
      overallRating: overallRating,
      comment: map['comment']?.toString() ?? '',
      questionnaire: questionnaire,
      isVerified: map['isVerified'] == true,
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt'] as Timestamp
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'userId': userId,
      'userName': userName,
      'overallRating': overallRating,
      'comment': comment,
      'questionnaire': questionnaire,
      'isVerified': isVerified,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
