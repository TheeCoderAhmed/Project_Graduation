import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_theme.dart';
import '../../../models/provider_model.dart';

// Summary strip showing total doctors, pharmacies, and combined review count.
// Numbers come from the lists passed in — no extra Firestore reads.
class HomeStatsBar extends StatelessWidget {
  final List<ProviderModel> doctors;
  final List<ProviderModel> pharmacies;

  const HomeStatsBar({
    super.key,
    required this.doctors,
    required this.pharmacies,
  });

  @override
  Widget build(BuildContext context) {
    // Sum totalReviews across all doctors and all pharmacies
    final totalReviews =
        doctors.fold<int>(0, (sum, p) => sum + p.totalReviews) +
        pharmacies.fold<int>(0, (sum, p) => sum + p.totalReviews);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Subtle two-color gradient background — change alpha values to adjust intensity
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      // Three equal columns separated by thin vertical lines
      child: Row(
        children: [
          _buildStat(doctors.length.toString(), 'Doctors'),
          _buildDivider(),
          _buildStat(pharmacies.length.toString(), 'Pharmacies'),
          _buildDivider(),
          _buildStat(_formatNum(totalReviews), 'Reviews'),
        ],
      ),
    );
  }

  // One stat column: large number on top, small label below.
  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Semantics(
        label: '$value $label',
        child: ExcludeSemantics(
          child: Column(children: [
            // Large number — uses AppColors.primary (medical blue)
            Text(value,
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                )),
            Text(label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                )),
          ]),
        ),
      ),
    );
  }

  // Thin 1px vertical divider between stat columns
  Widget _buildDivider() =>
      Container(width: 1, height: 40, color: AppColors.divider);

  // Converts large numbers to a compact form: 1200 → "1.2k"
  String _formatNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}
