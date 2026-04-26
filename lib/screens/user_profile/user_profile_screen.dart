import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../models/provider_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/provider_card.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ProviderModel> _bookmarkedProviders = [];
  bool _loadingBookmarks = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBookmarks());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    final user = context.read<AuthProvider>().userModel;
    if (user == null || user.bookmarks.isEmpty) {
      setState(() { _bookmarkedProviders = []; _loadingBookmarks = false; });
      return;
    }
    setState(() => _loadingBookmarks = true);
    final providers =
        await FirestoreService().getBookmarkedProviders(user.bookmarks);
    if (mounted) {
      setState(() {
        _bookmarkedProviders = providers;
        _loadingBookmarks = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: LoadingIndicator())
          : Column(
              children: [
                _buildProfileHeader(user.fullName, user.email, user.role),
                Container(
                  color: AppColors.surface,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: AppColors.primary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: const [
                      Tab(text: 'Saved Providers'),
                      Tab(text: 'Account Details'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookmarksTab(),
                      _buildAccountTab(user.fullName, user.email, user.role),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader(String name, String email, String role) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          _buildRoleBadge(role),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final (label, icon) = switch (role) {
      'provider' => ('Provider', Icons.medical_services_rounded),
      'admin' => ('Admin', Icons.admin_panel_settings_rounded),
      _ => ('Patient', Icons.person_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ]),
    );
  }

  Widget _buildBookmarksTab() {
    if (_loadingBookmarks) return const LoadingIndicator(message: 'Loading bookmarks...');

    if (_bookmarkedProviders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'No Saved Providers',
        subtitle: 'Providers you save will appear here for easy access',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookmarks,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 40),
        itemCount: _bookmarkedProviders.length,
        itemBuilder: (_, i) => ProviderCard(
          provider: _bookmarkedProviders[i],
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.providerProfile,
            arguments: _bookmarkedProviders[i].providerId,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTab(String name, String email, String role) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        _buildFormGroup([
          _buildInfoTile(Icons.person_rounded, 'Full Name', name),
          const Divider(height: 1, indent: 56),
          _buildInfoTile(Icons.email_rounded, 'Email Address', email),
          const Divider(height: 1, indent: 56),
          _buildInfoTile(Icons.badge_rounded, 'Account Type', role.capitalize()),
        ]),
        const SizedBox(height: 24),
        if (role == 'provider') ...[
          _buildFormGroup([
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.dashboard_rounded, color: AppColors.primary)),
              title: const Text('Provider Dashboard', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              subtitle: const Text('View your ratings & analytics', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              onTap: () => Navigator.pushNamed(context, AppRoutes.providerDashboard),
            ),
          ]),
          const SizedBox(height: 24),
        ],
        _buildFormGroup([
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.settings_rounded, color: AppColors.primary)),
            title: const Text('App Settings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ]),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildFormGroup(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.divider)),
            child: Icon(icon, size: 48, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5)),
        ]),
      ),
    );
  }
}

extension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
