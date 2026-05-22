// AbStatsBarHost — renders HomeStatsBar for the control variant,
// and an invisible SizedBox.shrink() for the treatment variant.
//
// Deliberately decoupled from AbTestService so it can be tested without
// any service mocking: just pass the variant directly in widget tests.
//
// Usage in HomeScreen:
//   AbStatsBarHost(
//     variant: AbTestService.assignVariant(userId),
//     doctors:   provState.topDoctors,
//     pharmacies: provState.topPharmacies,
//   ),

import 'package:flutter/material.dart';
import '../models/provider_model.dart';
import '../screens/home/widgets/home_stats_bar.dart';
import '../services/ab_test_service.dart';

class AbStatsBarHost extends StatelessWidget {
  final AbVariant variant;
  final List<ProviderModel> doctors;
  final List<ProviderModel> pharmacies;

  const AbStatsBarHost({
    super.key,
    required this.variant,
    required this.doctors,
    required this.pharmacies,
  });

  @override
  Widget build(BuildContext context) {
    // Treatment arm: stats bar is hidden — return nothing.
    if (variant == AbVariant.treatment) return const SizedBox.shrink();

    // Control arm: show the full stats bar.
    return HomeStatsBar(doctors: doctors, pharmacies: pharmacies);
  }
}
