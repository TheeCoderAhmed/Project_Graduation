import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _kPushNotif   = 'pref_push_notifications';
  static const _kLanguage    = 'pref_language';

  bool _pushNotif    = true;
  String _language   = 'English';
  bool _prefsLoaded  = false;

  final List<String> _languages = ['English', 'Turkish', 'Arabic'];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotif   = prefs.getBool(_kPushNotif)   ?? true;
      _language    = prefs.getString(_kLanguage)  ?? 'English';
      _prefsLoaded = true;
    });
  }

  Future<void> _setPref(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) await prefs.setBool(key, value);
      if (value is String) await prefs.setString(key, value);
    } catch (_) {
      // SharedPreferences write failure is non-fatal — the UI already shows
      // the new value; it just won't survive a restart. Silently ignore.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
            child: Text('Manage your preferences and account',
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 24),

          _sectionHeader('PREFERENCES'),
          _buildFormGroup([
            _switchTile(
              icon: Icons.notifications_active_rounded,
              title: 'Push Notifications',
              subtitle: 'Get notified about your reviews',
              value: _pushNotif,
              onChanged: (v) {
                setState(() => _pushNotif = v);
                _setPref(_kPushNotif, v);
              },
            ),
            const Divider(height: 1, color: AppColors.divider),
            _languageTile(),
          ]),
          const SizedBox(height: 28),

          _sectionHeader('ACCOUNT'),
          _buildFormGroup([
            _navTile(
              icon: Icons.lock_reset_rounded,
              title: 'Reset Password',
              onTap: _sendResetPasswordEmail,
            ),
          ]),
          const SizedBox(height: 28),

          _sectionHeader('SUPPORT & INFO'),
          _buildFormGroup([
            _navTile(
              icon: Icons.bug_report_rounded,
              title: 'Report a Problem',
              onTap: () => _showInfoDialog('Report a Problem', 'Please email support@drapo.com with details.'),
            ),
            const Divider(height: 1, color: AppColors.divider),
            _navTile(
              icon: Icons.privacy_tip_rounded,
              title: 'Privacy Policy',
              onTap: () => _showInfoDialog('Privacy Policy', _privacyText),
            ),
          ]),
          const SizedBox(height: 32),

          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error.withValues(alpha: 0.08),
                  foregroundColor: AppColors.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: Text('Sign Out', style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w600,
                )),
                onPressed: _confirmSignOut,
              ),
            ),
          ),

          const SizedBox(height: 48),
          // Branding footer
          Center(
            child: Column(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: AppTheme.subtleShadow,
                ),
                child: const Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(height: 12),
              Text('DRAPO', style: GoogleFonts.manrope(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary,
              )),
              const SizedBox(height: 2),
              Text('Healthcare Review & Rating', style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.outline,
              )),
            ]),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildFormGroup(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(AppTheme.containerMargin + 4, 0, AppTheme.containerMargin, 10),
    child: Text(title, style: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w600,
      color: AppColors.outline, letterSpacing: 0.8,
    )),
  );

  Widget _switchTile({
    required IconData icon, required String title,
    required String subtitle, required bool value,
    required ValueChanged<bool> onChanged,
  }) => SwitchListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    secondary: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    ),
    title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
    subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppColors.outline)),
    value: value,
    onChanged: onChanged,
  );

  Widget _languageTile() => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: const Icon(Icons.language_rounded, color: AppColors.primary, size: 20),
    ),
    title: Text('Language', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
    trailing: DropdownButton<String>(
      value: _language,
      underline: const SizedBox(),
      icon: const Icon(Icons.expand_more_rounded, color: AppColors.outline),
      style: GoogleFonts.inter(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w600),
      items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
      onChanged: (v) {
        if (v != null) {
          setState(() => _language = v);
          _setPref(_kLanguage, v);
        }
      },
    ),
  );

  Widget _navTile({
    required IconData icon, required String title, VoidCallback? onTap,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    ),
    title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
    trailing: onTap != null ? const Icon(Icons.chevron_right_rounded, color: AppColors.outline) : null,
    onTap: onTap,
  );

  Future<void> _sendResetPasswordEmail() async {
    final auth = context.read<AuthProvider>();
    final email = auth.userModel?.email;
    if (email == null || email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email address found for your account.')),
      );
      return;
    }

    final msg = await auth.resetPassword(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: msg.contains('sent') ? AppColors.primary : AppColors.error,
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: Text('Sign Out', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to sign out?', style: GoogleFonts.inter(fontSize: 15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
            ),
            onPressed: () async {
              Navigator.pop(context); // close dialog first
              // Cache router before async gap.
              final navigator = Navigator.of(context);
              await context.read<AuthProvider>().signOut();
              // AuthProvider.signOut() swallows its own errors and clears
              // local state — safe to navigate unconditionally.
              navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(child: Text(content, style: GoogleFonts.inter(fontSize: 14, height: 1.5))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  static const String _privacyText = '''
DRAPO Privacy Policy — Last updated: 2024

1. Information We Collect
We collect your name, email, and healthcare reviews you submit. Usage data is collected anonymously to improve the app.

2. How We Use Your Data
Your data is used to provide the service, display your reviews, and calculate provider rankings.

3. Data Sharing
We do not sell personal data. Aggregated, anonymous data may be used for research.

4. Your Rights (KVKK)
Under Turkey's KVKK regulation, you may request access to, correction of, or deletion of your personal data by contacting privacy@drapo.com.

5. Security
All data is encrypted in transit and at rest using Firebase and industry-standard protocols.

Contact: privacy@drapo.com
''';
}
