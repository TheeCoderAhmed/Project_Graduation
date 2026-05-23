import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../models/community_doctor_model.dart';
import '../../models/review_model.dart';
import '../../providers/community_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/review_card.dart';
import '../../widgets/star_rating_widget.dart';

/// Shows one off-app doctor: identity, average rating, breakdown, and all
/// patient reviews. Expects a [CommunityDoctorModel] as the route argument.
class CommunityDoctorDetailScreen extends StatefulWidget {
  const CommunityDoctorDetailScreen({super.key});

  @override
  State<CommunityDoctorDetailScreen> createState() =>
      _CommunityDoctorDetailScreenState();
}

class _CommunityDoctorDetailScreenState
    extends State<CommunityDoctorDetailScreen> {
  CommunityDoctorModel? _doctor;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is CommunityDoctorModel) {
        _doctor = arg;
        _init = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<CommunityProvider>().loadReviews(_doctor!.id);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityProvider>();
    final d = _doctor;
    if (d == null) {
      return const Scaffold(body: Center(child: LoadingIndicator()));
    }
    final reviews = community.doctorReviews;
    final n = d.totalReviews == 0 ? 1 : d.totalReviews;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(d.name,
            style: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.containerMargin),
        children: [
          _buildHeader(d),
          const SizedBox(height: 24),
          if (d.totalReviews > 0) ...[
            Text('Rating Breakdown',
                style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _buildBreakdown(d, n),
            const SizedBox(height: 24),
          ],
          Text('Patient Reviews',
              style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          if (community.isLoading)
            const Padding(padding: EdgeInsets.all(24), child: LoadingIndicator())
          else if (reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No reviews to show.',
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
            )
          else
            ...reviews.map((r) => ReviewCard(
                  review: ReviewModel(
                    reviewId: r.reviewId,
                    providerId: r.communityDoctorId,
                    userId: r.userId,
                    userName: r.userName,
                    overallRating: r.overallRating,
                    comment: r.comment,
                    questionnaire: r.questionnaire,
                    createdAt: r.createdAt,
                  ),
                )),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildHeader(CommunityDoctorModel d) {
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
          Row(children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              child: const Icon(Icons.person_rounded,
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.name,
                      style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  if (d.specialty.isNotEmpty)
                    Text(d.specialty,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _infoRow(Icons.local_hospital_outlined, d.hospital),
          if (d.department.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.account_tree_outlined, d.department),
          ],
          const SizedBox(height: 16),
          Row(children: [
            Text(d.averageRating.toStringAsFixed(1),
                style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(width: 10),
            StarRatingWidget(rating: d.averageRating, size: 20),
            const Spacer(),
            Text('${d.totalReviews} review${d.totalReviews == 1 ? '' : 's'}',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary)),
          ]),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.outline),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary)),
      ),
    ]);
  }

  Widget _buildBreakdown(CommunityDoctorModel d, int n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: [
        _barRow('Wait Time', d.waitSum / n),
        const SizedBox(height: 16),
        _barRow('Service', d.serviceSum / n),
        const SizedBox(height: 16),
        _barRow('Hygiene', d.hygieneSum / n),
        const SizedBox(height: 16),
        _barRow('Staff', d.staffSum / n),
      ]),
    );
  }

  Widget _barRow(String label, double value) {
    final normalized = (value / 5.0).clamp(0.0, 1.0);
    return Row(children: [
      SizedBox(
        width: 70,
        child: Text(label,
            style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: LinearProgressIndicator(
            value: normalized,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainer,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Text(value.toStringAsFixed(1),
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textPrimary)),
    ]);
  }
}
