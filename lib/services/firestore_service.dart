import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/provider_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── PROVIDERS ──────────────────────────────────────
  Future<List<ProviderModel>> getTopProviders({String? type}) async {
    Query<Map<String, dynamic>> query = _db.collection('providers');
    
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    
    query = query.orderBy('rankingScore', descending: true).limit(30);

    final snapshot = await query.get();
    return snapshot.docs
        .map((d) => ProviderModel.fromMap(d.id, d.data()))
        .toList();
  }

  Future<List<ProviderModel>> getAllProviders() async {
    final snapshot = await _db.collection('providers').get();
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

    list.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return list;
  }

  Future<bool> hasAlreadyReviewed(String userId, String providerId) async {
    final doc = await _db
        .collection('reviews')
        .doc(_reviewId(userId, providerId))
        .get();
    return doc.exists;
  }

  Future<void> submitReview(ReviewModel review) async {
    final reviewRef = _db
        .collection('reviews')
        .doc(_reviewId(review.userId, review.providerId));

    await _db.runTransaction((transaction) async {
      final existingReview = await transaction.get(reviewRef);
      if (existingReview.exists) {
        throw Exception('You have already reviewed this provider.');
      }

      transaction.set(reviewRef, review.toMap());
    });
  }

  Future<List<ReviewModel>> getUserReviews(String userId) async {
    final snapshot = await _db
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .get();

    final list = snapshot.docs
        .map((d) => ReviewModel.fromMap(d.id, d.data()))
        .toList();

    list.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return list;
  }

  // ── BOOKMARKS ──────────────────────────────────────
  /// Uses set(merge:true) so it works even if the user document doesn't
  /// yet exist in Firestore (e.g. after a failed sign-up Firestore write).
  Future<void> toggleBookmark(
      String userId, String providerId, bool add) async {
    await _db.collection('users').doc(userId).set(
      {
        'bookmarks': add
            ? FieldValue.arrayUnion([providerId])
            : FieldValue.arrayRemove([providerId]),
      },
      SetOptions(merge: true),
    );
  }

  Future<List<ProviderModel>> getBookmarkedProviders(
      List<String> ids) async {
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
  Future<List<ProviderModel>> getProvidersByOwner(String ownerId) async {
    final snapshot = await _db
        .collection('providers')
        .where('ownerId', isEqualTo: ownerId)
        .get();
    return snapshot.docs
        .map((d) => ProviderModel.fromMap(d.id, d.data()))
        .toList();
  }

  // ── ALL REVIEWS (for real-time stats aggregation) ──
  Future<List<ReviewModel>> getAllReviews() async {
    final snapshot = await _db.collection('reviews').get();
    return snapshot.docs
        .map((d) => ReviewModel.fromMap(d.id, d.data()))
        .toList();
  }

  String _reviewId(String userId, String providerId) => '${userId}_$providerId';
}
