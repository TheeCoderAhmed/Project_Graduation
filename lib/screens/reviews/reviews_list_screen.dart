import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/provider_provider.dart';
import '../../models/review_model.dart';
import '../../widgets/review_card.dart';
import '../../widgets/common/loading_indicator.dart';

class ReviewsListScreen extends StatefulWidget {
  const ReviewsListScreen({super.key});

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  bool _initDone = false;
  bool _isUserReviews = false;
  String? _providerId;
  /// Tracks the last UID we triggered a load for so we don't re-fetch
  /// on every rebuild, but DO re-fetch when auth state changes.
  String? _loadedForUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initDone) {
      _initDone = true;
      _providerId = ModalRoute.of(context)?.settings.arguments as String?;

      if (_providerId != null) {
        // Showing all reviews for a specific provider.
        context.read<ReviewProvider>().loadReviews(_providerId!);
      } else {
        // Showing the signed-in user's own review history.
        _isUserReviews = true;
        _tryLoadUserReviews();
      }
    }
  }

  /// Called both from didChangeDependencies (initial) and from build()
  /// when the auth state changes (user logs in while tab is mounted).
  void _tryLoadUserReviews() {
    final uid = context.read<AuthProvider>().userModel?.uid;
    if (uid != null && uid != _loadedForUid) {
      _loadedForUid = uid;
      context.read<ReviewProvider>().loadUserReviews(uid);
    }
  }

  void _retry() {
    if (_isUserReviews) {
      final uid = context.read<AuthProvider>().userModel?.uid;
      if (uid != null) {
        context.read<ReviewProvider>().loadUserReviews(uid);
      }
    } else if (_providerId != null) {
      context.read<ReviewProvider>().loadReviews(_providerId!);
    }
  }

  /// Resolves a provider name from the ProviderProvider cache.
  String _resolveProviderName(String providerId) {
    final provider = context.read<ProviderProvider>().getById(providerId);
    return provider?.name ?? 'Unknown Provider';
  }

  /// Navigates to the provider profile screen.
  void _navigateToProvider(String providerId) {
    Navigator.pushNamed(
      context,
      AppRoutes.providerProfile,
      arguments: providerId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reviewProv = context.watch<ReviewProvider>();
    final reviewList =
        _isUserReviews ? reviewProv.userReviews : reviewProv.reviews;

    // Re-trigger load when user signs in while the Reviews tab is already
    // mounted (e.g. inside an IndexedStack in MainWrapper).
    if (_isUserReviews && auth.userModel?.uid != null) {
      _tryLoadUserReviews();
    }

    final isLoggedIn = auth.isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isUserReviews ? 'My Reviews' : 'All Reviews',
          style: GoogleFonts.manrope(
              fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(reviewProv, reviewList, isLoggedIn),
    );
  }

  Widget _buildBody(ReviewProvider reviewProv, List reviews, bool isLoggedIn) {
    // Still loading.
    if (reviewProv.isLoading) {
      return const LoadingIndicator(message: 'Loading reviews...');
    }

    // Not logged in — only possible in user-reviews mode.
    if (_isUserReviews && !isLoggedIn) {
      return _buildMessage(
        icon: Icons.lock_outline_rounded,
        title: 'Sign in to see your reviews',
        subtitle: 'Your submitted reviews will appear here.',
        showRetry: false,
      );
    }

    // Error state with retry button.
    if (_isUserReviews && reviewProv.error != null && reviews.isEmpty) {
      return _buildMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load reviews',
        subtitle: reviewProv.error!,
        showRetry: true,
      );
    }

    // In "My Reviews" mode, merge in-app reviews + community (off-app) reviews.
    final communityReviews = _isUserReviews ? reviewProv.userCommunityReviews : const [];

    // Empty — genuinely no reviews yet.
    if (reviews.isEmpty && communityReviews.isEmpty) {
      return _buildMessage(
        icon: Icons.rate_review_outlined,
        title: _isUserReviews
            ? 'You haven\'t reviewed anyone yet'
            : 'No reviews yet',
        subtitle: _isUserReviews
            ? 'After visiting a provider, share your experience!'
            : 'Be the first to share your experience!',
        showRetry: false,
      );
    }

    if (!_isUserReviews) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        itemCount: reviews.length,
        itemBuilder: (_, i) => ReviewCard(review: reviews[i]),
      );
    }

    // "My Reviews": build a combined, date-sorted list of cards. Community
    // reviews are mapped to ReviewModel so they render in the same card.
    final entries = <_MyReviewEntry>[];
    for (final r in reviewProv.userReviews) {
      entries.add(_MyReviewEntry(
        review: r,
        providerName: _resolveProviderName(r.providerId),
        onTap: () => _navigateToProvider(r.providerId),
        sortKey: r.createdAt?.millisecondsSinceEpoch ?? 0,
      ));
    }
    for (final c in reviewProv.userCommunityReviews) {
      entries.add(_MyReviewEntry(
        review: ReviewModel(
          reviewId: c.reviewId,
          providerId: c.communityDoctorId,
          userId: c.userId,
          userName: c.userName,
          overallRating: c.overallRating,
          comment: c.comment,
          questionnaire: c.questionnaire,
          createdAt: c.createdAt,
        ),
        // Off-app doctors aren't tappable provider profiles; show identity.
        providerName: c.hospital.isNotEmpty
            ? '${c.doctorName} · ${c.hospital} (off-app)'
            : '${c.doctorName} (off-app)',
        onTap: null,
        sortKey: c.createdAt?.millisecondsSinceEpoch ?? 0,
      ));
    }
    entries.sort((a, b) => b.sortKey.compareTo(a.sortKey));

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _retry(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        itemCount: entries.length,
        itemBuilder: (_, i) => ReviewCard(
          review: entries[i].review,
          providerName: entries[i].providerName,
          onTap: entries[i].onTap,
        ),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: Icon(icon, size: 48, color: AppColors.outline),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
            if (showRetry) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One row in the "My Reviews" list — wraps an in-app or community review so
/// both render in the same card and sort together by date.
class _MyReviewEntry {
  final ReviewModel review;
  final String? providerName;
  final VoidCallback? onTap;
  final int sortKey;
  _MyReviewEntry({
    required this.review,
    required this.providerName,
    required this.onTap,
    required this.sortKey,
  });
}
