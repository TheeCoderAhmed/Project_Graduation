import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_routes.dart';
import '../../../constants/app_theme.dart';

// Fake search bar on the home screen.
// It looks like a text field but is not editable — tapping it navigates to SearchScreen.
// This pattern avoids opening the keyboard on the home screen.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Search for doctors and pharmacies',
      child: GestureDetector(
        // Tap anywhere on the bar → go to the real search screen
        onTap: () => Navigator.pushNamed(context, AppRoutes.search),
        child: ExcludeSemantics(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              // To make the bar fully rounded (pill shape): change radiusSm → radiusFull
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppColors.divider),
              boxShadow: AppTheme.subtleShadow,
            ),
            child: Row(children: [
              // Magnifier icon on the left
              const Icon(Icons.search_rounded, color: AppColors.outline, size: 22),
              const SizedBox(width: 12),
              // Placeholder text — not a real input. Expanded so it shrinks
              // instead of overflowing on narrow screens.
              Expanded(
                child: Text('Search doctors, pharmacies...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: AppColors.outline,
                      fontSize: 15,
                    )),
              ),
              const SizedBox(width: 12),
              // "Search" pill badge on the right — purely decorative
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text('Search',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    )),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
