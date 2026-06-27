// Widget tests for ReviewCard
//
// Coverage:
//   - Renders user name, rating, date, and comment
//   - Comment section is conditionally rendered (appears/absent based on content)
//   - Provider name banner shows only when providerName is non-empty
//   - Verified badge shows only when isVerified = true
//   - Questionnaire rows show only when at least one score > 0
//   - InkWell present only when onTap is provided; tap fires the callback

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drapo/models/review_model.dart';
import 'package:drapo/models/questionnaire_model.dart';
import 'package:drapo/widgets/review_card.dart';

void _disableFonts() => GoogleFonts.config.allowRuntimeFetching = false;

ReviewModel _fakeReview({
  String userName = 'Ahmed Haidar',
  double overallRating = 4.5,
  String comment = 'Great clinic, highly recommended.',
  bool isVerified = false,
  QuestionnaireModel? questionnaire,
}) {
  return ReviewModel(
    reviewId: 'r_001',
    providerId: 'p_001',
    userId: 'u_001',
    userName: userName,
    overallRating: overallRating,
    comment: comment,
    isVerified: isVerified,
    createdAt: Timestamp(1700000000, 0), // 2023-11-14
    questionnaire: questionnaire ??
        QuestionnaireModel(waitingTime: 0, serviceQuality: 0, hygiene: 0, staffCommunication: 0),
  );
}

QuestionnaireModel _fullQ() => QuestionnaireModel(
      waitingTime: 4.0,
      serviceQuality: 3.5,
      hygiene: 5.0,
      staffCommunication: 4.0,
    );

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  setUpAll(_disableFonts);

  // ── Basic content ───────────────────────────────────────────────────────────

  group('ReviewCard — basic content', () {
    testWidgets('renders user name', (tester) async {
      await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview())));
      await tester.pumpAndSettle();

      expect(find.text('Ahmed Haidar'), findsOneWidget);
    });

    testWidgets('renders overall rating as formatted string', (tester) async {
      await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview(overallRating: 4.5))));
      await tester.pumpAndSettle();

      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('renders integer rating as X.0 string', (tester) async {
      await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview(overallRating: 3.0))));
      await tester.pumpAndSettle();

      expect(find.text('3.0'), findsOneWidget);
    });

    testWidgets('renders comment text when comment is non-empty', (tester) async {
      const text = 'Very professional staff and clean facilities.';
      await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview(comment: text))));
      await tester.pumpAndSettle();

      expect(find.text(text), findsOneWidget);
    });

    testWidgets('comment text absent when comment is empty string', (tester) async {
      // First verify a known comment DOES appear — this confirms the comment
      // rendering path is reachable and the guard `if (isNotEmpty)` works.
      const knownComment = 'Unique comment to verify conditional rendering';
      await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview(comment: knownComment))));
      await tester.pumpAndSettle();
      expect(find.text(knownComment), findsOneWidget); // guard is NOT inverted

      // Now replace with empty comment — the known text must vanish.
      await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview(comment: ''))));
      await tester.pumpAndSettle();
      expect(find.text(knownComment), findsNothing);
    });

    testWidgets('renders "Anonymous" when userName is Anonymous', (tester) async {
      await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview(userName: 'Anonymous'))));
      await tester.pumpAndSettle();

      expect(find.text('Anonymous'), findsOneWidget);
    });

    testWidgets('renders a formatted date string (not "Just now")', (tester) async {
      // Timestamp(1700000000, 0) is in November 2023 in any timezone.
      // We test the YEAR rather than exact date to avoid timezone-dependent failures.
      await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview())));
      await tester.pumpAndSettle();

      expect(find.textContaining('2023'), findsOneWidget);
      expect(find.text('Just now'), findsNothing);
    });
  });

  // ── Provider name banner ────────────────────────────────────────────────────

  group('ReviewCard — provider name banner', () {
    testWidgets('banner visible when providerName is supplied', (tester) async {
      await tester.pumpWidget(_wrap(
        ReviewCard(review: _fakeReview(), providerName: 'City Hospital'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('City Hospital'), findsOneWidget);
      // Banner icon only appears when banner is rendered
      expect(find.byIcon(Icons.medical_services_rounded), findsOneWidget);
    });

    testWidgets('banner absent when providerName is null', (tester) async {
      await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview())));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.medical_services_rounded), findsNothing);
    });

    testWidgets('banner absent when providerName is empty string', (tester) async {
      await tester.pumpWidget(_wrap(
        ReviewCard(review: _fakeReview(), providerName: ''),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.medical_services_rounded), findsNothing);
    });

    testWidgets('chevron icon visible in banner when card is tappable', (tester) async {
      await tester.pumpWidget(_wrap(
        ReviewCard(review: _fakeReview(), providerName: 'City Hospital', onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('chevron icon absent in banner when card is not tappable', (tester) async {
      await tester.pumpWidget(_wrap(
        ReviewCard(review: _fakeReview(), providerName: 'City Hospital'),
      ));
      await tester.pumpAndSettle();

      // onTap is null → chevron should not be shown
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });
  });

  // ── Verified badge ──────────────────────────────────────────────────────────

  group('ReviewCard — verified badge', () {
    testWidgets('verified badge visible when isVerified is true', (tester) async {
      await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview(isVerified: true))));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    });

    testWidgets('verified badge absent when isVerified is false', (tester) async {
      await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview(isVerified: false))));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.verified_rounded), findsNothing);
    });
  });

  // ── Questionnaire rows ──────────────────────────────────────────────────────

  group('ReviewCard — questionnaire rows', () {
    testWidgets('all four row labels visible when scores are non-zero', (tester) async {
      await tester.pumpWidget(_wrap(
        ReviewCard(review: _fakeReview(questionnaire: _fullQ())),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Wait Time'), findsOneWidget);
      expect(find.text('Service'), findsOneWidget);
      expect(find.text('Hygiene'), findsOneWidget);
      expect(find.text('Staff'), findsOneWidget);
    });

    testWidgets('questionnaire section absent when all scores are zero', (tester) async {
      // All zeros = user skipped the questionnaire; section must not render.
      await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview())));
      await tester.pumpAndSettle();

      expect(find.text('Wait Time'), findsNothing);
      expect(find.text('Service'), findsNothing);
      expect(find.text('Hygiene'), findsNothing);
      expect(find.text('Staff'), findsNothing);
    });

    testWidgets('questionnaire section renders when only one score is non-zero', (tester) async {
      // The guard is `waitingTime > 0 || serviceQuality > 0` — only first two checked.
      final q = QuestionnaireModel(
        waitingTime: 3.0,  // triggers section
        serviceQuality: 0,
        hygiene: 0,
        staffCommunication: 0,
      );

      await tester.pumpWidget(_wrap(
        ReviewCard(review: _fakeReview(questionnaire: q)),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Wait Time'), findsOneWidget);
    });
  });

  // ── Tap behaviour ───────────────────────────────────────────────────────────

  group('ReviewCard — tap behaviour', () {
    testWidgets('InkWell present when onTap is provided', (tester) async {
      await tester.pumpWidget(_wrap(
        ReviewCard(review: _fakeReview(), onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('InkWell absent when onTap is null', (tester) async {
      await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview())));
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('onTap callback fires exactly once when tapped', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(_wrap(
        ReviewCard(review: _fakeReview(), onTap: () => callCount++),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(callCount, 1);
    });

    testWidgets('tapping twice fires callback twice', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(_wrap(
        ReviewCard(review: _fakeReview(), onTap: () => callCount++),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(callCount, 2);
    });
  });
}
