import 'package:cloud_firestore/cloud_firestore.dart';
import 'questionnaire_model.dart';

class ReviewModel {
  final String reviewId;
  final String providerId;
  final String userId;
  final String userName;
  final double overallRating;
  final String comment;
  final QuestionnaireModel questionnaire;
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
    QuestionnaireModel questionnaire;
    try {
      final raw = map['questionnaire'];
      if (raw is Map<String, dynamic>) {
        questionnaire = QuestionnaireModel.fromMap(raw);
      } else if (raw is Map) {
        questionnaire = QuestionnaireModel.fromMap(Map<String, dynamic>.from(raw));
      } else {
        questionnaire = QuestionnaireModel(
          waitingTime: 0.0, serviceQuality: 0.0, hygiene: 0.0, staffCommunication: 0.0
        );
      }
    } catch (_) {
      questionnaire = QuestionnaireModel(
        waitingTime: 0.0, serviceQuality: 0.0, hygiene: 0.0, staffCommunication: 0.0
      );
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
      'questionnaire': questionnaire.toMap(),
      'isVerified': isVerified,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
