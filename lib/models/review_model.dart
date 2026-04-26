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
    return ReviewModel(
      reviewId: id,
      providerId: map['providerId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      overallRating: (map['overallRating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      questionnaire: Map<String, double>.from(
        (map['questionnaire'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      ),
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
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
