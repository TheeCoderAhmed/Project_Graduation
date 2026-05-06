import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../models/review_model.dart';
import '../../models/questionnaire_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/star_rating_widget.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late String _providerId;
  bool _initialized = false;
  final _formKey = GlobalKey<FormState>();

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
      // Safely cast route argument — if it's missing (bad navigation,
      // deep link without args) pop immediately rather than crashing.
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is String && arg.isNotEmpty) {
        _providerId = arg;
        _initialized = true;
      } else {
        // Schedule pop after build completes — can't Navigator.pop in didChangeDependencies.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              // ignore: prefer_const_constructors
              SnackBar(
                // ignore: prefer_const_constructors
                content: Text(
                  'Could not open review form. Please try again.',
                ),
              ),
            );
            Navigator.pop(context);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Guard: provider ID must have been resolved from route args.
    if (!_initialized) return;

    final auth = context.read<AuthProvider>();
    if (auth.firebaseUser == null || auth.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to submit a review.')),
      );
      return;
    }

    // Rating floor — should always be ≥ 1 given RatingBar minRating:1,
    // but defend against any programmatic state corruption.
    if (_overallRating < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an overall star rating.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final comment = _commentController.text.trim();

    final review = ReviewModel(
      reviewId: '',
      providerId: _providerId,
      userId: auth.firebaseUser!.uid,
      userName: auth.userModel!.fullName,
      overallRating: _overallRating,
      comment: comment,
      questionnaire: QuestionnaireModel(
        waitingTime: _waitingTime,
        serviceQuality: _serviceQuality,
        hygiene: _hygiene,
        staffCommunication: _staffCommunication,
      ),
      createdAt: Timestamp.now(),
    );

    final result = await context.read<ReviewProvider>().submitReview(review);
    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully! Thank you.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              result.errorMessage ?? 'Submission failed. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<ReviewProvider>().isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tell us about your visit', style: GoogleFonts.manrope(
          fontSize: 18, fontWeight: FontWeight.w600,
        )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerMargin),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Overall Rating section
            Text('SERVICE QUALITY', style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary, letterSpacing: 0.8,
            )),
            const SizedBox(height: 12),
            _buildOverallRating(),
            const SizedBox(height: 28),
            // Experience details
            Text('EXPERIENCE DETAILS', style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary, letterSpacing: 0.8,
            )),
            const SizedBox(height: 12),
            _buildQuestionnaireCard(),
            const SizedBox(height: 28),
            // Comments
            Text('ADDITIONAL COMMENTS', style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary, letterSpacing: 0.8,
            )),
            const SizedBox(height: 12),
            _buildCommentField(),
            const SizedBox(height: 32),
            AppButton(
              label: 'Submit Review',
              icon: Icons.send_rounded,
              onPressed: isSubmitting ? null : _submit,
              isLoading: isSubmitting,
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.outline),
                  const SizedBox(width: 6),
                  Text('Your feedback is securely submitted and anonymized',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildOverallRating() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          StarRatingWidget(
            rating: _overallRating,
            size: 44,
            ignoreGestures: false,
            onRatingUpdate: (r) => setState(() => _overallRating = r),
          ),
          const SizedBox(height: 10),
          Text(
            _ratingLabel(_overallRating),
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionnaireCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _buildSliderRow('Waiting Time', Icons.access_time_rounded, _waitingTime,
              (v) => setState(() => _waitingTime = v)),
          const Divider(color: AppColors.divider, height: 24),
          _buildSliderRow('Service Quality', Icons.thumb_up_outlined, _serviceQuality,
              (v) => setState(() => _serviceQuality = v)),
          const Divider(color: AppColors.divider, height: 24),
          _buildSliderRow('Hygiene', Icons.cleaning_services_outlined, _hygiene,
              (v) => setState(() => _hygiene = v)),
          const Divider(color: AppColors.divider, height: 24),
          _buildSliderRow('Staff Communication', Icons.people_outline_rounded, _staffCommunication,
              (v) => setState(() => _staffCommunication = v)),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, IconData icon, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              value.toStringAsFixed(1),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ]),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 8,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Poor', style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
            Text('Excellent', style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentField() {
    return AppTextField(
      controller: _commentController,
      label: '',
      hint: 'Share your experience (min. 20 characters)...',
      maxLines: 5,
      maxLength: 500,
      helperText: 'Minimum 20 characters required',
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please add a comment before submitting.';
        }
        if (value.trim().length < 20) {
          return 'Your comment is too short. Please write at least 20 characters.';
        }
        return null;
      },
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
