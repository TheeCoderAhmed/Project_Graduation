import 'package:cloud_firestore/cloud_firestore.dart';
import 'questionnaire_model.dart';

/// A single patient review of an off-app doctor. Stored in the
/// `community_reviews` collection and linked to a [CommunityDoctorModel] via
/// [communityDoctorId]. One review per patient per doctor (deterministic ID).
class CommunityReviewModel {
  final String reviewId;
  final String communityDoctorId;
  final String userId;
  final String userName;
  // Denormalised doctor identity so a review is self-describing.
  final String doctorName;
  final String hospital;
  final String department;
  final String specialty;
  final double overallRating;
  final String comment;
  final QuestionnaireModel questionnaire;
  final Timestamp? createdAt;

  CommunityReviewModel({
    required this.reviewId,
    required this.communityDoctorId,
    required this.userId,
    required this.userName,
    required this.doctorName,
    required this.hospital,
    required this.department,
    required this.specialty,
    required this.overallRating,
    required this.comment,
    required this.questionnaire,
    this.createdAt,
  });

  factory CommunityReviewModel.fromMap(String id, Map<String, dynamic> map) {
    QuestionnaireModel q;
    final raw = map['questionnaire'];
    if (raw is Map) {
      q = QuestionnaireModel.fromMap(Map<String, dynamic>.from(raw));
    } else {
      q = QuestionnaireModel(
          waitingTime: 0, serviceQuality: 0, hygiene: 0, staffCommunication: 0);
    }
    double overall = 0.0;
    if (map['overallRating'] is num) {
      overall = (map['overallRating'] as num).toDouble().clamp(0.0, 5.0);
    }
    return CommunityReviewModel(
      reviewId: id,
      communityDoctorId: map['communityDoctorId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userName: (map['userName']?.toString().trim().isEmpty ?? true)
          ? 'Anonymous'
          : map['userName'].toString(),
      doctorName: map['doctorName']?.toString() ?? '',
      hospital: map['hospital']?.toString() ?? '',
      department: map['department']?.toString() ?? '',
      specialty: map['specialty']?.toString() ?? '',
      overallRating: overall,
      comment: map['comment']?.toString() ?? '',
      questionnaire: q,
      createdAt:
          map['createdAt'] is Timestamp ? map['createdAt'] as Timestamp : Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'communityDoctorId': communityDoctorId,
      'userId': userId,
      'userName': userName,
      'doctorName': doctorName,
      'hospital': hospital,
      'department': department,
      'specialty': specialty,
      'overallRating': overallRating,
      'comment': comment,
      'questionnaire': questionnaire.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
