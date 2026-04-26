import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
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
    try {
      _topDoctors = await _service.getTopProviders(type: 'doctor');
      _topPharmacies = await _service.getTopProviders(type: 'pharmacy');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final q = query.toLowerCase();
      final allProviders = [..._topDoctors, ..._topPharmacies];
      
      final uniqueIds = <String>{};
      final List<ProviderModel> results = [];
      
      for (var p in allProviders) {
        if (uniqueIds.contains(p.providerId)) continue;
        
        final matchName = p.name.toLowerCase().contains(q);
        final matchSpec = p.specialty.toLowerCase().contains(q);
        final matchAddr = p.address.toLowerCase().contains(q);
        
        if (matchName || matchSpec || matchAddr) {
          uniqueIds.add(p.providerId);
          results.add(p);
        }
      }
      
      _searchResults = results;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBookmarks(List<String> ids) async {
    _bookmarked = await _service.getBookmarkedProviders(ids);
    notifyListeners();
  }

  Future<void> toggleBookmark(String userId, String providerId, bool add) async {
    await _service.toggleBookmark(userId, providerId, add);
  }
}
