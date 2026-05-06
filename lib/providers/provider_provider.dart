import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/provider_model.dart';
import '../models/review_model.dart';

class ProviderProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<ProviderModel> _allProviders = [];
  List<ProviderModel> _topDoctors = [];
  List<ProviderModel> _topPharmacies = [];
  List<ProviderModel> _searchResults = [];
  List<ProviderModel> _bookmarked = [];
  bool _isLoading = false;
  String? _error;

  List<ProviderModel> get topDoctors => _topDoctors;
  List<ProviderModel> get topPharmacies => _topPharmacies;
  List<ProviderModel> get searchResults => _searchResults;
  List<ProviderModel> get bookmarked => _bookmarked;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHomeData({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final rawProviders = await _service.getAllProviders();

      // Fetch all real reviews and compute actual counts/averages.
      List<ReviewModel> allReviews = [];
      try {
        allReviews = await _service.getAllReviews();
      } catch (_) {
        // If reviews fetch fails, we'll use zero counts rather than fake data.
      }

      _allProviders = _applyRealStats(rawProviders, allReviews);

      _topDoctors = _allProviders.where((p) => p.type == 'doctor').toList()
        ..sort((a, b) {
          final ratingCmp = b.averageRating.compareTo(a.averageRating);
          if (ratingCmp != 0) return ratingCmp;
          return b.totalReviews.compareTo(a.totalReviews);
        });
      if (_topDoctors.length > 30) _topDoctors = _topDoctors.sublist(0, 30);

      _topPharmacies = _allProviders.where((p) => p.type == 'pharmacy').toList()
        ..sort((a, b) {
          final ratingCmp = b.averageRating.compareTo(a.averageRating);
          if (ratingCmp != 0) return ratingCmp;
          return b.totalReviews.compareTo(a.totalReviews);
        });
      if (_topPharmacies.length > 30) _topPharmacies = _topPharmacies.sublist(0, 30);

      _searchResults = List.from(_allProviders);
      _error = null;
    } catch (e) {
      _error = 'Failed to load providers';
    }
    if (showLoading) {
      _isLoading = false;
    }
    notifyListeners();
  }

  /// Replaces the static `totalReviews` and `averageRating` fields on each
  /// provider with values computed from the actual reviews collection.
  List<ProviderModel> _applyRealStats(
      List<ProviderModel> providers, List<ReviewModel> reviews) {
    // Group reviews by providerId.
    final Map<String, List<ReviewModel>> grouped = {};
    for (final r in reviews) {
      grouped.putIfAbsent(r.providerId, () => []).add(r);
    }

    return providers.map((p) {
      final providerReviews = grouped[p.providerId] ?? [];
      final count = providerReviews.length;
      final avg = count > 0
          ? providerReviews.fold<double>(0, (sum, r) => sum + r.overallRating) / count
          : 0.0;
      return p.copyWith(
        totalReviews: count,
        averageRating: double.parse(avg.toStringAsFixed(1)),
      );
    }).toList();
  }

  Future<void> search(String query) async {
    if (_allProviders.isEmpty) {
      await loadHomeData(showLoading: true);
    }

    if (query.trim().isEmpty) {
      _searchResults = List.from(_allProviders);
      notifyListeners();
      return;
    }
    final q = query.trim().toLowerCase();
    final words = q.split(' ').where((w) => w.isNotEmpty).toList();
    _searchResults = _allProviders.where((p) {
      final textToSearch = '${p.name} ${p.specialty} ${p.address} ${p.type}'.toLowerCase();
      return words.every((w) => textToSearch.contains(w));
    }).toList();
    notifyListeners();
  }

  Future<void> loadBookmarks(List<String> ids) async {
    if (ids.isEmpty) {
      _bookmarked = [];
      notifyListeners();
      return;
    }
    _bookmarked = _allProviders
        .where((p) => ids.contains(p.providerId))
        .toList();
    notifyListeners();
  }

  /// Persists bookmark to Firestore. Returns true on success.
  /// On failure, returns false so the caller (screen/AuthProvider) can
  /// roll back the optimistic local toggle.
  Future<bool> toggleBookmark(
      String userId, String providerId, bool add) async {
    try {
      await _service.toggleBookmark(userId, providerId, add);
      _error = null;
      return true;
    } catch (e) {
      _error = 'Could not save bookmark. Check your connection.';
      notifyListeners();
      return false;
    }
  }

  ProviderModel? getById(String providerId) {
    try {
      return _allProviders
          .firstWhere((p) => p.providerId == providerId);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
