import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/dummy_data_service.dart';
import '../models/provider_model.dart';

class ProviderProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

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

  Future<void> loadHomeData() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _topDoctors = DummyDataService.doctors;
    _topPharmacies = DummyDataService.pharmacies;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));
    final q = query.toLowerCase();
    _searchResults = DummyDataService.allProviders.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.specialty.toLowerCase().contains(q) ||
          p.address.toLowerCase().contains(q) ||
          p.type.toLowerCase().contains(q);
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadBookmarks(List<String> ids) async {
    if (ids.isEmpty) {
      _bookmarked = [];
      notifyListeners();
      return;
    }
    _bookmarked = DummyDataService.allProviders
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
      return DummyDataService.allProviders
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
