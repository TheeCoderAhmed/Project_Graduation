import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/provider_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── PROVIDERS ──────────────────────────────────────
  Future<List<ProviderModel>> getTopProviders({String? type}) async {
    final query = _db
        .collection('providers')
        .orderBy('rankingScore', descending: true)
        .limit(30);

    final snapshot = await query.get();
    var results = snapshot.docs
        .map((d) => ProviderModel.fromMap(d.id, d.data()))
        .toList();

    if (type != null) {
      results = results.where((p) => p.type == type).toList();
    }
    return results;
  }

  Future<List<ProviderModel>> searchProviders(String query) async {
    final snapshot = await _db
        .collection('providers')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs
        .map((d) => ProviderModel.fromMap(d.id, d.data()))
        .toList();
  }

  Future<ProviderModel?> getProvider(String providerId) async {
    final doc = await _db.collection('providers').doc(providerId).get();
    if (doc.exists) return ProviderModel.fromMap(doc.id, doc.data()!);
    return null;
  }

  // ── REVIEWS ────────────────────────────────────────
  Future<List<ReviewModel>> getReviews(String providerId) async {
    final snapshot = await _db
        .collection('reviews')
        .where('providerId', isEqualTo: providerId)
        .get();
        
    final list = snapshot.docs
        .map((d) => ReviewModel.fromMap(d.id, d.data()))
        .toList();
        
    // Sort descending by createdAt — null timestamps go to the end
    list.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return list;
  }

  /// Returns true if the user has already reviewed this provider.
  Future<bool> hasAlreadyReviewed(String userId, String providerId) async {
    final snapshot = await _db
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .where('providerId', isEqualTo: providerId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> submitReview(ReviewModel review) async {
    // Duplicate guard — prevent multiple reviews for the same provider
    final alreadyReviewed =
        await hasAlreadyReviewed(review.userId, review.providerId);
    if (alreadyReviewed) {
      throw Exception('You have already reviewed this provider.');
    }

    final batch = _db.batch();
    final reviewRef = _db.collection('reviews').doc();
    batch.set(reviewRef, review.toMap());
    final providerRef = _db.collection('providers').doc(review.providerId);
    batch.update(providerRef, {'totalReviews': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<List<ReviewModel>> getUserReviews(String userId) async {
    final snapshot = await _db
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .get();
        
    final list = snapshot.docs
        .map((d) => ReviewModel.fromMap(d.id, d.data()))
        .toList();
        
    // Sort descending by createdAt — null timestamps go to the end
    list.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return list;
  }

  // ── BOOKMARKS ──────────────────────────────────────
  Future<void> toggleBookmark(String userId, String providerId, bool add) async {
    await _db.collection('users').doc(userId).update({
      'bookmarks': add
          ? FieldValue.arrayUnion([providerId])
          : FieldValue.arrayRemove([providerId]),
    });
  }

  Future<List<ProviderModel>> getBookmarkedProviders(List<String> ids) async {
    if (ids.isEmpty) return [];
    final snapshot = await _db
        .collection('providers')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snapshot.docs
        .map((d) => ProviderModel.fromMap(d.id, d.data()))
        .toList();
  }

  // ── PROVIDER DASHBOARD ─────────────────────────────
  /// Fetch provider listings owned by a given user UID
  Future<List<ProviderModel>> getProvidersByOwner(String ownerId) async {
    final snapshot = await _db
        .collection('providers')
        .where('ownerId', isEqualTo: ownerId)
        .get();
    return snapshot.docs
        .map((d) => ProviderModel.fromMap(d.id, d.data()))
        .toList();
  }
}
