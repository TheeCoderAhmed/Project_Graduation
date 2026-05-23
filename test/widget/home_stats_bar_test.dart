// Widget tests for HomeStatsBar
//
// Coverage:
//   - All three column labels rendered
//   - Doctor, pharmacy, and review counts show correct values
//   - Large review counts formatted as "X.Xk" above 1000
//   - Boundary: exactly 1000 formats as "1.0k"; 999 stays "999"

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drapo/models/provider_model.dart';
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

// Helper to find a text widget that is a descendant of HomeStatsBar.
// Prevents false positives from Text widgets outside the stats bar.
Finder _statText(String value) => find.descendant(
      of: find.byType(HomeStatsBar),
      matching: find.text(value),
    );

void main() {
  setUpAll(_disableFonts);

  // ── Labels ──────────────────────────────────────────────────────────────────

  group('HomeStatsBar — column labels', () {
    testWidgets('renders Doctors label', (tester) async {
      await tester.pumpWidget(_wrap(const HomeStatsBar(doctors: [], pharmacies: [])));
      await tester.pumpAndSettle();

      expect(_statText('Doctors'), findsOneWidget);
    });

    testWidgets('renders Pharmacies label', (tester) async {
      await tester.pumpWidget(_wrap(const HomeStatsBar(doctors: [], pharmacies: [])));
      await tester.pumpAndSettle();

      expect(_statText('Pharmacies'), findsOneWidget);
    });

    testWidgets('renders Reviews label', (tester) async {
      await tester.pumpWidget(_wrap(const HomeStatsBar(doctors: [], pharmacies: [])));
      await tester.pumpAndSettle();

      expect(_statText('Reviews'), findsOneWidget);
    });
  });

  // ── Counts ──────────────────────────────────────────────────────────────────

  group('HomeStatsBar — counts', () {
    testWidgets('shows 0 for all columns when both lists are empty', (tester) async {
      await tester.pumpWidget(_wrap(const HomeStatsBar(doctors: [], pharmacies: [])));
      await tester.pumpAndSettle();

      // Three separate "0" stat values — one per column
      expect(_statText('0'), findsNWidgets(3));
    });

    testWidgets('shows correct doctor count', (tester) async {
      final doctors = [_fakeProvider(), _fakeProvider(), _fakeProvider()];
      await tester.pumpWidget(_wrap(HomeStatsBar(doctors: doctors, pharmacies: const [])));
      await tester.pumpAndSettle();

      expect(_statText('3'), findsOneWidget);
    });

    testWidgets('shows correct pharmacy count', (tester) async {
      final pharmacies = [_fakeProvider(), _fakeProvider()];
      await tester.pumpWidget(_wrap(HomeStatsBar(doctors: const [], pharmacies: pharmacies)));
      await tester.pumpAndSettle();

      expect(_statText('2'), findsOneWidget);
    });

    testWidgets('sums reviews from doctors and pharmacies', (tester) async {
      final doctors = [_fakeProvider(reviews: 10), _fakeProvider(reviews: 20)];
      final pharmacies = [_fakeProvider(reviews: 5)];
      await tester.pumpWidget(_wrap(HomeStatsBar(doctors: doctors, pharmacies: pharmacies)));
      await tester.pumpAndSettle();

      // 10 + 20 + 5 = 35
      expect(_statText('35'), findsOneWidget);
    });

    testWidgets('doctor and pharmacy counts are independent', (tester) async {
      final doctors = [_fakeProvider(), _fakeProvider()];       // 2
      final pharmacies = [_fakeProvider(), _fakeProvider(), _fakeProvider()]; // 3
      await tester.pumpWidget(_wrap(HomeStatsBar(doctors: doctors, pharmacies: pharmacies)));
      await tester.pumpAndSettle();

      expect(_statText('2'), findsOneWidget);
      expect(_statText('3'), findsOneWidget);
    });
  });

  // ── Number formatting ───────────────────────────────────────────────────────

  group('HomeStatsBar — number formatting', () {
    testWidgets('999 reviews displayed as "999" (no k-suffix)', (tester) async {
      // 3 doctors, each with 333 reviews = 999 total reviews.
      // Doctor count (3) and review count (999) are different — no collision.
      final doctors = List.generate(3, (_) => _fakeProvider(reviews: 333));
      await tester.pumpWidget(_wrap(HomeStatsBar(doctors: doctors, pharmacies: const [])));
      await tester.pumpAndSettle();

      expect(_statText('999'), findsOneWidget);
      expect(find.textContaining('k'), findsNothing);
    });

    testWidgets('exactly 1000 reviews displayed as "1.0k"', (tester) async {
      final doctors = [_fakeProvider(reviews: 1000)];
      await tester.pumpWidget(_wrap(HomeStatsBar(doctors: doctors, pharmacies: const [])));
      await tester.pumpAndSettle();

      expect(_statText('1.0k'), findsOneWidget);
      expect(_statText('1000'), findsNothing);
    });

    testWidgets('1200 reviews displayed as "1.2k"', (tester) async {
      final doctors = [_fakeProvider(reviews: 1200)];
      await tester.pumpWidget(_wrap(HomeStatsBar(doctors: doctors, pharmacies: const [])));
      await tester.pumpAndSettle();

      expect(_statText('1.2k'), findsOneWidget);
    });

    testWidgets('5500 reviews displayed as "5.5k"', (tester) async {
      final doctors = [_fakeProvider(reviews: 5500)];
      await tester.pumpWidget(_wrap(HomeStatsBar(doctors: doctors, pharmacies: const [])));
      await tester.pumpAndSettle();

      expect(_statText('5.5k'), findsOneWidget);
    });
  });
}
