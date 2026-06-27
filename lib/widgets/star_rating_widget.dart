import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../constants/app_colors.dart';

class StarRatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final bool ignoreGestures;
  final ValueChanged<double>? onRatingUpdate;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.size = 14.0,
    this.ignoreGestures = true,
    this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: size,
      ignoreGestures: ignoreGestures,
      unratedColor: AppColors.divider,
      itemBuilder: (context, _) => const Icon(
        Icons.star_rounded,
        color: AppColors.starGold,
      ),
      onRatingUpdate: onRatingUpdate ?? (_) {},
    );
  }
}
