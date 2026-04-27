import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/provider_model.dart';

class ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback onTap;

  const ProviderCard({super.key, required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: provider.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: provider.photoUrl!,
                          width: 60, height: 60, fit: BoxFit.cover,
                          placeholder: (_, __) => _PlaceholderAvatar(type: provider.type),
                          errorWidget: (_, __, ___) => _PlaceholderAvatar(type: provider.type),
                        )
                      : _PlaceholderAvatar(type: provider.type),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.name,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(provider.specialty,
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        // Gold rating badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryFixed,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.star_rounded, color: AppColors.tertiary, size: 14),
                            const SizedBox(width: 3),
                            Text(provider.averageRating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.tertiary,
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(width: 8),
                        Text('${provider.totalReviews} reviews',
                          style: GoogleFonts.inter(
                            color: AppColors.outline,
                            fontSize: 13,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.outline, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderAvatar extends StatelessWidget {
  final String type;
  const _PlaceholderAvatar({required this.type});
  @override
  Widget build(BuildContext context) {
    final icon = type == 'pharmacy'
        ? Icons.local_pharmacy_rounded
        : Icons.local_hospital_rounded;
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Icon(icon, color: AppColors.primary, size: 28),
    );
  }
}
