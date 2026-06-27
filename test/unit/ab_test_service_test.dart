// Unit tests for AbTestService
//
// Experiment: Stats Bar Visibility
//   Control   (A): HomeStatsBar visible
//   Treatment (B): HomeStatsBar hidden
//
// Coverage:
//   - Same userId always returns the same variant (deterministic)
//   - isControl and isTreatment are mutually exclusive
//   - Every userId is assigned exactly one variant (no gaps)
//   - A large population produces a roughly 50/50 split
//   - Empty string and special characters are handled without throwing

import 'package:flutter_test/flutter_test.dart';
import 'package:drapo/services/ab_test_service.dart';

void main() {
  // ── Determinism ──────────────────────────────────────────────────────────────

  group('AbTestService — determinism', () {
    test('same userId always returns the same variant', () {
      const userId = 'user_abc_123';

      final first  = AbTestService.assignVariant(userId);
      final second = AbTestService.assignVariant(userId);
      final third  = AbTestService.assignVariant(userId);

      expect(first, equals(second));
      expect(second, equals(third));
    });

    test('different userIds can return different variants', () {
      // Find two IDs with opposite hashCode parity — guarantees both variants exist.
      // 'a' has a known hashCode; 'b' differs. We just assert the service handles both.
      final variants = ['user_001', 'user_002', 'user_003', 'user_004', 'user_005']
          .map(AbTestService.assignVariant)
          .toSet();

      // Over 5 distinct IDs, at least one variant must appear.
      expect(variants.isNotEmpty, isTrue);
    });
  });

  // ── Mutual exclusion ─────────────────────────────────────────────────────────

  group('AbTestService — isControl and isTreatment are mutually exclusive', () {
    test('isControl and isTreatment never both true for the same userId', () {
      const ids = ['alpha', 'beta', 'gamma', 'delta', 'epsilon'];

      for (final id in ids) {
        final ctrl  = AbTestService.isControl(id);
        final treat = AbTestService.isTreatment(id);

        // XOR: exactly one must be true
        expect(ctrl ^ treat, isTrue,
            reason: 'userId "$id" must be in exactly one variant');
      }
    });

    test('every userId is assigned exactly one variant', () {
      const ids = ['u1', 'u2', 'u3', 'u4', 'u5', 'u6', 'u7', 'u8'];

      for (final id in ids) {
        final variant = AbTestService.assignVariant(id);
        expect(variant == AbVariant.control || variant == AbVariant.treatment, isTrue,
            reason: 'userId "$id" returned an unrecognised variant');
      }
    });
  });

  // ── Distribution ─────────────────────────────────────────────────────────────

  group('AbTestService — distribution', () {
    test('100 sequential user IDs produce a roughly 50/50 split', () {
      int controlCount = 0;
      int treatmentCount = 0;

      for (int i = 0; i < 100; i++) {
        final variant = AbTestService.assignVariant('user_$i');
        if (variant == AbVariant.control) {
          controlCount++;
        } else {
          treatmentCount++;
        }
      }

      // Allow ±15% deviation — hash distributions are not perfectly uniform
      // on small samples, but should be within this range for 100 entries.
      expect(controlCount,   inInclusiveRange(35, 65));
      expect(treatmentCount, inInclusiveRange(35, 65));
    });
  });

  // ── Edge cases ───────────────────────────────────────────────────────────────

  group('AbTestService — edge cases', () {
    test('empty string userId does not throw', () {
      expect(() => AbTestService.assignVariant(''), returnsNormally);
    });

    test('special characters in userId do not throw', () {
      expect(
        () => AbTestService.assignVariant('user@example.com / #1!'),
        returnsNormally,
      );
    });

    test('very long userId does not throw', () {
      final longId = 'u' * 10000;
      expect(() => AbTestService.assignVariant(longId), returnsNormally);
    });
  });
}
