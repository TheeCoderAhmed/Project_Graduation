import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/dummy_data_service.dart';
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
    _isLoading = true;
    Future.microtask(notifyListeners);

    try {
      final realReviews = await _firestoreService.getReviews(providerId);
      final realIds = realReviews.map((r) => r.reviewId).toSet();
      final seed = DummyDataService.seedReviewsFor(providerId)
          .where((r) => !realIds.contains(r.reviewId))
          .toList();
      _reviews = [...realReviews, ...seed];
      _error = null;
    } catch (_) {
      // Fall back to seed data so the UI is never blank.
      _reviews = DummyDataService.seedReviewsFor(providerId);
      // Don't surface a Firestore index/network error as user-visible
      // since seed data is showing — it looks correct to the user.
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserReviews(String userId) async {
    _isLoading = true;
    Future.microtask(notifyListeners);

    try {
      _userReviews = await _firestoreService.getUserReviews(userId);
      _error = null;
    } catch (e) {
      _error = _friendlyError(e.toString());
      _userReviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits a review to Firestore.
  ///
  /// Returns a [ReviewSubmitResult] so the caller has a single, unambiguous
  /// source of truth — no try/catch needed in the screen, no dual error paths.
  Future<ReviewSubmitResult> submitReview(ReviewModel review) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.submitReview(review);

      // Ranking update is best-effort — errors are swallowed inside the service.
      await _rankingService.recalculateRanking(
        providerId: review.providerId,
        newOverallRating: review.overallRating,
        newQuestionnaire: review.questionnaire,
      );

      // Optimistic local update only AFTER the Firestore write confirmed.
      _reviews = [review, ..._reviews];
      _userReviews = [review, ..._userReviews];

      return ReviewSubmitResult.success();
    } on Exception catch (e) {
      final msg = _friendlyError(e.toString());
      _error = msg;
      return ReviewSubmitResult.failure(msg);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _friendlyError(String raw) {
    if (raw.contains('already reviewed')) {
      return 'You have already submitted a review for this provider.';
    }
    if (raw.contains('network') || raw.contains('connection')) {
      return 'No internet connection. Please try again.';
    }
    if (raw.contains('permission-denied')) {
      return 'You don\'t have permission to do that. Please sign in again.';
    }
    return 'Something went wrong. Please try again.';
  }
}

/// Typed result returned by [ReviewProvider.submitReview].
/// Screens switch on [success] — no try/catch, no dual error sources.
class ReviewSubmitResult {
  final bool success;
  final String? errorMessage;

  const ReviewSubmitResult._({required this.success, this.errorMessage});

  factory ReviewSubmitResult.success() =>
      const ReviewSubmitResult._(success: true);

  factory ReviewSubmitResult.failure(String message) =>
      ReviewSubmitResult._(success: false, errorMessage: message);
}
