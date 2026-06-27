import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../models/questionnaire_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/star_rating_widget.dart';

/// Form for reviewing a doctor who isn't listed on DRAPO. Captures the
/// doctor's identity (name, hospital, department, specialty) plus the same
/// rating + questionnaire used for in-app providers.
class AddCommunityReviewScreen extends StatefulWidget {
  const AddCommunityReviewScreen({super.key});

  @override
  State<AddCommunityReviewScreen> createState() =>
      _AddCommunityReviewScreenState();
}

class _AddCommunityReviewScreenState extends State<AddCommunityReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();

  double _overall = 3.0;
  double _wait = 3.0;
  double _service = 3.0;
  double _hygiene = 3.0;
  double _staff = 3.0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hospitalCtrl.dispose();
    _deptCtrl.dispose();
    _specialtyCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    if (auth.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to submit.')),
      );
      return;
    }

    final error = await context.read<CommunityProvider>().submitReview(
          userId: auth.userModel!.uid,
          userName: auth.userModel!.fullName,
          doctorName: _nameCtrl.text.trim(),
          hospital: _hospitalCtrl.text.trim(),
          department: _deptCtrl.text.trim(),
          specialty: _specialtyCtrl.text.trim(),
          overallRating: _overall,
          comment: _commentCtrl.text.trim(),
          questionnaire: QuestionnaireModel(
            waitingTime: _wait,
            serviceQuality: _service,
            hygiene: _hygiene,
            staffCommunication: _staff,
          ),
        );

    if (!mounted) return;
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted. Thank you!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<CommunityProvider>().isSubmitting;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Review a doctor',
            style: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerMargin),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('DOCTOR DETAILS'),
              const SizedBox(height: 12),
              AppTextField(
                label: '',
                hint: 'Doctor\'s full name',
                controller: _nameCtrl,
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? 'Enter the doctor\'s name' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: '',
                hint: 'Hospital / clinic',
                controller: _hospitalCtrl,
                prefixIcon: Icons.local_hospital_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Hospital is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: '',
                hint: 'Department (e.g. Cardiology)',
                controller: _deptCtrl,
                prefixIcon: Icons.account_tree_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Department is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: '',
                hint: 'Specialty (e.g. Cardiologist)',
                controller: _specialtyCtrl,
                prefixIcon: Icons.badge_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Specialty is required' : null,
              ),
              const SizedBox(height: 28),
              _section('OVERALL RATING'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Center(
                  child: StarRatingWidget(
                    rating: _overall,
                    size: 44,
                    ignoreGestures: false,
                    onRatingUpdate: (r) => setState(() => _overall = r),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _section('EXPERIENCE DETAILS'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(children: [
                  _slider('Waiting Time', Icons.access_time_rounded, _wait,
                      (v) => setState(() => _wait = v)),
                  const Divider(color: AppColors.divider, height: 24),
                  _slider('Service Quality', Icons.thumb_up_outlined, _service,
                      (v) => setState(() => _service = v)),
                  const Divider(color: AppColors.divider, height: 24),
                  _slider('Hygiene', Icons.cleaning_services_outlined, _hygiene,
                      (v) => setState(() => _hygiene = v)),
                  const Divider(color: AppColors.divider, height: 24),
                  _slider('Staff Communication', Icons.people_outline_rounded,
                      _staff, (v) => setState(() => _staff = v)),
                ]),
              ),
              const SizedBox(height: 28),
              _section('COMMENT'),
              const SizedBox(height: 12),
              AppTextField(
                controller: _commentCtrl,
                label: '',
                hint: 'Share your experience (min. 20 characters)...',
                maxLines: 5,
                maxLength: 500,
                helperText: 'Minimum 20 characters required',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please add a comment before submitting.';
                  }
                  if (v.trim().length < 20) {
                    return 'Your comment is too short. Please write at least 20 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Submit Review',
                icon: Icons.send_rounded,
                onPressed: isSubmitting ? null : _submit,
                isLoading: isSubmitting,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String text) => Text(text,
      style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.8));

  Widget _slider(String label, IconData icon, double value,
      ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(value.toStringAsFixed(1),
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 8,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
