import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
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
  String? _userId;

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
        _userId = context.read<AuthProvider>().userModel?.uid;

        if (_userId != null) {
          context.read<ReviewProvider>().loadUserReviews(_userId!);
        }
        // If _userId is null the user is logged out — the empty state
        // below will prompt them with an appropriate message.
      }
    }
  }

  void _retry() {
    if (_isUserReviews) {
      if (_userId != null) {
        context.read<ReviewProvider>().loadUserReviews(_userId!);
      }
    } else if (_providerId != null) {
      context.read<ReviewProvider>().loadReviews(_providerId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewProv = context.watch<ReviewProvider>();
    final reviewList =
        _isUserReviews ? reviewProv.userReviews : reviewProv.reviews;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isUserReviews ? 'My Reviews' : 'All Reviews',
          style: GoogleFonts.manrope(
              fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(reviewProv, reviewList),
    );
  }

  Widget _buildBody(ReviewProvider reviewProv, List reviews) {
    // Still loading.
    if (reviewProv.isLoading) {
      return const LoadingIndicator(message: 'Loading reviews...');
    }

    // Not logged in — only possible in user-reviews mode.
    if (_isUserReviews && _userId == null) {
      return _buildMessage(
        icon: Icons.lock_outline_rounded,
        title: 'Sign in to see your reviews',
        subtitle: 'Your submitted reviews will appear here.',
        showRetry: false,
      );
    }

    // Error state with retry button — only shown in user-reviews mode
    // because provider reviews fall back silently to seed data.
    if (_isUserReviews && reviewProv.error != null && reviews.isEmpty) {
      return _buildMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load reviews',
        subtitle: reviewProv.error!,
        showRetry: true,
      );
    }

    // Empty — genuinely no reviews yet.
    if (reviews.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      itemCount: reviews.length,
      itemBuilder: (_, i) => ReviewCard(review: reviews[i]),
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
