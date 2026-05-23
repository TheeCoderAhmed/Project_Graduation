import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_theme.dart';
import '../../models/community_doctor_model.dart';
import '../../providers/community_provider.dart';
import '../../widgets/common/loading_indicator.dart';

/// Browsable list of off-app doctors that patients have reviewed. Searchable
/// by name, hospital, or department. The FAB opens the "review a doctor" form.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().loadDoctors();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityProvider>();
    final doctors = community.filteredDoctors;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.addCommunityReview),
        icon: const Icon(Icons.rate_review_rounded),
        label: const Text('Review a doctor'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.containerMargin),
              child: Text('Community Reviews',
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.containerMargin),
              child: Text('Doctors reviewed by patients, not yet on DRAPO',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.containerMargin),
              child: TextField(
                controller: _searchCtrl,
                style: GoogleFonts.inter(
                    fontSize: 15, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search name, hospital, or department...',
                  hintStyle: GoogleFonts.inter(
                      color: AppColors.outline, fontSize: 15),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: AppColors.outline),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: AppColors.outline),
                          onPressed: () {
                            _searchCtrl.clear();
                            context.read<CommunityProvider>().setQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onChanged: (v) {
                  setState(() {});
                  context.read<CommunityProvider>().setQuery(v);
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: community.isLoading
                  ? const LoadingIndicator()
                  : doctors.isEmpty
                      ? _buildEmpty(community.query.isNotEmpty)
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () =>
                              context.read<CommunityProvider>().loadDoctors(),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 100),
                            itemCount: doctors.length,
                            itemBuilder: (_, i) => _DoctorCard(
                              doctor: doctors[i],
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.communityDoctor,
                                arguments: doctors[i],
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isSearch) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSearch ? Icons.search_off_rounded : Icons.groups_outlined,
                size: 64, color: AppColors.divider),
            const SizedBox(height: 16),
            Text(
              isSearch ? 'No doctors match your search' : 'No community reviews yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isSearch
                  ? 'Try a different name or hospital'
                  : 'Be the first to review a doctor who isn\'t on DRAPO yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final CommunityDoctorModel doctor;
  final VoidCallback onTap;
  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.containerMargin, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      [doctor.specialty, doctor.department]
                          .where((s) => s.isNotEmpty)
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.local_hospital_outlined,
                          size: 13, color: AppColors.outline),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(doctor.hospital,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.outline)),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryFixed,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.tertiary, size: 15),
                      const SizedBox(width: 3),
                      Text(doctor.averageRating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.tertiary)),
                    ]),
                  ),
                  const SizedBox(height: 4),
                  Text('${doctor.totalReviews} review${doctor.totalReviews == 1 ? '' : 's'}',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.outline)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
