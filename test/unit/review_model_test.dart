// Unit tests for ReviewModel
//
// What we test: fromMap() — the factory that converts raw Firestore data to a typed object.
//
// What we DON'T test here: toMap() — it calls FieldValue.serverTimestamp() which
// requires a live Firebase platform. That belongs in integration tests.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drapo/models/review_model.dart';
import 'package:drapo/models/questionnaire_model.dart';

// A valid Firestore-shaped map — used as the base for most tests.
Map<String, dynamic> _validMap() => {
      'providerId': 'provider_123',
      'userId': 'user_456',
      'userName': 'Ahmed Haidar',
      'overallRating': 4.5,
      'comment': 'Great service, very professional.',
      'questionnaire': {
        'waitingTime': 4.0,
        'serviceQuality': 5.0,
        'hygiene': 4.5,
        'staffCommunication': 3.5,
      },
      'isVerified': true,
      'createdAt': Timestamp(1700000000, 0),
    };

void main() {
  group('ReviewModel.fromMap() — happy path', () {
    test('parses all fields correctly from valid Firestore data', () {
      final review = ReviewModel.fromMap('review_001', _validMap());

      expect(review.reviewId, 'review_001');
      expect(review.providerId, 'provider_123');
      expect(review.userId, 'user_456');
      expect(review.userName, 'Ahmed Haidar');
      expect(review.overallRating, 4.5);
      expect(review.comment, 'Great service, very professional.');
      expect(review.isVerified, true);
      expect(review.createdAt, isNotNull);
    });

    test('parses nested questionnaire map correctly', () {
      final review = ReviewModel.fromMap('review_001', _validMap());

      expect(review.questionnaire.waitingTime, 4.0);
      expect(review.questionnaire.serviceQuality, 5.0);
      expect(review.questionnaire.hygiene, 4.5);
      expect(review.questionnaire.staffCommunication, 3.5);
    });
  });

  group('ReviewModel.fromMap() — overallRating safety', () {
    test('clamps overallRating above 5.0 to 5.0', () {
      final map = _validMap()..['overallRating'] = 7.0;
      final review = ReviewModel.fromMap('r1', map);

      expect(review.overallRating, 5.0);
    });

    test('clamps overallRating below 0.0 to 0.0', () {
      final map = _validMap()..['overallRating'] = -2.0;
      final review = ReviewModel.fromMap('r1', map);

      expect(review.overallRating, 0.0);
    });

    test('defaults to 0.0 when overallRating is null', () {
      final map = _validMap()..['overallRating'] = null;
      final review = ReviewModel.fromMap('r1', map);

      expect(review.overallRating, 0.0);
    });

    test('defaults to 0.0 when overallRating is a non-numeric string', () {
      final map = _validMap()..['overallRating'] = 'five stars';
      final review = ReviewModel.fromMap('r1', map);

      expect(review.overallRating, 0.0);
    });

    test('accepts integer rating and converts to double', () {
      final map = _validMap()..['overallRating'] = 4;
      final review = ReviewModel.fromMap('r1', map);

      expect(review.overallRating, 4.0);
    });
  });

  group('ReviewModel.fromMap() — userName fallback', () {
    test('uses "Anonymous" when userName is empty string', () {
      final map = _validMap()..['userName'] = '';
      final review = ReviewModel.fromMap('r1', map);

      expect(review.userName, 'Anonymous');
    });

    test('uses "Anonymous" when userName is whitespace only', () {
      final map = _validMap()..['userName'] = '   ';
      final review = ReviewModel.fromMap('r1', map);

      expect(review.userName, 'Anonymous');
    });

    test('uses "Anonymous" when userName is null', () {
      final map = _validMap()..['userName'] = null;
      final review = ReviewModel.fromMap('r1', map);

      expect(review.userName, 'Anonymous');
    });

    test('preserves a valid non-empty userName', () {
      final map = _validMap()..['userName'] = 'Dr. Smith';
      final review = ReviewModel.fromMap('r1', map);

      expect(review.userName, 'Dr. Smith');
    });
  });

  group('ReviewModel.fromMap() — questionnaire fallback', () {
    test('defaults all scores to 0.0 when questionnaire field is missing', () {
      final map = _validMap()..remove('questionnaire');
      final review = ReviewModel.fromMap('r1', map);

      expect(review.questionnaire.waitingTime, 0.0);
      expect(review.questionnaire.serviceQuality, 0.0);
      expect(review.questionnaire.hygiene, 0.0);
      expect(review.questionnaire.staffCommunication, 0.0);
    });

    test('defaults all scores to 0.0 when questionnaire is null', () {
      final map = _validMap()..['questionnaire'] = null;
      final review = ReviewModel.fromMap('r1', map);

      expect(review.questionnaire.waitingTime, 0.0);
      expect(review.questionnaire.serviceQuality, 0.0);
      expect(review.questionnaire.hygiene, 0.0);
      expect(review.questionnaire.staffCommunication, 0.0);
    });

    test('parses questionnaire when it is an untyped Map (not Map<String,dynamic>)', () {
      // Firestore SDK sometimes returns Map without explicit type parameter.
      final map = _validMap()
        ..['questionnaire'] = <dynamic, dynamic>{
          'waitingTime': 3.0,
          'serviceQuality': 4.0,
          'hygiene': 2.5,
          'staffCommunication': 5.0,
        };

      final review = ReviewModel.fromMap('r1', map);

      expect(review.questionnaire.waitingTime, 3.0);
      expect(review.questionnaire.serviceQuality, 4.0);
      expect(review.questionnaire.hygiene, 2.5);
      expect(review.questionnaire.staffCommunication, 5.0);
    });

    test('defaults to 0.0 when questionnaire is a non-map type', () {
      final map = _validMap()..['questionnaire'] = 'invalid';
      final review = ReviewModel.fromMap('r1', map);

      expect(review.questionnaire.waitingTime, 0.0);
    });
  });

  group('ReviewModel.fromMap() — other fields', () {
    test('isVerified defaults to false when field is missing', () {
      final map = _validMap()..remove('isVerified');
      final review = ReviewModel.fromMap('r1', map);

      expect(review.isVerified, false);
    });

    test('isVerified is false when field is not exactly true', () {
      final map = _validMap()..['isVerified'] = 'yes';
      final review = ReviewModel.fromMap('r1', map);

      // Only the boolean literal true triggers verified status
      expect(review.isVerified, false);
    });

    test('comment defaults to empty string when missing', () {
      final map = _validMap()..remove('comment');
      final review = ReviewModel.fromMap('r1', map);

      expect(review.comment, '');
    });

    test('createdAt falls back to a non-null Timestamp when field is missing', () {
      final map = _validMap()..remove('createdAt');
      final review = ReviewModel.fromMap('r1', map);

      expect(review.createdAt, isNotNull);
    });

    test('createdAt falls back when field is not a Timestamp', () {
      final map = _validMap()..['createdAt'] = 'yesterday';
      final review = ReviewModel.fromMap('r1', map);

      expect(review.createdAt, isNotNull);
    });

    test('providerId defaults to empty string when missing', () {
      final map = _validMap()..remove('providerId');
      final review = ReviewModel.fromMap('r1', map);

      expect(review.providerId, '');
    });
  });

  group('ReviewModel.fromMap() — completely empty map', () {
    test('does not throw and fills all defaults', () {
      // Simulates a corrupt or incomplete Firestore document.
      // If fromMap() throws, this test fails — no separate returnsNormally needed.
      final review = ReviewModel.fromMap('r_empty', {});

      expect(review.reviewId, 'r_empty');
      expect(review.overallRating, 0.0);
      expect(review.userName, 'Anonymous');
      expect(review.isVerified, false);
      expect(review.comment, '');
      expect(review.questionnaire.waitingTime, 0.0);
    });
  });
}
