import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../widgets/common/app_button.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late String _providerId;
  bool _initialized = false;

  double _overallRating = 3.0;
  double _waitingTime = 3.0;
  double _serviceQuality = 3.0;
  double _hygiene = 3.0;
  double _staffCommunication = 3.0;
  final _commentController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _providerId = ModalRoute.of(context)!.settings.arguments as String;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (auth.firebaseUser == null || auth.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to submit a review.')),
      );
      return;
    }

    final review = ReviewModel(
      reviewId: '',
      providerId: _providerId,
      userId: auth.firebaseUser!.uid,
      userName: auth.userModel!.fullName,
      overallRating: _overallRating,
      comment: _commentController.text.trim(),
      questionnaire: {
        'waitingTime': _waitingTime,
        'serviceQuality': _serviceQuality,
        'hygiene': _hygiene,
        'staffCommunication': _staffCommunication,
      },
      createdAt: Timestamp.now(),
    );

    try {
      await context.read<ReviewProvider>().submitReview(review);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully! Thank you.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<ReviewProvider>().isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Overall Rating', Icons.star_rate_rounded),
                  const SizedBox(height: 12),
                  _buildOverallRating(),
                  const SizedBox(height: 28),
                  _buildSectionHeader('Experience Details', Icons.checklist_rounded),
                  const SizedBox(height: 12),
                  _buildQuestionnaireCard(),
                  const SizedBox(height: 28),
                  _buildSectionHeader('Your Comments', Icons.comment_outlined),
                  const SizedBox(height: 12),
                  _buildCommentField(),
                  const SizedBox(height: 32),
                  AppButton(
                    label: 'Submit Review',
                    icon: Icons.send_rounded,
                    onPressed: isSubmitting ? null : _submit,
                    isLoading: isSubmitting,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOverallRating() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          RatingBar.builder(
            initialRating: _overallRating,
            minRating: 1,
            itemCount: 5,
            itemSize: 44,
            glow: true,
            glowColor: AppColors.accent.withValues(alpha: 0.3),
            itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppColors.accent),
            onRatingUpdate: (r) => setState(() => _overallRating = r),
          ),
          const SizedBox(height: 8),
          Text(
            _ratingLabel(_overallRating),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionnaireCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildSliderRow('Waiting Time', Icons.access_time_rounded, _waitingTime,
              (v) => setState(() => _waitingTime = v)),
          _buildDivider(),
          _buildSliderRow('Service Quality', Icons.thumb_up_outlined, _serviceQuality,
              (v) => setState(() => _serviceQuality = v)),
          _buildDivider(),
          _buildSliderRow('Hygiene', Icons.cleaning_services_outlined, _hygiene,
              (v) => setState(() => _hygiene = v)),
          _buildDivider(),
          _buildSliderRow('Staff Communication', Icons.people_outline_rounded, _staffCommunication,
              (v) => setState(() => _staffCommunication = v)),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, IconData icon, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                value.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ]),
          Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 8,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.divider,
            onChanged: onChanged,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Poor', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text('Excellent', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, thickness: 1, color: AppColors.divider);

  Widget _buildCommentField() {
    return TextField(
      controller: _commentController,
      maxLines: 5,
      maxLength: 500,
      decoration: InputDecoration(
        hintText: 'Share your experience with this provider...',
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  String _ratingLabel(double rating) {
    if (rating <= 1) return 'Very Poor';
    if (rating <= 2) return 'Poor';
    if (rating <= 3) return 'Average';
    if (rating <= 4) return 'Good';
    return 'Excellent';
  }
}
