import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/provider_provider.dart';
import '../../widgets/provider_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../models/provider_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderProvider>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provState = context.watch<ProviderProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('DRAPO'),
        automaticallyImplyLeading: false,
      ),
      body: provState.isLoading
          ? const LoadingIndicator(message: 'Loading providers...')
          : RefreshIndicator(
              onRefresh: () => context.read<ProviderProvider>().loadHomeData(),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildGreeting(auth.userModel?.fullName ?? 'there'),
                  const SizedBox(height: 20),
                  _buildSearchBar(context),
                  const SizedBox(height: 24),
                  _buildSection(context, 'Top Doctors', provState.topDoctors),
                  const SizedBox(height: 20),
                  _buildSection(context, 'Top Pharmacies', provState.topPharmacies),
                ],
              ),
            ),
    );
  }

  Widget _buildGreeting(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Hello, $name 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Text('Find trusted healthcare providers', style: TextStyle(color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.search),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
        ),
        child: const Row(children: [
          Icon(Icons.search, color: AppColors.textSecondary),
          SizedBox(width: 10),
          Text('Search doctors, pharmacies...', style: TextStyle(color: AppColors.textSecondary)),
        ]),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<ProviderModel> list) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      const SizedBox(height: 10),
      if (list.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(children: [
            const Icon(Icons.search_off_rounded, size: 48, color: AppColors.divider),
            const SizedBox(height: 8),
            Text('No $title yet',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 4),
            const Text('Check back soon as providers are added.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center),
          ]),
        )
      else
        ...list.map((p) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ProviderCard(
            provider: p,
            onTap: () => Navigator.pushNamed(context, AppRoutes.providerProfile, arguments: p.providerId),
          ),
        )),
    ]);
  }
}
