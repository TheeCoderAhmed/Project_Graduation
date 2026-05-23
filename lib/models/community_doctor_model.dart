import 'package:cloud_firestore/cloud_firestore.dart';

/// An off-app doctor that exists only because patients reviewed them.
/// Multiple reviews of the same doctor (same name + hospital) aggregate into
/// one of these documents so the community page shows real averages.
///
/// The document ID is a deterministic slug of name + hospital so two patients
/// reviewing the same doctor land on the same record.
class CommunityDoctorModel {
  final String id;
  final String name;
  final String hospital;
  final String department;
  final String specialty;
  final int totalReviews;
  final double ratingSum; // sum of overallRating across all reviews
  // Sums of each questionnaire criterion, for the rating breakdown.
  final double waitSum;
  final double serviceSum;
  final double hygieneSum;
  final double staffSum;
  final Timestamp? updatedAt;

  CommunityDoctorModel({
    required this.id,
    required this.name,
    required this.hospital,
    required this.department,
    required this.specialty,
    this.totalReviews = 0,
    this.ratingSum = 0.0,
    this.waitSum = 0.0,
    this.serviceSum = 0.0,
    this.hygieneSum = 0.0,
    this.staffSum = 0.0,
    this.updatedAt,
  });

  double get averageRating =>
      totalReviews == 0 ? 0.0 : ratingSum / totalReviews;

  /// Builds the deterministic document ID for a doctor identity.
  static String buildId(String name, String hospital) {
    String slug(String s) => s
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final n = slug(name);
    final h = slug(hospital);
    return h.isEmpty ? n : '${n}__$h';
  }

  factory CommunityDoctorModel.fromMap(String id, Map<String, dynamic> map) {
    double d(dynamic v) => (v is num) ? v.toDouble() : 0.0;
    return CommunityDoctorModel(
      id: id,
      name: map['name']?.toString() ?? '',
      hospital: map['hospital']?.toString() ?? '',
      department: map['department']?.toString() ?? '',
      specialty: map['specialty']?.toString() ?? '',
      totalReviews: (map['totalReviews'] is num) ? (map['totalReviews'] as num).toInt() : 0,
      ratingSum: d(map['ratingSum']),
      waitSum: d(map['waitSum']),
      serviceSum: d(map['serviceSum']),
      hygieneSum: d(map['hygieneSum']),
      staffSum: d(map['staffSum']),
      updatedAt: map['updatedAt'] is Timestamp ? map['updatedAt'] as Timestamp : null,
    );
  }
}
