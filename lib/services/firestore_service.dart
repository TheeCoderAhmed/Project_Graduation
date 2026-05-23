import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/provider_model.dart';
import '../models/review_model.dart';
import '../models/community_doctor_model.dart';
import '../models/community_review_model.dart';

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

  /// Creates the provider's own listing, keyed by their UID so each provider
  /// account maps 1:1 to one listing. ownerId must equal the UID (enforced by
  /// security rules) so the dashboard can find it via getProvidersByOwner().
  Future<void> createProviderListing(ProviderModel provider) async {
    await _db
        .collection('providers')
        .doc(provider.providerId)
        .set(provider.toMap());
  }

  /// Doctor requests a change to their practice details (hospital / department
  /// / room). The live fields are NOT touched — the new values land in the
  /// pending* fields with status 'pending' until an admin approves. Security
  /// rules block the doctor from writing the live fields directly.
  Future<void> requestPracticeChange(
    String providerId, {
    required String hospital,
    required String department,
    required String room,
  }) async {
    await _db.collection('providers').doc(providerId).update({
      'pendingHospital': hospital,
      'pendingDepartment': department,
      'pendingRoom': room,
      'practiceChangeStatus': 'pending',
    });
  }

  // ── ADMIN: PRACTICE CHANGE APPROVALS ───────────────
  /// Providers with a practice change awaiting admin review.
  Future<List<ProviderModel>> getPendingPracticeChanges() async {
    final snapshot = await _db
        .collection('providers')
        .where('practiceChangeStatus', isEqualTo: 'pending')
        .get();
    return snapshot.docs
        .map((d) => ProviderModel.fromMap(d.id, d.data()))
        .toList();
  }

  /// Admin approves: copies the pending values onto the live fields and clears
  /// the pending state. Allowed by rules only for admins (live practice fields
  /// are locked to providers).
  Future<void> approvePracticeChange(ProviderModel p) async {
    await _db.collection('providers').doc(p.providerId).update({
      'hospital': p.pendingHospital ?? p.hospital,
      'department': p.pendingDepartment ?? p.department,
      'room': p.pendingRoom ?? p.room,
      'pendingHospital': null,
      'pendingDepartment': null,
      'pendingRoom': null,
      'practiceChangeStatus': null,
    });
  }

  /// Admin rejects: discards the pending values, keeps live fields unchanged.
  Future<void> rejectPracticeChange(String providerId) async {
    await _db.collection('providers').doc(providerId).update({
      'pendingHospital': null,
      'pendingDepartment': null,
      'pendingRoom': null,
      'practiceChangeStatus': null,
    });
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

  /// Provider posts (or edits) their public reply to a review. Only the two
  /// reply fields are written — security rules reject any other change and
  /// verify the caller owns the listing.
  Future<void> addProviderReply(String reviewId, String reply) async {
    await _db.collection('reviews').doc(reviewId).update({
      'providerReply': reply,
      'providerReplyAt': FieldValue.serverTimestamp(),
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

  // ── COMMUNITY (off-app doctor) REVIEWS ─────────────
  /// All community doctor listings, highest rated first.
  Future<List<CommunityDoctorModel>> getCommunityDoctors() async {
    final snapshot = await _db.collection('community_doctors').get();
    final list = snapshot.docs
        .map((d) => CommunityDoctorModel.fromMap(d.id, d.data()))
        .toList();
    list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return list;
  }

  /// All reviews for one community doctor, newest first.
  Future<List<CommunityReviewModel>> getCommunityReviews(
      String communityDoctorId) async {
    final snapshot = await _db
        .collection('community_reviews')
        .where('communityDoctorId', isEqualTo: communityDoctorId)
        .get();
    final list = snapshot.docs
        .map((d) => CommunityReviewModel.fromMap(d.id, d.data()))
        .toList();
    list.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return list;
  }

  /// All community reviews written by one user, newest first. Used by the
  /// patient's "My Reviews" tab so off-app reviews appear alongside in-app ones.
  Future<List<CommunityReviewModel>> getUserCommunityReviews(
      String userId) async {
    final snapshot = await _db
        .collection('community_reviews')
        .where('userId', isEqualTo: userId)
        .get();
    final list = snapshot.docs
        .map((d) => CommunityReviewModel.fromMap(d.id, d.data()))
        .toList();
    list.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return list;
  }

  /// Submits a community review and aggregates it into the doctor listing in
  /// one atomic transaction. The doctor doc is created on first review and
  /// incremented thereafter, so averages stay correct without a Cloud Function.
  /// One review per patient per doctor — enforced by the deterministic ID.
  Future<void> submitCommunityReview(CommunityReviewModel review) async {
    final doctorRef =
        _db.collection('community_doctors').doc(review.communityDoctorId);
    final reviewRef = _db
        .collection('community_reviews')
        .doc(_reviewId(review.userId, review.communityDoctorId));

    await _db.runTransaction((tx) async {
      final existing = await tx.get(reviewRef);
      if (existing.exists) {
        throw Exception('You have already reviewed this doctor.');
      }
      final doctorSnap = await tx.get(doctorRef);
      final q = review.questionnaire;

      if (!doctorSnap.exists) {
        tx.set(doctorRef, {
          'name': review.doctorName,
          'hospital': review.hospital,
          'department': review.department,
          'specialty': review.specialty,
          'totalReviews': 1,
          'ratingSum': review.overallRating,
          'waitSum': q.waitingTime,
          'serviceSum': q.serviceQuality,
          'hygieneSum': q.hygiene,
          'staffSum': q.staffCommunication,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        tx.update(doctorRef, {
          'totalReviews': FieldValue.increment(1),
          'ratingSum': FieldValue.increment(review.overallRating),
          'waitSum': FieldValue.increment(q.waitingTime),
          'serviceSum': FieldValue.increment(q.serviceQuality),
          'hygieneSum': FieldValue.increment(q.hygiene),
          'staffSum': FieldValue.increment(q.staffCommunication),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      tx.set(reviewRef, review.toMap());
    });
  }
}
