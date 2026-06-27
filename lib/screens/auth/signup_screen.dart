import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/tc_kimlik.dart';
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
  // Provider listing fields (only used when role == 'provider').
  final _specialtyCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _tcCtrl = TextEditingController();
  final _fatherCtrl = TextEditingController();
  String _role = 'patient';
  String _providerType = 'doctor'; // doctor | pharmacy
  String? _gender; // male | female — doctors only
  bool _obscure = true;

  bool get _isProvider => _role == 'provider';
  bool get _isDoctor => _isProvider && _providerType == 'doctor';
  // Patients and individual doctors are people → collect gender + national ID.
  // Pharmacies are businesses → skip both.
  bool get _collectsIdentity => _role == 'patient' || _isDoctor;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    _specialtyCtrl.dispose(); _addressCtrl.dispose(); _phoneCtrl.dispose();
    _hospitalCtrl.dispose(); _departmentCtrl.dispose(); _roomCtrl.dispose();
    _tcCtrl.dispose(); _fatherCtrl.dispose();
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
      providerType: _isProvider ? _providerType : null,
      specialty: _isProvider ? _specialtyCtrl.text.trim() : null,
      address: _isProvider ? _addressCtrl.text.trim() : null,
      phone: _isProvider ? _phoneCtrl.text.trim() : null,
      gender: _collectsIdentity ? _gender : null,
      hospital: _isDoctor ? _hospitalCtrl.text.trim() : null,
      department: _isDoctor ? _departmentCtrl.text.trim() : null,
      room: _isDoctor ? _roomCtrl.text.trim() : null,
      tcKimlik: _collectsIdentity ? _tcCtrl.text.trim() : null,
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
                        _label("FATHER'S NAME"),
                        const SizedBox(height: 8),
                        AppTextField(
                          label: '', hint: 'Enter your father\'s name',
                          controller: _fatherCtrl,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Father\'s name is required';
                            if (v.trim().length < 2) return 'Please enter your father\'s name';
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
                        // Patients give gender + national ID (private, on their
                        // own user doc only).
                        if (_role == 'patient') ..._buildIdentityFields(),
                        // Provider-only listing fields — collected so the account
                        // is linked to a real listing the moment they sign up.
                        if (_isProvider) ..._buildProviderFields(),
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

  // Provider-only fields: type, optional gender (doctors), specialty, address, phone.
  List<Widget> _buildProviderFields() {
    final isDoctor = _providerType == 'doctor';
    return [
      const SizedBox(height: 20),
      _label('LISTING TYPE'),
      const SizedBox(height: 8),
      Row(children: [
        _buildSegment('Doctor', isDoctor, Icons.medical_services_rounded,
            () => setState(() => _providerType = 'doctor')),
        const SizedBox(width: 12),
        _buildSegment('Pharmacy', !isDoctor, Icons.local_pharmacy_rounded,
            () => setState(() => _providerType = 'pharmacy')),
      ]),
      if (isDoctor) ...[
        ..._genderSegments(),
        const SizedBox(height: 20),
        _label('HOSPITAL / CLINIC'),
        const SizedBox(height: 8),
        AppTextField(
          label: '',
          hint: 'e.g. Acıbadem Hospital',
          controller: _hospitalCtrl,
          prefixIcon: Icons.local_hospital_outlined,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Hospital is required' : null,
        ),
        const SizedBox(height: 20),
        _label('DEPARTMENT'),
        const SizedBox(height: 8),
        AppTextField(
          label: '',
          hint: 'e.g. Cardiology',
          controller: _departmentCtrl,
          prefixIcon: Icons.account_tree_outlined,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Department is required' : null,
        ),
        const SizedBox(height: 20),
        _label('ROOM / OFFICE NO. (OPTIONAL)'),
        const SizedBox(height: 8),
        AppTextField(
          label: '',
          hint: 'e.g. Room 204',
          controller: _roomCtrl,
          prefixIcon: Icons.meeting_room_outlined,
        ),
        const SizedBox(height: 20),
        _tcField(),
      ],
      const SizedBox(height: 20),
      _label('SPECIALTY'),
      const SizedBox(height: 8),
      AppTextField(
        label: '',
        hint: isDoctor ? 'e.g. Cardiologist' : 'e.g. Community Pharmacy',
        controller: _specialtyCtrl,
        prefixIcon: Icons.badge_outlined,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Specialty is required' : null,
      ),
      const SizedBox(height: 20),
      _label('ADDRESS / CITY'),
      const SizedBox(height: 8),
      AppTextField(
        label: '',
        hint: 'e.g. Çankaya, Ankara',
        controller: _addressCtrl,
        prefixIcon: Icons.location_on_outlined,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Address is required' : null,
      ),
      const SizedBox(height: 20),
      _label('PHONE'),
      const SizedBox(height: 8),
      AppTextField(
        label: '',
        hint: 'e.g. +90 312 000 0000',
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        prefixIcon: Icons.phone_outlined,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
      ),
    ];
  }

  // Gender + national ID, shared by patients and individual doctors.
  List<Widget> _buildIdentityFields() {
    return [
      ..._genderSegments(),
      const SizedBox(height: 20),
      _tcField(),
    ];
  }

  List<Widget> _genderSegments() {
    return [
      const SizedBox(height: 20),
      _label('GENDER'),
      const SizedBox(height: 8),
      Row(children: [
        _buildSegment('Female', _gender == 'female', Icons.woman_rounded,
            () => setState(() => _gender = 'female')),
        const SizedBox(width: 12),
        _buildSegment('Male', _gender == 'male', Icons.man_rounded,
            () => setState(() => _gender = 'male')),
      ]),
    ];
  }

  Widget _tcField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('T.C. KİMLİK NO'),
        const SizedBox(height: 8),
        AppTextField(
          label: '',
          hint: '11-digit national ID',
          controller: _tcCtrl,
          keyboardType: TextInputType.number,
          maxLength: 11,
          prefixIcon: Icons.badge_outlined,
          helperText: 'Private — visible only to you.',
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'T.C. Kimlik No is required';
            if (!TcKimlik.isValid(v.trim())) return 'Enter a valid 11-digit T.C. Kimlik No';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSegment(String label, bool selected, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
