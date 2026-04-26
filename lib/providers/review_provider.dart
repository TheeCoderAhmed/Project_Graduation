import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/ranking_service.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final RankingService _rankingService = RankingService();

  List<ReviewModel> _reviews = [];
  List<ReviewModel> _userReviews = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<ReviewModel> get reviews => _reviews;
  List<ReviewModel> get userReviews => _userReviews;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<void> loadReviews(String providerId) async {
    await Future.microtask(() {});
    _isLoading = true;
    notifyListeners();
    try {
      _reviews = await _firestoreService.getReviews(providerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserReviews(String userId) async {
    await Future.microtask(() {});
    _isLoading = true;
    notifyListeners();
    try {
      _userReviews = await _firestoreService.getUserReviews(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview(ReviewModel review) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _firestoreService.submitReview(review);
      await _rankingService.recalculateRanking(
        providerId: review.providerId,
        newOverallRating: review.overallRating,
        newQuestionnaire: review.questionnaire,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
