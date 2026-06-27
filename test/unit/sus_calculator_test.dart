// Unit tests for SusCalculator
//
// Coverage:
//   - Known score: all-neutral (3s) → 50.0
//   - Known score: all-best responses → 100.0
//   - Known score: all-worst responses → 0.0
//   - Odd-item scoring path (response − 1)
//   - Even-item scoring path (5 − response)
//   - Mixed realistic responses produce correct score
//   - averageScore over multiple participants
//   - grade() returns correct label for each band
//   - ArgumentError on wrong response count
//   - ArgumentError on out-of-range response values
//   - ArgumentError on empty participant list

import 'package:flutter_test/flutter_test.dart';
import 'package:drapo/utils/sus_calculator.dart';

void main() {
  // ── Known boundary scores ─────────────────────────────────────────────────

  group('SusCalculator.calculate() — boundary scores', () {
    test('all neutral responses (3) produce score of 50.0', () {
      // Every odd item: 3−1=2. Every even item: 5−3=2.
      // Sum = 10×2 = 20. Score = 20×2.5 = 50.0.
      final responses = List.filled(10, 3);
      expect(SusCalculator.calculate(responses), 50.0);
    });

    test('all best responses produce score of 100.0', () {
      // Best: odd items = 5 (contribution 4), even items = 1 (contribution 4).
      final responses = [5, 1, 5, 1, 5, 1, 5, 1, 5, 1];
      expect(SusCalculator.calculate(responses), 100.0);
    });

    test('all worst responses produce score of 0.0', () {
      // Worst: odd items = 1 (contribution 0), even items = 5 (contribution 0).
      final responses = [1, 5, 1, 5, 1, 5, 1, 5, 1, 5];
      expect(SusCalculator.calculate(responses), 0.0);
    });
  });

  // ── Item-level scoring paths ──────────────────────────────────────────────

  group('SusCalculator.calculate() — scoring formula', () {
    test('odd items use (response − 1) formula', () {
      // Set only Q1 (index 0, odd item) to 5; everything else neutral (3).
      // Odd items neutral: 2 each × 4 = 8. Even items neutral: 2 each × 5 = 10.
      // Q1 best: 5−1=4 instead of 3−1=2 → delta +2.
      // Base neutral score = 50.0; +2 × 2.5 = +5.0 → expect 55.0.
      final base      = List.filled(10, 3);
      final withBestQ1 = List<int>.from(base)..[0] = 5;
      expect(SusCalculator.calculate(withBestQ1), 55.0);
    });

    test('even items use (5 − response) formula', () {
      // Set only Q2 (index 1, even item) to 1; everything else neutral.
      // Q2 best: 5−1=4 instead of 5−3=2 → delta +2.
      // Base neutral = 50.0; +2 × 2.5 = +5.0 → expect 55.0.
      final base       = List.filled(10, 3);
      final withBestQ2 = List<int>.from(base)..[1] = 1;
      expect(SusCalculator.calculate(withBestQ2), 55.0);
    });
  });

  // ── Realistic participant scores ──────────────────────────────────────────

  group('SusCalculator.calculate() — realistic data', () {
    // These responses mirror the six participants in the USABILITY_TEST.md
    // study. Scores are pre-verified by manual calculation.

    test('P1 (tech-savvy, 28) scores 90.0', () {
      // [4,2,5,1,4,2,5,1,5,1]
      // odd: 3+4+3+4+4=18  even: 3+4+3+4+4=18  → 36×2.5=90.0
      expect(SusCalculator.calculate([4, 2, 5, 1, 4, 2, 5, 1, 5, 1]), 90.0);
    });

    test('P2 (moderate, 45) scores 72.5', () {
      // [4,3,4,2,4,2,4,2,4,2]
      // odd: 3+3+3+3+3=15  even: 2+3+3+3+3=14  → 29×2.5=72.5
      expect(SusCalculator.calculate([4, 3, 4, 2, 4, 2, 4, 2, 4, 2]), 72.5);
    });

    test('P5 (low-tech, 55) scores 52.5', () {
      // [3,3,4,3,3,3,3,3,3,3]
      // odd: 2+3+2+2+2=11  even: 2+2+2+2+2=10  → 21×2.5=52.5
      expect(SusCalculator.calculate([3, 3, 4, 3, 3, 3, 3, 3, 3, 3]), 52.5);
    });
  });

  // ── averageScore ──────────────────────────────────────────────────────────

  group('SusCalculator.averageScore()', () {
    test('average of two identical response sets equals single score', () {
      final responses = [4, 2, 4, 2, 4, 2, 4, 2, 4, 2];
      final single = SusCalculator.calculate(responses);
      final avg    = SusCalculator.averageScore([responses, responses]);
      expect(avg, single);
    });

    test('average of all-100 and all-0 is 50.0', () {
      final best  = [5, 1, 5, 1, 5, 1, 5, 1, 5, 1];
      final worst = [1, 5, 1, 5, 1, 5, 1, 5, 1, 5];
      expect(SusCalculator.averageScore([best, worst]), 50.0);
    });

    test('all six study participants average to 78.75', () {
      final participants = [
        [4, 2, 5, 1, 4, 2, 5, 1, 5, 1], // P1 → 90.0
        [4, 3, 4, 2, 4, 2, 4, 2, 4, 2], // P2 → 72.5
        [5, 2, 4, 1, 4, 2, 5, 1, 4, 2], // P3 → 85.0
        [5, 1, 5, 1, 4, 1, 5, 1, 5, 1], // P4 → 97.5
        [3, 3, 4, 3, 3, 3, 3, 3, 3, 3], // P5 → 52.5
        [4, 2, 4, 2, 4, 2, 4, 2, 4, 2], // P6 → 75.0
      ];
      // (90 + 72.5 + 85 + 97.5 + 52.5 + 75) / 6 = 472.5 / 6 = 78.75
      expect(SusCalculator.averageScore(participants), closeTo(78.75, 0.01));
    });
  });

  // ── grade() ──────────────────────────────────────────────────────────────

  group('SusCalculator.grade()', () {
    test('score ≥ 80.3 → A — Excellent', () {
      expect(SusCalculator.grade(90.0), 'A — Excellent');
      expect(SusCalculator.grade(80.3), 'A — Excellent');
    });

    test('score in [68, 80.3) → B — Good', () {
      expect(SusCalculator.grade(78.75), 'B — Good');
      expect(SusCalculator.grade(68.0),  'B — Good');
    });

    test('score in [51, 68) → C — OK', () {
      expect(SusCalculator.grade(52.5), 'C — OK');
      expect(SusCalculator.grade(51.0), 'C — OK');
    });

    test('score in [25, 51) → D — Poor', () {
      expect(SusCalculator.grade(40.0), 'D — Poor');
      expect(SusCalculator.grade(25.0), 'D — Poor');
    });

    test('score < 25 → F — Awful', () {
      expect(SusCalculator.grade(0.0),  'F — Awful');
      expect(SusCalculator.grade(24.9), 'F — Awful');
    });
  });

  // ── Error handling ────────────────────────────────────────────────────────

  group('SusCalculator — error handling', () {
    test('throws ArgumentError when fewer than 10 responses given', () {
      expect(
        () => SusCalculator.calculate([1, 2, 3]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when more than 10 responses given', () {
      expect(
        () => SusCalculator.calculate(List.filled(11, 3)),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when a response is 0 (below range)', () {
      final responses = List.filled(10, 3)..[0] = 0;
      expect(
        () => SusCalculator.calculate(responses),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when a response is 6 (above range)', () {
      final responses = List.filled(10, 3)..[5] = 6;
      expect(
        () => SusCalculator.calculate(responses),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('averageScore throws ArgumentError on empty participant list', () {
      expect(
        () => SusCalculator.averageScore([]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
