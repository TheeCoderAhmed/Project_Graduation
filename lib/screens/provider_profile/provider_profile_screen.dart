import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_theme.dart';
import '../../models/provider_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/provider_provider.dart';
import '../../widgets/review_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/loading_indicator.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});
  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  ProviderModel? _provider;
  bool _loading = true;
  bool _initDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initDone) {
      _initDone = true;
      final id = ModalRoute.of(context)!.settings.arguments as String;
      _load(id);
    }
  }

  Future<void> _load(String id) async {
    // Resolve from seed data instantly — no Firestore read needed for providers.
    final p = context.read<ProviderProvider>().getById(id);
    if (!mounted) return;
    setState(() { _provider = p; _loading = false; });
    if (p != null) {
      // loadReviews merges real Firestore reviews on top of seed reviews.
      context.read<ReviewProvider>().loadReviews(p.providerId);
    }
  }

  void _toggleBookmark(bool isCurrentlyBookmarked) async {
    final auth = context.read<AuthProvider>();
    if (auth.userModel == null || _provider == null) return;
    final add = !isCurrentlyBookmarked;

    // Optimistic local update.
    auth.toggleBookmark(_provider!.providerId, add);

    // Persist to Firestore — real UID, real write.
    final ok = await context
        .read<ProviderProvider>()
        .toggleBookmark(auth.userModel!.uid, _provider!.providerId, add);

    if (!ok && mounted) {
      // Firestore write failed — roll back the optimistic toggle.
      auth.revertBookmark(_provider!.providerId, isCurrentlyBookmarked);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save bookmark. Check your connection.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingIndicator());
    if (_provider == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.divider),
              const SizedBox(height: 16),
              Text('Provider not found', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('This provider profile may have been removed.', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go back'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final reviews = context.watch<ReviewProvider>();
    final auth = context.watch<AuthProvider>();
    final isBookmarked = auth.userModel?.bookmarks.contains(_provider!.providerId) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: AppColors.primary,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: Colors.white, size: 24,
                ),
                onPressed: () => _toggleBookmark(isBookmarked),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            title: Text(
              _provider!.name,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [const Shadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                _provider!.photoUrl != null
                    ? CachedNetworkImage(imageUrl: _provider!.photoUrl!, fit: BoxFit.cover)
                    : Container(color: AppColors.primaryContainer),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black45],
                      stops: [0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.containerMargin),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Info rows
              _buildInfoRow(Icons.medical_services_rounded, _provider!.specialty),
              _buildInfoRow(Icons.location_on_rounded, _provider!.address),
              _buildInfoRow(Icons.phone_rounded, _provider!.phone),
              const SizedBox(height: 24),
              // Rating card
              _buildRatingCard(reviews),
              const SizedBox(height: 24),
              // Write a Review CTA
              AppButton(
                label: 'Write a Review',
                icon: Icons.rate_review_rounded,
                onPressed: () => Navigator.pushNamed(
                  context, AppRoutes.questionnaire, arguments: _provider!.providerId,
                ),
              ),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Patient Reviews', style: GoogleFonts.manrope(
                  fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                )),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.reviewsList, arguments: _provider!.providerId),
                  child: Text('See all', style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary,
                  )),
                ),
              ]),
            ]),
          ),
        ),
        reviews.isLoading
            ? const SliverToBoxAdapter(child: LoadingIndicator())
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ReviewCard(review: reviews.reviews[i]),
                  childCount: reviews.reviews.length.clamp(0, 3),
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ]),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(text, style: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
        ))),
      ]),
    );
  }

  Widget _buildRatingCard(ReviewProvider reviews) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildStat(_provider!.averageRating.toStringAsFixed(1), 'Rating', Icons.star_rounded, AppColors.starGold),
        Container(width: 1, height: 48, color: AppColors.divider),
        _buildStat(reviews.isLoading ? '...' : reviews.reviews.length.toString(), 'Reviews', Icons.forum_rounded, AppColors.secondary),
        Container(width: 1, height: 48, color: AppColors.divider),
        _buildStat(_provider!.rankingScore.toStringAsFixed(1), 'Score', Icons.trending_up_rounded, AppColors.primary),
      ]),
    );
  }

  Widget _buildStat(String value, String label, IconData icon, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 6),
      Text(value, style: GoogleFonts.manrope(
        fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
      )),
      Text(label, style: GoogleFonts.inter(
        color: AppColors.outline, fontSize: 12, fontWeight: FontWeight.w500,
      )),
    ]);
  }
}
