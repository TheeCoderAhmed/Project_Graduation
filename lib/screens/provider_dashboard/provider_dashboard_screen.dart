import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/provider_model.dart';
import '../../models/review_model.dart';
import '../../widgets/common/loading_indicator.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});
  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  ProviderModel? _myProvider;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMyProfile();
  }

  Future<void> _loadMyProfile() async {
    final auth = context.read<AuthProvider>();
    if (auth.userModel == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final uid = auth.userModel!.uid;

    // Try to find a real provider linked to the user's UID in Firestore.
    List<ProviderModel> providers = [];
    try {
      providers = await FirestoreService().getProvidersByOwner(uid);
    } catch (_) {}

    if (!mounted) return;

    final ProviderModel? provider =
        providers.isNotEmpty ? providers.first : null;

    setState(() { _myProvider = provider; _loading = false; });
    if (provider != null) {
      context.read<ReviewProvider>().loadReviews(provider.providerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<ReviewProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Dashboard', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const LoadingIndicator(message: 'Loading dashboard...')
          : _myProvider == null
              ? _buildNoProfile()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadMyProfile,
                  child: ListView(
                    padding: const EdgeInsets.all(AppTheme.containerMargin),
                    children: [
                      Text('Performance', style: GoogleFonts.manrope(
                        fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                      )),
                      const SizedBox(height: 4),
                      Text('Your ${_myProvider!.name} ratings at a glance', style: GoogleFonts.inter(
                        fontSize: 15, color: AppColors.textSecondary,
                      )),
                      const SizedBox(height: 24),
                      _buildStatsGrid(reviews),
                      const SizedBox(height: 28),
                      Text('Rating Breakdown', style: GoogleFonts.manrope(
                        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                      )),
                      const SizedBox(height: 16),
                      _buildBreakdownCard(reviews),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatsGrid(ReviewProvider reviews) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(
          icon: Icons.star_rounded,
          iconColor: AppColors.starGold,
          value: _myProvider!.averageRating.toStringAsFixed(1),
          label: 'Avg Rating',
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          icon: Icons.forum_rounded,
          iconColor: AppColors.secondary,
          value: reviews.isLoading ? '...' : reviews.reviews.length.toString(),
          label: 'Reviews',
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.primary,
          value: _myProvider!.rankingScore.toStringAsFixed(1),
          label: 'Score',
        )),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Semantics(
      label: '$value $label',
      child: ExcludeSemantics(
        child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.manrope(
          fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
        )),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.outline,
        )),
      ]),
    ),
      ),
    );
  }

  Widget _buildBreakdownCard(ReviewProvider reviews) {
    if (reviews.isLoading || reviews.reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(children: [
          const Icon(Icons.analytics_outlined, size: 40, color: AppColors.outline, semanticLabel: 'Analytics icon'),
          const SizedBox(height: 8),
          Text('No breakdown data available yet',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center),
        ]),
      );
    }

    // Calculate averages per category
    final rList = reviews.reviews;
    double avg(double Function(ReviewModel) getter) {
      final vals = rList.where((r) => getter(r) > 0).map(getter);
      if (vals.isEmpty) return 0;
      return vals.reduce((a, b) => a + b) / vals.length;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: [
        _buildBarRow('Wait Time', avg((r) => r.questionnaire.waitingTime)),
        const SizedBox(height: 16),
        _buildBarRow('Service', avg((r) => r.questionnaire.serviceQuality)),
        const SizedBox(height: 16),
        _buildBarRow('Hygiene', avg((r) => r.questionnaire.hygiene)),
        const SizedBox(height: 16),
        _buildBarRow('Staff', avg((r) => r.questionnaire.staffCommunication)),
      ]),
    );
  }

  Widget _buildBarRow(String label, double value) {
    final normalized = (value / 5.0).clamp(0.0, 1.0);
    return Semantics(
      label: '$label score is ${value.toStringAsFixed(1)} out of 5',
      child: ExcludeSemantics(
        child: Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: GoogleFonts.inter(
            color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500,
          )),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(value.toStringAsFixed(1), style: GoogleFonts.inter(
          fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary,
        )),
      ],
    ),
      ),
    );
  }

  Widget _buildNoProfile() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider),
          ),
          child: const Icon(Icons.business_rounded, size: 48, color: AppColors.outline, semanticLabel: 'No profile icon'),
        ),
        const SizedBox(height: 24),
        Text('No provider profile found',
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            'Contact support to claim and manage your healthcare provider listing.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {
            setState(() => _loading = true);
            _loadMyProfile();
          },
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Refresh'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
          ),
        ),
      ]),
    );
  }
}
