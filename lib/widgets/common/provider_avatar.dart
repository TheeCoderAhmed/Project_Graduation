import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../models/provider_model.dart';

/// Avatar for a provider.
///
/// Order of preference:
///  1. Real uploaded photo (`photoUrl`)
///  2. Generated, deterministic avatar based on type + gender:
///     - pharmacy  → pharmacy glyph on teal
///     - doctor    → gender glyph (woman/man/neutral) on a gender-tinted circle
///
/// No real faces are used — the generated form is a clean, offline-safe glyph
/// so it always renders during a demo even with no network.
class ProviderAvatar extends StatelessWidget {
  final ProviderModel provider;
  final double size;

  const ProviderAvatar({super.key, required this.provider, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final url = provider.photoUrl;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _generated(),
          errorWidget: (_, __, ___) => _generated(),
        ),
      );
    }
    return _generated();
  }

  Widget _generated() {
    final isPharmacy = provider.type == 'pharmacy';
    final (bg, fg, icon) = _style(isPharmacy, provider.gender);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: size * 0.5),
    );
  }

  (Color, Color, IconData) _style(bool isPharmacy, String? gender) {
    if (isPharmacy) {
      return (
        AppColors.secondary.withValues(alpha: 0.12),
        AppColors.secondary,
        Icons.local_pharmacy_rounded,
      );
    }
    switch (gender) {
      case 'female':
        return (const Color(0xFFFCE4EC), const Color(0xFFC2185B), Icons.woman_rounded);
      case 'male':
        return (const Color(0xFFE3F2FD), const Color(0xFF1565C0), Icons.man_rounded);
      default:
        return (
          AppColors.primary.withValues(alpha: 0.10),
          AppColors.primary,
          Icons.local_hospital_rounded,
        );
    }
  }
}
