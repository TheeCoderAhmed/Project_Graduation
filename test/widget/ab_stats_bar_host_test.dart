// Widget tests for AbStatsBarHost
//
// Experiment: Stats Bar Visibility
//   Control (A)  → HomeStatsBar rendered
//   Treatment (B) → HomeStatsBar absent (SizedBox.shrink)
//
// Coverage:
//   - Control variant renders HomeStatsBar
//   - Treatment variant renders nothing (no HomeStatsBar, no stat text)
//   - Control passes live doctor/pharmacy data into the stats bar
//   - Switching from control to treatment removes the stats bar
//   - Switching from treatment to control reveals the stats bar

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drapo/models/provider_model.dart';
import 'package:drapo/services/ab_test_service.dart';
import 'package:drapo/widgets/ab_stats_bar_host.dart';
import 'package:drapo/screens/home/widgets/home_stats_bar.dart';

void _disableFonts() => GoogleFonts.config.allowRuntimeFetching = false;

ProviderModel _fakeProvider({int reviews = 0}) => ProviderModel(
      providerId: 'id',
      type: 'doctor',
      name: 'Dr. Test',
      specialty: 'General',
      address: 'Cairo',
      phone: '0000',
      totalReviews: reviews,
    );

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

AbStatsBarHost _host({
  required AbVariant variant,
  List<ProviderModel>? doctors,
  List<ProviderModel>? pharmacies,
}) =>
    AbStatsBarHost(
      variant: variant,
      doctors: doctors ?? [],
      pharmacies: pharmacies ?? [],
    );

void main() {
  setUpAll(_disableFonts);

  // ── Control variant ──────────────────────────────────────────────────────────

  group('AbStatsBarHost — control variant (A)', () {
    testWidgets('renders HomeStatsBar widget', (tester) async {
      await tester.pumpWidget(_wrap(_host(variant: AbVariant.control)));
      await tester.pumpAndSettle();

      expect(find.byType(HomeStatsBar), findsOneWidget);
    });

    testWidgets('passes doctor and pharmacy data into the stats bar', (tester) async {
      final doctors    = [_fakeProvider(), _fakeProvider()];     // 2 doctors
      final pharmacies = [_fakeProvider()];                       // 1 pharmacy

      await tester.pumpWidget(_wrap(
        _host(variant: AbVariant.control, doctors: doctors, pharmacies: pharmacies),
      ));
      await tester.pumpAndSettle();

      // Stats bar must show "2" for doctors and "1" for pharmacies
      expect(
        find.descendant(of: find.byType(HomeStatsBar), matching: find.text('2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(HomeStatsBar), matching: find.text('1')),
        findsOneWidget,
      );
    });
  });

  // ── Treatment variant ────────────────────────────────────────────────────────

  group('AbStatsBarHost — treatment variant (B)', () {
    testWidgets('does NOT render HomeStatsBar widget', (tester) async {
      await tester.pumpWidget(_wrap(_host(variant: AbVariant.treatment)));
      await tester.pumpAndSettle();

      expect(find.byType(HomeStatsBar), findsNothing);
    });

    testWidgets('does NOT render stat labels when in treatment', (tester) async {
      final doctors = [_fakeProvider(), _fakeProvider(), _fakeProvider()];

      await tester.pumpWidget(_wrap(
        _host(variant: AbVariant.treatment, doctors: doctors),
      ));
      await tester.pumpAndSettle();

      // No stats text should appear at all in the treatment arm
      expect(find.text('Doctors'),    findsNothing);
      expect(find.text('Pharmacies'), findsNothing);
      expect(find.text('Reviews'),    findsNothing);
    });
  });

  // ── Variant switching ────────────────────────────────────────────────────────

  group('AbStatsBarHost — variant switching', () {
    testWidgets('switching from control to treatment removes stats bar', (tester) async {
      // Start in control
      await tester.pumpWidget(_wrap(_host(variant: AbVariant.control)));
      await tester.pumpAndSettle();
      expect(find.byType(HomeStatsBar), findsOneWidget);

      // Switch to treatment
      await tester.pumpWidget(_wrap(_host(variant: AbVariant.treatment)));
      await tester.pumpAndSettle();
      expect(find.byType(HomeStatsBar), findsNothing);
    });

    testWidgets('switching from treatment to control reveals stats bar', (tester) async {
      // Start in treatment
      await tester.pumpWidget(_wrap(_host(variant: AbVariant.treatment)));
      await tester.pumpAndSettle();
      expect(find.byType(HomeStatsBar), findsNothing);

      // Switch to control
      await tester.pumpWidget(_wrap(_host(variant: AbVariant.control)));
      await tester.pumpAndSettle();
      expect(find.byType(HomeStatsBar), findsOneWidget);
    });
  });
}
