// Widget tests for HomeSearchBar
//
// Coverage:
//   - Placeholder text, badge, and search icon render correctly
//   - Tapping anywhere on the bar pushes AppRoutes.search
//   - After tap, the search screen is visible (navigation succeeded)
//   - Bar is not a real text input — no TextField present

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drapo/screens/home/widgets/home_search_bar.dart';
import 'package:drapo/constants/app_routes.dart';

void _disableFonts() => GoogleFonts.config.allowRuntimeFetching = false;

class _RouteObserver extends NavigatorObserver {
  final List<String?> pushed = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route.settings.name);
  }
}

Widget _wrap(Widget child, {NavigatorObserver? observer}) {
  return MaterialApp(
    navigatorObservers: [if (observer != null) observer],
    routes: {
      AppRoutes.search: (_) => const Scaffold(body: Text('SearchScreen')),
    },
    home: Scaffold(body: child),
  );
}

void main() {
  setUpAll(_disableFonts);

  // ── Rendering ───────────────────────────────────────────────────────────────

  group('HomeSearchBar — rendering', () {
    testWidgets('shows placeholder text', (tester) async {
      await tester.pumpWidget(_wrap(const HomeSearchBar()));
      await tester.pumpAndSettle();

      expect(find.text('Search doctors, pharmacies...'), findsOneWidget);
    });

    testWidgets('shows "Search" badge text', (tester) async {
      await tester.pumpWidget(_wrap(const HomeSearchBar()));
      await tester.pumpAndSettle();

      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('shows search magnifier icon', (tester) async {
      await tester.pumpWidget(_wrap(const HomeSearchBar()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('is NOT a real text field — no TextField widget', (tester) async {
      // HomeSearchBar is a fake bar that navigates on tap, not a real input.
      await tester.pumpWidget(_wrap(const HomeSearchBar()));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });
  });

  // ── Navigation ──────────────────────────────────────────────────────────────

  group('HomeSearchBar — navigation on tap', () {
    testWidgets('tapping bar pushes AppRoutes.search route', (tester) async {
      final observer = _RouteObserver();
      await tester.pumpWidget(_wrap(const HomeSearchBar(), observer: observer));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(observer.pushed, contains(AppRoutes.search));
    });

    testWidgets('search screen becomes visible after tap', (tester) async {
      await tester.pumpWidget(_wrap(const HomeSearchBar()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.text('SearchScreen'), findsOneWidget);
    });

    testWidgets('tapping placeholder text navigates to search', (tester) async {
      final observer = _RouteObserver();
      await tester.pumpWidget(_wrap(const HomeSearchBar(), observer: observer));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search doctors, pharmacies...'));
      await tester.pumpAndSettle();

      expect(observer.pushed, contains(AppRoutes.search));
    });
  });
}
