import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/provider_provider.dart';
import '../../widgets/provider_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../models/provider_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderProvider>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provState = context.watch<ProviderProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: provState.isLoading
          ? const LoadingIndicator(message: 'Loading providers...')
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<ProviderProvider>().loadHomeData(showLoading: false),
              child: ListView(
                padding: const EdgeInsets.only(top: 0, bottom: 100),
                children: [
                  _buildHeader(auth.userModel?.fullName ?? 'there'),
                  const SizedBox(height: 20),
                  _buildSearchBar(context),
                  const SizedBox(height: 24),
                  _buildQuickCategories(context),
                  const SizedBox(height: 28),
                  _buildStatsBar(provState),
                  const SizedBox(height: 28),
                  _buildSection(
                    context,
                    'Top Rated Doctors',
                    provState.topDoctors,
                    horizontal: true,
                  ),
                  const SizedBox(height: 28),
                  _buildSection(
                    context,
                    'Pharmacies Near Me',
                    provState.topPharmacies,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(String name) {
    final greeting = _greeting();
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.containerMargin, 24, AppTheme.containerMargin, 28),
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
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
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

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildSearchBar(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Search for doctors and pharmacies',
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.search),
        child: ExcludeSemantics(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppColors.divider),
              boxShadow: AppTheme.subtleShadow,
            ),
            child: Row(children: [
              const Icon(Icons.search_rounded, color: AppColors.outline, size: 22),
              const SizedBox(width: 12),
              Text('Search doctors, pharmacies...',
                  style: GoogleFonts.inter(
                    color: AppColors.outline,
                    fontSize: 15,
                  )),
              const Spacer(),
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

  Widget _buildQuickCategories(BuildContext context) {
    final categories = [
      const _Category('Cardiologist', Icons.favorite_rounded, AppColors.catCardioBg, AppColors.catCardioAccent),
      const _Category('Pediatrics', Icons.child_care_rounded, AppColors.catPedsBg, AppColors.catPedsAccent),
      const _Category('Dermatology', Icons.face_retouching_natural_rounded, AppColors.catDermBg, AppColors.catDermAccent),
      const _Category('Pharmacy', Icons.local_pharmacy_rounded, AppColors.catPharmBg, AppColors.catPharmAccent),
      const _Category('Neurology', Icons.psychology_rounded, AppColors.catNeuroBg, AppColors.catNeuroAccent),
      const _Category('Orthopedics', Icons.accessibility_new_rounded, AppColors.catOrthoBg, AppColors.catOrthoAccent),
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
      SizedBox(
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _buildCategoryChip(context, categories[i]),
        ),
      ),
    ]);
  }

  Widget _buildCategoryChip(BuildContext context, _Category cat) {
    return Semantics(
      button: true,
      label: 'Search for ${cat.label}',
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.search, arguments: cat.label);
        },
        child: ExcludeSemantics(
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.22,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cat.bg,
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
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cat.accent,
                      height: 1.2,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar(ProviderProvider provState) {
    final totalDoctors = provState.topDoctors.length;
    final totalPharmacies = provState.topPharmacies.length;
    final totalReviews = provState.topDoctors.fold<int>(0, (a, b) => a + b.totalReviews) +
        provState.topPharmacies.fold<int>(0, (a, b) => a + b.totalReviews);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _buildStat2(totalDoctors.toString(), 'Doctors'),
          _buildDivider(),
          _buildStat2(totalPharmacies.toString(), 'Pharmacies'),
          _buildDivider(),
          _buildStat2(_formatNum(totalReviews), 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildStat2(String value, String label) {
    return Expanded(
      child: Semantics(
        label: '$value $label',
        child: ExcludeSemantics(
          child: Column(children: [
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

  Widget _buildDivider() =>
      Container(width: 1, height: 40, color: AppColors.divider);

  String _formatNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  Widget _buildSection(BuildContext context, String title, List<ProviderModel> list,
      {bool horizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              if (list.isNotEmpty)
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.search),
                  child: Text('View all',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      )),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          _buildEmptyState(title, onRetry: () => context.read<ProviderProvider>().loadHomeData())
        else if (horizontal)
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.containerMargin),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) => _buildHorizontalCard(context, list[i]),
            ),
          )
        else
          ...list.map((p) => Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.containerMargin - 16, vertical: 4),
                child: ProviderCard(
                  provider: p,
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.providerProfile,
                      arguments: p.providerId),
                ),
              )),
      ],
    );
  }

  Widget _buildHorizontalCard(BuildContext context, ProviderModel provider) {
    return Semantics(
      button: true,
      label: 'View details for ${provider.name}, ${provider.specialty}, Rating: ${provider.averageRating.toStringAsFixed(1)} stars from ${provider.totalReviews} reviews',
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.providerProfile,
            arguments: provider.providerId),
        child: ExcludeSemantics(
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.45,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.divider),
              boxShadow: AppTheme.subtleShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(
                    provider.type == 'pharmacy'
                        ? Icons.local_pharmacy_rounded
                        : Icons.local_hospital_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const Spacer(),
                Text(provider.name,
                    style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(provider.specialty,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryFixed,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: AppColors.tertiary),
                        const SizedBox(width: 3),
                        Text(provider.averageRating.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.tertiary)),
                      ]),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('${provider.totalReviews} reviews',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.outline),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, {VoidCallback? onRetry}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.containerMargin, vertical: 20),
      child: Column(children: [
        const Icon(Icons.search_off_rounded,
            size: 48, color: AppColors.divider, semanticLabel: 'No results icon'),
        const SizedBox(height: 8),
        Text('No $title found',
            style: GoogleFonts.inter(
                color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 4),
        Text('Check back soon as providers are added or try refreshing.',
            style: GoogleFonts.inter(
                color: AppColors.outline, fontSize: 12),
            textAlign: TextAlign.center),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  final Color bg;
  final Color accent;
  const _Category(this.label, this.icon, this.bg, this.accent);
}
