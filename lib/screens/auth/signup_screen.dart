import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'patient';
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    // Clear any stale error from a previous attempt before trying again.
    context.read<AuthProvider>().clearError();
    final success = await context.read<AuthProvider>().signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      fullName: _nameCtrl.text.trim(),
      role: _role,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      final err = context.read<AuthProvider>().error ?? 'Sign up failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: AppTheme.subtleShadow,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Center(child: Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 32)),
                      Positioned(
                        bottom: -3, right: -3,
                        child: Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.starGold,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.star_rounded, color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Form card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: AppTheme.subtleShadow,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create account', style: GoogleFonts.manrope(
                          fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                        )),
                        const SizedBox(height: 4),
                        Text('Join DRAPO today', style: GoogleFonts.inter(
                          fontSize: 15, color: AppColors.textSecondary,
                        )),
                        const SizedBox(height: 28),
                        _label('FULL NAME'),
                        const SizedBox(height: 8),
                        AppTextField(
                          label: '', hint: 'Enter your full name',
                          controller: _nameCtrl, prefixIcon: Icons.person_outline,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Name is required';
                            if (v.trim().length < 2) return 'Please enter your full name';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _label('EMAIL'),
                        const SizedBox(height: 8),
                        AppTextField(
                          label: '', hint: 'Enter your email',
                          controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) return 'Enter a valid email address';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _label('PASSWORD'),
                        const SizedBox(height: 8),
                        AppTextField(
                          label: '', hint: 'Create a password',
                          controller: _passCtrl, obscureText: _obscure,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.outline),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _label('I AM A...'),
                        const SizedBox(height: 8),
                        // Segmented role selection
                        Row(children: [
                          _buildRoleChip('Patient', 'patient', Icons.person_rounded),
                          const SizedBox(width: 12),
                          _buildRoleChip('Provider', 'provider', Icons.medical_services_rounded),
                        ]),
                        const SizedBox(height: 28),
                        AppButton(label: 'Create Account', onPressed: _signup, isLoading: auth.isLoading),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Already have an account? ', style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 14,
                  )),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      child: Text('Log in', style: GoogleFonts.inter(
                        color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600,
                      )),
                    ),
                  ),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, letterSpacing: 0.8,
  ));

  Widget _buildRoleChip(String label, String value, IconData icon) {
    final selected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            )),
          ]),
        ),
      ),
    );
  }
}
