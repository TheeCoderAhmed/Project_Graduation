import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/review_model.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar — safely extracts first character, falls back to '?'
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                child: Text(
                  _avatarInitial(review.userName),
                  style: GoogleFonts.manrope(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName.isNotEmpty ? review.userName : 'Anonymous',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.createdAt != null
                          ? DateFormat('MMM d, yyyy')
                              .format(review.createdAt!.toDate())
                          : 'Just now',
                      style: GoogleFonts.inter(
                        color: AppColors.outline,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Gold rating badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryFixed,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.tertiary, size: 16),
                  const SizedBox(width: 3),
                  Text(
                    review.overallRating.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.tertiary,
                    ),
                  ),
                ]),
              ),
              if (review.isVerified) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Verified Patient',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_rounded,
                        color: AppColors.secondary, size: 16),
                  ),
                ),
              ],
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              review.comment,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ],
          if (review.questionnaire.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 8),
            _buildQRow('Wait Time',
                review.questionnaire['waitingTime'] ?? 0.0),
            _buildQRow('Service',
                review.questionnaire['serviceQuality'] ?? 0.0),
            _buildQRow(
                'Hygiene', review.questionnaire['hygiene'] ?? 0.0),
            _buildQRow('Staff',
                review.questionnaire['staffCommunication'] ?? 0.0),
          ],
        ],
      ),
    );
  }

  /// Safely extracts the first visible character for the avatar.
  /// Never throws on empty string or unusual Unicode.
  String _avatarInitial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    // characters package not assumed — use runes for Unicode safety.
    final first = trimmed.runes.first;
    return String.fromCharCode(first).toUpperCase();
  }

  Widget _buildQRow(String label, double rawValue) {
    // Clamp value to 0–5 so star rendering is always safe even if a
    // corrupt Firestore document slips through fromMap's own clamping.
    final value = rawValue.clamp(0.0, 5.0);
    final filledCount = value.round().clamp(0, 5);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < filledCount
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 16,
                color: i < filledCount
                    ? AppColors.starGold
                    : AppColors.divider,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
