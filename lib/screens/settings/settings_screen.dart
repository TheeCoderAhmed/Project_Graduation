import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _kPushNotif   = 'pref_push_notifications';
  static const _kEmailNotif  = 'pref_email_notifications';
  static const _kLanguage    = 'pref_language';

  bool _pushNotif    = true;
  bool _emailNotif   = true;
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
      _emailNotif  = prefs.getBool(_kEmailNotif)  ?? true;
      _language    = prefs.getString(_kLanguage)  ?? 'English';
      _prefsLoaded = true;
    });
  }

  Future<void> _setPref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool)   prefs.setBool(key, value);
    if (value is String) prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _sectionHeader('Notifications'),
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
            const Divider(height: 1),
            _switchTile(
              icon: Icons.email_rounded,
              title: 'Email Notifications',
              subtitle: 'Receive updates via email',
              value: _emailNotif,
              onChanged: (v) {
                setState(() => _emailNotif = v);
                _setPref(_kEmailNotif, v);
              },
            ),
          ]),
          const SizedBox(height: 24),

          _sectionHeader('Preferences'),
          _buildFormGroup([
            _languageTile(),
          ]),
          const SizedBox(height: 24),

          _sectionHeader('About'),
          _buildFormGroup([
            _navTile(
              icon: Icons.privacy_tip_rounded,
              title: 'Privacy Policy',
              onTap: () => _showInfoDialog('Privacy Policy', _privacyText),
            ),
            const Divider(height: 1),
            _navTile(
              icon: Icons.description_rounded,
              title: 'Terms of Service',
              onTap: () => _showInfoDialog('Terms of Service', _termsText),
            ),
            const Divider(height: 1),
            _navTile(
              icon: Icons.info_rounded,
              title: 'App Version',
              trailing: const Text('v1.0.0', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
              onTap: null,
            ),
          ]),
          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withValues(alpha: 0.1),
                foregroundColor: AppColors.error,
                elevation: 0,
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              onPressed: _confirmSignOut,
            ),
          ),

          const SizedBox(height: 48),
          const Center(
            child: Column(children: [
              Icon(Icons.favorite_rounded, color: AppColors.primary, size: 36),
              SizedBox(height: 12),
              Text('DRAPO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1.5)),
              SizedBox(height: 4),
              Text('Healthcare Review & Rating', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ]),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ── WIDGETS ────────────────────────────────────────────────────────────

  Widget _buildFormGroup(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
    child: Text(title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
            color: AppColors.textSecondary, letterSpacing: 1.2)),
  );

  Widget _switchTile({
    required IconData icon, required String title,
    required String subtitle, required bool value,
    required ValueChanged<bool> onChanged,
  }) => SwitchListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    secondary: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: AppColors.primary, size: 22)
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    value: value,
    activeThumbColor: AppColors.primary,
    onChanged: onChanged,
  );

  Widget _languageTile() => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.language_rounded, color: AppColors.primary, size: 22)
    ),
    title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
    trailing: DropdownButton<String>(
      value: _language,
      underline: const SizedBox(),
      icon: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
      style: const TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w600),
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
    required IconData icon, required String title,
    Color? titleColor, Color? iconColor,
    Widget? trailing, VoidCallback? onTap,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22)
    ),
    title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: titleColor ?? AppColors.textPrimary)),
    trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary) : null),
    onTap: onTap,
  );

  // ── DIALOGS ─────────────────────────────────────────────────────────────

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(fontSize: 15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(child: Text(content, style: const TextStyle(fontSize: 14, height: 1.5))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  // ── STATIC CONTENT ──────────────────────────────────────────────────────

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

  static const String _termsText = '''
DRAPO Terms of Service — Last updated: 2024

1. Eligibility
You must be 18 or older to use this service.

2. Reviews Policy
All reviews must reflect genuine personal experiences. False or misleading reviews are prohibited and may result in account termination.

3. Acceptable Use
Do not use DRAPO for illegal purposes, harassment, or spreading misinformation about healthcare providers.

4. Medical Disclaimer
Reviews are user opinions only. Always consult a qualified medical professional for health decisions.

5. Liability
DRAPO is not liable for any medical decisions made based on content on this platform.

Contact: support@drapo.com
''';
}
