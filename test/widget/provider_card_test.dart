// Widget tests for ProviderCard
//
// Coverage:
//   - Name, specialty, review count, rating all rendered
//   - Hospital icon for doctor, pharmacy icon for pharmacy
//   - Placeholder avatar (icon) shown when photoUrl is null
//   - Chevron arrow always visible as navigation affordance
//   - onTap callback fires correctly; fires exactly once per tap

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drapo/models/provider_model.dart';
import 'package:drapo/widgets/provider_card.dart';

void _disableFonts() => GoogleFonts.config.allowRuntimeFetching = false;

// photoUrl intentionally null — prevents CachedNetworkImage network calls in tests.
ProviderModel _fakeProvider({
  String type = 'doctor',
  String name = 'Dr. Sarah Johnson',
  String specialty = 'Cardiologist',
  double averageRating = 4.7,
  int totalReviews = 42,
  String? photoUrl,
}) {
  return ProviderModel(
    providerId: 'p_001',
    type: type,
    name: name,
    specialty: specialty,
    address: '15 Medical District, Cairo',
    phone: '+20-100-000-0001',
    photoUrl: photoUrl,
    averageRating: averageRating,
    totalReviews: totalReviews,
  );
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  setUpAll(_disableFonts);

  // ── Content rendering ───────────────────────────────────────────────────────

  group('ProviderCard — content rendering', () {
    testWidgets('renders provider name', (tester) async {
      await tester.pumpWidget(_wrap(
        ProviderCard(provider: _fakeProvider(name: 'Dr. Sarah Johnson'), onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Sarah Johnson'), findsOneWidget);
    });

    testWidgets('renders specialty', (tester) async {
      await tester.pumpWidget(_wrap(
        ProviderCard(provider: _fakeProvider(specialty: 'Cardiologist'), onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Cardiologist'), findsOneWidget);
    });

    testWidgets('renders review count with "reviews" suffix', (tester) async {
      await tester.pumpWidget(_wrap(
        ProviderCard(provider: _fakeProvider(totalReviews: 42), onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('42 reviews'), findsOneWidget);
    });

    testWidgets('renders average rating formatted to one decimal', (tester) async {
      await tester.pumpWidget(_wrap(
        ProviderCard(provider: _fakeProvider(averageRating: 4.7), onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('4.7'), findsOneWidget);
    });

    testWidgets('renders 0 reviews and 0.0 rating for a new provider', (tester) async {
      await tester.pumpWidget(_wrap(
        ProviderCard(
          provider: _fakeProvider(totalReviews: 0, averageRating: 0.0),
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('0 reviews'), findsOneWidget);
      expect(find.text('0.0'), findsOneWidget);
    });

    testWidgets('chevron icon visible as navigation affordance', (tester) async {
      await tester.pumpWidget(_wrap(
        ProviderCard(provider: _fakeProvider(), onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('star icon visible in rating badge', (tester) async {
      await tester.pumpWidget(_wrap(
        ProviderCard(provider: _fakeProvider(), onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });
  });

  // ── Provider type icon ──────────────────────────────────────────────────────

  group('ProviderCard — type icon (placeholder avatar)', () {
    testWidgets('shows hospital icon for doctor when photoUrl is null', (tester) async {
      await tester.pumpWidget(_wrap(
        ProviderCard(provider: _fakeProvider(type: 'doctor', photoUrl: null), onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_hospital_rounded), findsOneWidget);
      expect(find.byIcon(Icons.local_pharmacy_rounded), findsNothing);
    });

    testWidgets('shows pharmacy icon for pharmacy when photoUrl is null', (tester) async {
      await tester.pumpWidget(_wrap(
        ProviderCard(provider: _fakeProvider(type: 'pharmacy', photoUrl: null), onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_pharmacy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.local_hospital_rounded), findsNothing);
    });

    testWidgets('correct icon for a full pharmacy provider record', (tester) async {
      await tester.pumpWidget(_wrap(
        ProviderCard(
          provider: _fakeProvider(
            type: 'pharmacy',
            name: 'City Pharmacy',
            specialty: 'General Pharmacy',
            totalReviews: 15,
            averageRating: 3.9,
          ),
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('City Pharmacy'), findsOneWidget);
      expect(find.text('General Pharmacy'), findsOneWidget);
      expect(find.text('15 reviews'), findsOneWidget);
      expect(find.byIcon(Icons.local_pharmacy_rounded), findsOneWidget);
    });
  });

  // ── Tap behaviour ───────────────────────────────────────────────────────────

  group('ProviderCard — tap behaviour', () {
    testWidgets('onTap fires when card is tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(
        ProviderCard(provider: _fakeProvider(), onTap: () => tapped = true),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('onTap fires exactly once per tap', (tester) async {
      int count = 0;
      await tester.pumpWidget(_wrap(
        ProviderCard(provider: _fakeProvider(), onTap: () => count++),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(count, 1);
    });

    testWidgets('tapping twice increments count to 2', (tester) async {
      int count = 0;
      await tester.pumpWidget(_wrap(
        ProviderCard(provider: _fakeProvider(), onTap: () => count++),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(count, 2);
    });
  });
}
