import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_routes.dart';
import '../../../constants/app_theme.dart';

// Horizontal row of specialty chips: Cardiologist, Pediatrics, Pharmacy, etc.
// Tapping a chip opens SearchScreen pre-filtered by that specialty label.
class HomeQuickCategories extends StatelessWidget {
  const HomeQuickCategories({super.key});

  @override
  Widget build(BuildContext context) {
    // Add or remove specialties here to change what chips appear.
    // Each entry uses background color + accent color from AppColors.
    final categories = [
      const _Category('Cardiologist',  Icons.favorite_rounded,               AppColors.catCardioBg,  AppColors.catCardioAccent),
      const _Category('Pediatrics',    Icons.child_care_rounded,             AppColors.catPedsBg,    AppColors.catPedsAccent),
      const _Category('Dermatology',   Icons.face_retouching_natural_rounded, AppColors.catDermBg,    AppColors.catDermAccent),
      const _Category('Pharmacy',      Icons.local_pharmacy_rounded,         AppColors.catPharmBg,   AppColors.catPharmAccent),
      const _Category('Neurology',     Icons.psychology_rounded,             AppColors.catNeuroBg,   AppColors.catNeuroAccent),
      const _Category('Orthopedics',   Icons.accessibility_new_rounded,      AppColors.catOrthoBg,   AppColors.catOrthoAccent),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
        child: Text('Browse Specialties',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            )),
      ),
      const SizedBox(height: 12),
      // Height 96 = icon (28) + gap (6) + 2 lines of text (~10×2 + lineHeight)
      SizedBox(
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _buildChip(context, categories[i]),
        ),
      ),
    ]);
  }

  // Builds a single square specialty chip.
  Widget _buildChip(BuildContext context, _Category cat) {
    return Semantics(
      button: true,
      label: 'Search for ${cat.label}',
      child: GestureDetector(
        // Pass specialty name as argument so SearchScreen can pre-fill the filter
        onTap: () => Navigator.pushNamed(context, AppRoutes.search, arguments: cat.label),
        child: ExcludeSemantics(
          child: Container(
            // 22% of screen width — adjust to make chips wider or narrower
            width: MediaQuery.sizeOf(context).width * 0.22,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cat.bg,     // light tinted background per specialty
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: cat.accent.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat.icon, color: cat.accent, size: 28),
                const SizedBox(height: 6),
                Text(cat.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Data class for a specialty chip — holds its label, icon, and two colors.
class _Category {
  final String label;
  final IconData icon;
  final Color bg;      // chip background (light tint)
  final Color accent;  // icon + text color (darker shade of the same hue)
  const _Category(this.label, this.icon, this.bg, this.accent);
}
