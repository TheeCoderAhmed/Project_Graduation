import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../models/provider_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../services/firestore_service.dart';
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
    final p = await FirestoreService().getProvider(id);
    if (!mounted) return;
    setState(() { _provider = p; _loading = false; });
    if (p != null) {
      context.read<ReviewProvider>().loadReviews(p.providerId);
    }
  }

  void _toggleBookmark(bool isCurrentlyBookmarked) async {
    final auth = context.read<AuthProvider>();
    if (auth.userModel == null || _provider == null) return;
    final add = !isCurrentlyBookmarked;
    auth.toggleBookmark(_provider!.providerId, add);
    await FirestoreService().toggleBookmark(
        auth.userModel!.uid, _provider!.providerId, add);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingIndicator());
    if (_provider == null) return const Scaffold(body: Center(child: Text('Provider not found')));
    final reviews = context.watch<ReviewProvider>();
    final auth = context.watch<AuthProvider>();
    final isBookmarked = auth.userModel?.bookmarks.contains(_provider!.providerId) ?? false;

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, color: Colors.white, size: 26),
                onPressed: () => _toggleBookmark(isBookmarked),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            title: Text(
              _provider!.name, 
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w700, 
                color: Colors.white, 
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)]
              )
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                _provider!.photoUrl != null
                    ? CachedNetworkImage(imageUrl: _provider!.photoUrl!, fit: BoxFit.cover)
                    : Container(color: AppColors.primaryLight),
                // Gradient overlay for text legibility
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black45],
                      stops: [0.6, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildInfoRow(Icons.medical_services_rounded, _provider!.specialty),
              _buildInfoRow(Icons.location_on_rounded, _provider!.address),
              _buildInfoRow(Icons.phone_rounded, _provider!.phone),
              const SizedBox(height: 24),
              _buildRatingCard(),
              const SizedBox(height: 24),
              AppButton(
                label: 'Write a Review',
                icon: Icons.rate_review_rounded,
                onPressed: () => Navigator.pushNamed(
                  context, AppRoutes.questionnaire, arguments: _provider!.providerId,
                ),
              ),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Verified Reviews', style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.reviewsList, arguments: _provider!.providerId),
                  child: const Text('See all'),
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
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _buildRatingCard() {
    final reviews = context.read<ReviewProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildStat(_provider!.averageRating.toStringAsFixed(1), 'Rating', Icons.star_rounded),
        _buildStat(reviews.isLoading ? '...' : reviews.reviews.length.toString(), 'Reviews', Icons.forum_rounded),
        _buildStat(_provider!.rankingScore.toStringAsFixed(1), 'Score', Icons.trending_up_rounded),
      ]),
    );
  }

  Widget _buildStat(String value, String label, IconData icon) {
    return Column(children: [
      Icon(icon, color: AppColors.accent, size: 28),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
    ]);
  }
}
