import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;

  static const _pages = [
    _OnboardingData(
      icon: Icons.medical_services_rounded,
      title: 'Find the best doctors',
      body: 'Discover top-rated healthcare providers near you with verified profiles and patient reviews.',
      chipLabel: 'Verified Profiles',
      chipIcon: Icons.verified_rounded,
    ),
    _OnboardingData(
      icon: Icons.local_pharmacy_rounded,
      title: 'Rate your pharmacy',
      body: 'Help others find trusted pharmacies by sharing your honest service experience ratings.',
      chipLabel: 'Service Ratings',
      chipIcon: Icons.star_rounded,
    ),
    _OnboardingData(
      icon: Icons.people_rounded,
      title: 'Help the community',
      body: 'Your feedback helps improve healthcare quality for everyone in your community.',
      chipLabel: 'Shared Insights',
      chipIcon: Icons.insights_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Mark onboarding as completed and navigate to login.
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _next() {
    if (_current < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative blurred blob
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.6,
              height: MediaQuery.sizeOf(context).width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, top: 4),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: Text('Skip', style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      )),
                    ),
                  ),
                ),
                // Logo
                const SizedBox(height: 24),
                _buildLogo(),
                const SizedBox(height: 8),
                Text('DRAPO', style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                )),
                const SizedBox(height: 32),
                // Card carousel
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _current = i),
                    itemBuilder: (_, i) => _buildCard(_pages[i]),
                  ),
                ),
                // Pagination dots
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _current == i ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _current == i ? AppColors.primary : AppColors.divider,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  )),
                ),
                const SizedBox(height: 32),
                // CTA button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: AppColors.ambientShadow,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _current == _pages.length - 1 ? 'Get Started' : 'Next',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Already have an account
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Already have an account? ', style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  )),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _completeOnboarding,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      child: Text('Log in', style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                  ),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Center(
            child: Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 32),
          ),
          Positioned(
            bottom: -3,
            right: -3,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.starGold,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(_OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
          boxShadow: AppTheme.ambientShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Icon(data.icon, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            // Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(data.chipIcon, size: 14, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(data.chipLabel, style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                )),
              ]),
            ),
            const SizedBox(height: 20),
            Text(data.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(data.body,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String body;
  final String chipLabel;
  final IconData chipIcon;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.body,
    required this.chipLabel,
    required this.chipIcon,
  });
}
