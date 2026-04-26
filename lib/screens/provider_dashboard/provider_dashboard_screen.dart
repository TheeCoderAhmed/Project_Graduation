import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/provider_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/review_card.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  ProviderModel? _ownProvider;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();

    // Guard: only providers can access this screen
    if (auth.userModel?.role != 'provider') {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }

    final uid = auth.firebaseUser?.uid;
    if (uid == null) return;

    // Find the provider document owned by this user
    final db = FirestoreService();
    // Search providers by ownerId
    final providers = await db.getProvidersByOwner(uid);
    if (!mounted) return;

    if (providers.isNotEmpty) {
      final p = providers.first;
      setState(() {
        _ownProvider = p;
        _loading = false;
      });
      context.read<ReviewProvider>().loadReviews(p.providerId);
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const LoadingIndicator(message: 'Loading your dashboard...')
          : _ownProvider == null
              ? _buildNoProviderProfile()
              : _buildDashboard(),
    );
  }

  Widget _buildNoProviderProfile() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.business_outlined, size: 80, color: AppColors.divider),
          SizedBox(height: 20),
          Text(
            'No Provider Profile Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Your provider account is not yet linked to a provider listing. Please contact an administrator.',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }

  Widget _buildDashboard() {
    final reviews = context.watch<ReviewProvider>();
    final p = _ownProvider!;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProviderHeader(p),
          const SizedBox(height: 20),
          _buildStatsGrid(p),
          const SizedBox(height: 20),
          _buildScoreBreakdown(p),
          const SizedBox(height: 20),
          if (reviews.isLoading)
            const LoadingIndicator(message: 'Loading reviews...')
          else ...[
            _buildSectionTitle('Recent Patient Reviews'),
            if (reviews.reviews.isEmpty)
              _buildEmptyReviews()
            else
              ...reviews.reviews.take(5).map((r) => ReviewCard(review: r)),
            if (reviews.reviews.length > 5) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.reviewsList,
                  arguments: p.providerId,
                ),
                icon: const Icon(Icons.list_alt),
                label: Text('See all ${reviews.reviews.length} reviews'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProviderHeader(ProviderModel p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            p.type == 'pharmacy' ? Icons.local_pharmacy_outlined : Icons.local_hospital_outlined,
            color: Colors.white, size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(p.specialty, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 4),
            Text(p.address, style: const TextStyle(color: Colors.white60, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStatsGrid(ProviderModel p) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard('⭐ Rating', p.averageRating.toStringAsFixed(1), AppColors.accent),
        _buildStatCard('📝 Reviews', p.totalReviews.toString(), AppColors.primary),
        _buildStatCard('🏆 Score', p.rankingScore.toStringAsFixed(1), AppColors.success),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildScoreBreakdown(ProviderModel p) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSectionTitle('Ranking Formula'),
          const SizedBox(height: 12),
          _buildFormulaRow('Overall Rating (40%)', p.averageRating, AppColors.accent),
          const SizedBox(height: 8),
          _buildFormulaRow('Questionnaire Score (60%)', p.rankingScore, AppColors.primary),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Final Ranking Score', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              child: Text(
                p.rankingScore.toStringAsFixed(2),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildFormulaRow(String label, double score, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(score.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: score / 5.0,
          backgroundColor: color.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ),
    ]);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Column(children: [
        Icon(Icons.rate_review_outlined, size: 48, color: AppColors.divider),
        SizedBox(height: 12),
        Text('No reviews yet', style: TextStyle(color: AppColors.textSecondary)),
        Text('Reviews from patients will appear here.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ]),
    );
  }
}
