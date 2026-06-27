import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'community/community_screen.dart';
import 'reviews/reviews_list_screen.dart';
import 'provider_dashboard/provider_dashboard_screen.dart';
import 'user_profile/user_profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isProvider = auth.userModel?.role == 'provider';

    // Two distinct experiences:
    //  - Provider: their own Dashboard (listing + incoming reviews) + Profile.
    //    No browsing, searching, reviewing, or bookmarking — those are patient
    //    actions and make no sense for the business being reviewed.
    //  - Patient: browse, search, read reviews, manage their profile.
    final List<Widget> screens = isProvider
        ? const [
            ProviderDashboardScreen(),
            UserProfileScreen(),
          ]
        : const [
            HomeScreen(),
            SearchScreen(),
            CommunityScreen(),
            ReviewsListScreen(),
            UserProfileScreen(),
          ];

    final List<BottomNavigationBarItem> navItems = isProvider
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ]
        : const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              activeIcon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups_rounded),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rate_review_outlined),
              activeIcon: Icon(Icons.rate_review_rounded),
              label: 'Reviews',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ];

    // Clamp index in case it exceeds the new screens list length
    // (e.g. user role changes dynamically after initial build).
    final safeIndex = _currentIndex.clamp(0, screens.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          border: Border(top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: BottomNavigationBar(
              currentIndex: safeIndex,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.outline.withValues(alpha: 0.8),
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              iconSize: 24,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, height: 1.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, height: 1.5),
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: navItems,
            ),
          ),
        ),
      ),
    );
  }
}
