import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_routes.dart';
import '../../../constants/app_theme.dart';

// Gradient top banner: DRAPO logo, time-based greeting, user name, notifications button.
class HomeHeader extends StatelessWidget {
  // The logged-in user's display name shown in large text below the greeting.
  final String name;
  const HomeHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final greeting = _greeting();
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.containerMargin, 24, AppTheme.containerMargin, 28),
        // Blue gradient background — change colors in AppColors.primary / primaryContainer
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── App logo (icon + "DRAPO" text) ──
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      // To make the logo box circular: change to BorderRadius.circular(9999)
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: const Icon(Icons.local_hospital_rounded,
                        color: Colors.white, size: 20, semanticLabel: 'DRAPO logo'),
                  ),
                  const SizedBox(width: 10),
                  Text('DRAPO',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      )),
                ]),

                // ── Notifications button (top-right circle icon) ──
                // CircleBorder makes it round; tap opens NotificationsScreen
                Semantics(
                  button: true,
                  label: 'Notifications',
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.notifications);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Greeting + name ──
            // _greeting() returns "Good morning", "Good afternoon", or "Good evening"
            Text('$greeting 👋',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w400,
                )),
            const SizedBox(height: 4),
            Text(
              name,
              style: GoogleFonts.manrope(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Find the best healthcare near you',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Returns a greeting string based on the current hour (0–23).
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
