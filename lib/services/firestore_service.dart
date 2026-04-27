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
    final snapshot = await _db
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .where('providerId', isEqualTo: providerId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Writes the review and increments totalReviews atomically.
  ///
  /// Because seed providers don't exist in Firestore, the provider-doc
  /// increment uses set(merge:true) instead of update() so it never
  /// throws "document not found".
  Future<void> submitReview(ReviewModel review) async {
    final alreadyReviewed =
        await hasAlreadyReviewed(review.userId, review.providerId);
    if (alreadyReviewed) {
      throw Exception('You have already reviewed this provider.');
    }

    final batch = _db.batch();

    final reviewRef = _db.collection('reviews').doc();
    batch.set(reviewRef, review.toMap());

    // set(merge:true) is safe whether the provider doc exists or not.
    final providerRef = _db.collection('providers').doc(review.providerId);
    batch.set(
      providerRef,
      {'totalReviews': FieldValue.increment(1)},
      SetOptions(merge: true),
    );

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
}
