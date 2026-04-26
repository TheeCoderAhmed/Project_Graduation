import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../models/provider_model.dart';

class ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback onTap;

  const ProviderCard({super.key, required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16), // Generous padding
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12), // Softer radius
                child: provider.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: provider.photoUrl!,
                        width: 64, height: 64, fit: BoxFit.cover,
                        placeholder: (_, __) => _PlaceholderAvatar(type: provider.type),
                        errorWidget: (_, __, ___) => _PlaceholderAvatar(type: provider.type),
                      )
                    : _PlaceholderAvatar(type: provider.type),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(provider.specialty,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: AppColors.accent, size: 18),
                      const SizedBox(width: 4),
                      Text(provider.averageRating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                      const SizedBox(width: 6),
                      Text('(${provider.totalReviews} reviews)',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                    ]),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 24),
            ],
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
      width: 64, height: 64,
      color: AppColors.surfaceContainer,
      child: Icon(icon, color: AppColors.primary, size: 32),
    );
  }
}
