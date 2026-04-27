import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_theme.dart';
import '../../models/provider_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/provider_provider.dart';
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

    // Resolve bookmarks from seed data by ID — instant, no network.
    final providerProvider = context.read<ProviderProvider>();
    final providers = user.bookmarks
        .map((id) => providerProvider.getById(id))
        .whereType<ProviderModel>()
        .toList();

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
      body: user == null
          ? const Center(child: LoadingIndicator())
          : NestedScrollView(
              headerSliverBuilder: (_, __) => [
                SliverToBoxAdapter(child: _buildProfileHeader(user.fullName, user.email, user.role)),
              ],
              body: Column(
                children: [
                  // Tab bar
                  Container(
                    color: AppColors.surface,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelColor: AppColors.primary,
                      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                      unselectedLabelColor: AppColors.outline,
                      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
                      dividerColor: AppColors.divider,
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
            ),
    );
  }

  Widget _buildProfileHeader(String name, String email, String role) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(AppTheme.containerMargin, MediaQuery.of(context).padding.top + 16, AppTheme.containerMargin, 28),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Column(
        children: [
          // Top bar with settings icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profile', style: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,
              )),
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Avatar
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Text(name, style: GoogleFonts.manrope(
            fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white,
          )),
          const SizedBox(height: 4),
          Text(email, style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 14,
          )),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        )),
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
      color: AppColors.primary,
      onRefresh: _loadBookmarks,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 100),
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
          const Divider(height: 1, color: AppColors.divider, indent: 56),
          _buildInfoTile(Icons.email_rounded, 'Email Address', email),
          const Divider(height: 1, color: AppColors.divider, indent: 56),
          _buildInfoTile(Icons.badge_rounded, 'Account Type', role._capitalize()),
        ]),
        const SizedBox(height: 24),
        if (role == 'provider') ...[
          _buildFormGroup([
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(Icons.dashboard_rounded, color: AppColors.secondary, size: 20),
              ),
              title: Text('Provider Dashboard', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: Text('View your ratings & analytics', style: GoogleFonts.inter(fontSize: 13, color: AppColors.outline)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
              onTap: () => Navigator.pushNamed(context, AppRoutes.providerDashboard),
            ),
          ]),
          const SizedBox(height: 24),
        ],
        const SizedBox(height: 100),
      ],
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

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
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
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: Icon(icon, size: 44, color: AppColors.outline),
          ),
          const SizedBox(height: 24),
          Text(title, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.inter(
            color: AppColors.textSecondary, fontSize: 14, height: 1.5,
          )),
        ]),
      ),
    );
  }
}

extension on String {
  String _capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
