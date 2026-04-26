import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/review_model.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20), // Generous, uniform padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceContainer,
                  child: Text(
                    review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        review.createdAt != null
                            ? DateFormat('MMM d, yyyy')
                                .format(review.createdAt!.toDate())
                            : 'Just now',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    const Icon(Icons.star_rounded, color: AppColors.accent, size: 18),
                    const SizedBox(width: 4),
                    Text(review.overallRating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ]),
                ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(review.comment,
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5)),
            ],
            if (review.questionnaire.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildQRow('Wait Time', review.questionnaire['waitingTime'] ?? 0),
              _buildQRow('Service', review.questionnaire['serviceQuality'] ?? 0),
              _buildQRow('Hygiene', review.questionnaire['hygiene'] ?? 0),
              _buildQRow('Staff', review.questionnaire['staffCommunication'] ?? 0),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          Row(
            children: List.generate(5, (i) => Icon(
              i < value.round() ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 16, color: i < value.round() ? AppColors.accent : AppColors.divider,
            )),
          ),
        ],
      ),
    );
  }
}
