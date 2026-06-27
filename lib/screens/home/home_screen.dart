import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/provider_provider.dart';
import '../../services/ab_test_service.dart';
import '../../widgets/ab_stats_bar_host.dart';
import '../../widgets/common/loading_indicator.dart';
import 'widgets/home_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_quick_categories.dart';
import 'widgets/home_provider_section.dart';

// Home tab — the app's main landing screen.
// Loads provider data on first render and supports pull-to-refresh.
// Layout is built from focused sub-widgets in the widgets/ folder:
//   HomeHeader            → gradient banner with greeting
//   HomeSearchBar         → tappable fake search bar
//   HomeQuickCategories   → specialty chip row
//   HomeStatsBar          → doctors / pharmacies / reviews counts
//   HomeProviderSection   → titled provider list (horizontal or vertical)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load providers after the first frame so BuildContext is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderProvider>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provState = context.watch<ProviderProvider>();

    // A/B test: assign variant based on logged-in user ID.
    // Falls back to 'anonymous' when no user is signed in.
    final userId = auth.userModel?.uid ?? 'anonymous';
    final abVariant = AbTestService.assignVariant(userId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: provState.isLoading
          ? const LoadingIndicator(message: 'Loading providers...')
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  context.read<ProviderProvider>().loadHomeData(showLoading: false),
              child: ListView(
                padding: const EdgeInsets.only(top: 0, bottom: 100),
                children: [
                  HomeHeader(name: auth.userModel?.fullName ?? 'there'),
                  const SizedBox(height: 20),
                  const HomeSearchBar(),
                  const SizedBox(height: 24),
                  const HomeQuickCategories(),
                  const SizedBox(height: 28),
                  // A/B experiment: control sees stats bar, treatment does not.
                  AbStatsBarHost(
                    variant: abVariant,
                    doctors: provState.topDoctors,
                    pharmacies: provState.topPharmacies,
                  ),
                  const SizedBox(height: 28),
                  HomeProviderSection(
                    title: 'Top Rated Doctors',
                    list: provState.topDoctors,
                    horizontal: true,
                    onRetry: () => context.read<ProviderProvider>().loadHomeData(),
                  ),
                  const SizedBox(height: 28),
                  HomeProviderSection(
                    title: 'Pharmacies Near Me',
                    list: provState.topPharmacies,
                    onRetry: () => context.read<ProviderProvider>().loadHomeData(),
                  ),
                ],
              ),
            ),
    );
  }
}
