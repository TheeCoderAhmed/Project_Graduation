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
import '../../widgets/review_card.dart';

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
                      if (_myProvider!.type == 'doctor') ...[
                        Text('Practice Information', style: GoogleFonts.manrope(
                          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                        )),
                        const SizedBox(height: 16),
                        _buildPracticeCard(),
                        const SizedBox(height: 28),
                      ],
                      Text('Rating Breakdown', style: GoogleFonts.manrope(
                        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                      )),
                      const SizedBox(height: 16),
                      _buildBreakdownCard(reviews),
                      const SizedBox(height: 28),
                      Text('Patient Reviews', style: GoogleFonts.manrope(
                        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                      )),
                      const SizedBox(height: 8),
                      ..._buildReviewsList(reviews),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
    );
  }

  List<Widget> _buildReviewsList(ReviewProvider reviews) {
    if (reviews.isLoading) {
      return [const Padding(padding: EdgeInsets.all(24), child: LoadingIndicator())];
    }
    if (reviews.reviews.isEmpty) {
      return [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(children: [
            const Icon(Icons.forum_outlined, size: 40, color: AppColors.outline),
            const SizedBox(height: 8),
            Text('No reviews yet',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
          ]),
        ),
      ];
    }
    // ReviewCard already renders any existing reply. Below it we add the
    // reply action so the provider can respond or edit their response.
    return reviews.reviews.map((r) {
      final hasReply = r.providerReply != null && r.providerReply!.isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReviewCard(review: r),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _showReplyDialog(r),
                icon: Icon(hasReply ? Icons.edit_rounded : Icons.reply_rounded, size: 16),
                label: Text(hasReply ? 'Edit reply' : 'Reply'),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Future<void> _showReplyDialog(ReviewModel review) async {
    final ctrl = TextEditingController(text: review.providerReply ?? '');
    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: Text('Reply to ${review.userName}',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 18)),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Write a professional response...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
            ),
            onPressed: () => Navigator.pop(dialogContext, ctrl.text.trim()),
            child: const Text('Post Reply'),
          ),
        ],
      ),
    );

    if (text == null || text.isEmpty || !mounted) return;
    final ok = await context.read<ReviewProvider>().replyToReview(review.reviewId, text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Reply posted' : 'Could not post reply'),
        backgroundColor: ok ? AppColors.primary : AppColors.error,
      ),
    );
  }

  Widget _buildPracticeCard() {
    final p = _myProvider!;
    final pending = p.hasPendingPracticeChange;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _practiceRow(Icons.local_hospital_outlined, 'Hospital', p.hospital),
          const SizedBox(height: 14),
          _practiceRow(Icons.account_tree_outlined, 'Department', p.department),
          const SizedBox(height: 14),
          _practiceRow(Icons.meeting_room_outlined, 'Room / Office', p.room),
          if (pending) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.starGold.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppColors.starGold.withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.hourglass_top_rounded, size: 18, color: AppColors.starGold),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Change pending approval',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        '${p.pendingHospital ?? '-'} · ${p.pendingDepartment ?? '-'}'
                        '${(p.pendingRoom ?? '').isNotEmpty ? ' · ${p.pendingRoom}' : ''}',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: pending ? null : _showPracticeDialog,
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: Text(pending ? 'Awaiting approval' : 'Request a change'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _practiceRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                (value == null || value.isEmpty) ? 'Not set' : value,
                style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showPracticeDialog() async {
    final hospitalCtrl = TextEditingController(text: _myProvider!.hospital ?? '');
    final deptCtrl = TextEditingController(text: _myProvider!.department ?? '');
    final roomCtrl = TextEditingController(text: _myProvider!.room ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: Text('Request practice change',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Updates are reviewed by an admin before going live.',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextFormField(
                controller: hospitalCtrl,
                decoration: const InputDecoration(labelText: 'Hospital / Clinic', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: deptCtrl,
                decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: roomCtrl,
                decoration: const InputDecoration(labelText: 'Room / Office (optional)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (saved != true || !mounted) return;
    bool ok = true;
    try {
      await FirestoreService().requestPracticeChange(
        _myProvider!.providerId,
        hospital: hospitalCtrl.text.trim(),
        department: deptCtrl.text.trim(),
        room: roomCtrl.text.trim(),
      );
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    if (ok) {
      setState(() {
        _myProvider = _myProvider!.copyWith(
          pendingHospital: hospitalCtrl.text.trim(),
          pendingDepartment: deptCtrl.text.trim(),
          pendingRoom: roomCtrl.text.trim(),
          practiceChangeStatus: 'pending',
        );
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Change submitted for approval' : 'Could not submit change'),
        backgroundColor: ok ? AppColors.primary : AppColors.error,
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
          const Icon(Icons.insights_rounded, size: 40, color: AppColors.outline, semanticLabel: 'Reviews chart icon'),
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
        Text('Listing not loaded',
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            "We couldn't load your listing right now. Check your connection and refresh.",
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
