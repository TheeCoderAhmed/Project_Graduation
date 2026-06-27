import 'package:flutter/material.dart';
import '../models/community_doctor_model.dart';
import '../models/community_review_model.dart';
import '../models/questionnaire_model.dart';
import '../services/firestore_service.dart';

/// State for the community (off-app doctor) review feature: the browsable list
/// of doctors, the search/filter query, and submission of new reviews.
class CommunityProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<CommunityDoctorModel> _doctors = [];
  List<CommunityReviewModel> _reviews = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String _query = '';
  String? _error;

  List<CommunityReviewModel> get doctorReviews => _reviews;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String get query => _query;

  /// Doctors filtered by the current search query (matches name, hospital,
  /// or department — case-insensitive).
  List<CommunityDoctorModel> get filteredDoctors {
    if (_query.trim().isEmpty) return _doctors;
    final q = _query.trim().toLowerCase();
    return _doctors.where((d) {
      return d.name.toLowerCase().contains(q) ||
          d.hospital.toLowerCase().contains(q) ||
          d.department.toLowerCase().contains(q);
    }).toList();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> loadDoctors() async {
    _isLoading = true;
    Future.microtask(notifyListeners);
    try {
      _doctors = await _firestore.getCommunityDoctors();
      _error = null;
    } catch (e) {
      _error = 'Could not load doctors. Please try again.';
      _doctors = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReviews(String communityDoctorId) async {
    _isLoading = true;
    Future.microtask(notifyListeners);
    try {
      _reviews = await _firestore.getCommunityReviews(communityDoctorId);
      _error = null;
    } catch (e) {
      _error = 'Could not load reviews. Please try again.';
      _reviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits a review of an off-app doctor. Returns null on success or a
  /// friendly error message on failure.
  Future<String?> submitReview({
    required String userId,
    required String userName,
    required String doctorName,
    required String hospital,
    required String department,
    required String specialty,
    required double overallRating,
    required String comment,
    required QuestionnaireModel questionnaire,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final id = CommunityDoctorModel.buildId(doctorName, hospital);
      final review = CommunityReviewModel(
        reviewId: '',
        communityDoctorId: id,
        userId: userId,
        userName: userName,
        doctorName: doctorName,
        hospital: hospital,
        department: department,
        specialty: specialty,
        overallRating: overallRating,
        comment: comment,
        questionnaire: questionnaire,
      );
      await _firestore.submitCommunityReview(review);
      await loadDoctors();
      return null;
    } catch (e) {
      final raw = e.toString();
      if (raw.contains('already reviewed')) {
        return 'You have already reviewed this doctor.';
      }
      if (raw.contains('permission-denied')) {
        return 'You don\'t have permission to do that. Please sign in again.';
      }
      return 'Something went wrong. Please try again.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
