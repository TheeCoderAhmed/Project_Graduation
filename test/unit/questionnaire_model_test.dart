// Unit tests for QuestionnaireModel
//
// What we test: fromMap() parsing and toMap() round-trip.
// No Firebase dependency — QuestionnaireModel is a plain Dart value class.

import 'package:flutter_test/flutter_test.dart';
import 'package:drapo/models/questionnaire_model.dart';

void main() {
  group('QuestionnaireModel.fromMap()', () {
    test('parses valid data correctly', () {
      final model = QuestionnaireModel.fromMap({
        'waitingTime': 4.0,
        'serviceQuality': 3.5,
        'hygiene': 5.0,
        'staffCommunication': 2.0,
      });

      expect(model.waitingTime, 4.0);
      expect(model.serviceQuality, 3.5);
      expect(model.hygiene, 5.0);
      expect(model.staffCommunication, 2.0);
    });

    test('accepts integer values and converts to double', () {
      final model = QuestionnaireModel.fromMap({
        'waitingTime': 3,
        'serviceQuality': 4,
        'hygiene': 5,
        'staffCommunication': 2,
      });

      expect(model.waitingTime, 3.0);
      expect(model.serviceQuality, 4.0);
    });

    test('clamps values above 5.0 to exactly 5.0', () {
      // A corrupt Firestore document might send 6, 10, etc.
      final model = QuestionnaireModel.fromMap({
        'waitingTime': 6.0,
        'serviceQuality': 10.0,
        'hygiene': 99.0,
        'staffCommunication': 5.1,
      });

      expect(model.waitingTime, 5.0);
      expect(model.serviceQuality, 5.0);
      expect(model.hygiene, 5.0);
      expect(model.staffCommunication, 5.0);
    });

    test('clamps negative values to 0.0', () {
      final model = QuestionnaireModel.fromMap({
        'waitingTime': -1.0,
        'serviceQuality': -100.0,
        'hygiene': -0.1,
        'staffCommunication': -5.0,
      });

      expect(model.waitingTime, 0.0);
      expect(model.serviceQuality, 0.0);
      expect(model.hygiene, 0.0);
      expect(model.staffCommunication, 0.0);
    });

    test('defaults to 0.0 when field is missing', () {
      final model = QuestionnaireModel.fromMap({});

      expect(model.waitingTime, 0.0);
      expect(model.serviceQuality, 0.0);
      expect(model.hygiene, 0.0);
      expect(model.staffCommunication, 0.0);
    });

    test('defaults to 0.0 when field is non-numeric (e.g. String)', () {
      final model = QuestionnaireModel.fromMap({
        'waitingTime': 'great',
        'serviceQuality': null,
        'hygiene': true,
        'staffCommunication': [],
      });

      expect(model.waitingTime, 0.0);
      expect(model.serviceQuality, 0.0);
      expect(model.hygiene, 0.0);
      expect(model.staffCommunication, 0.0);
    });

    test('accepts the exact boundary value 5.0 without clamping', () {
      final model = QuestionnaireModel.fromMap({
        'waitingTime': 5.0,
        'serviceQuality': 0.0,
        'hygiene': 5.0,
        'staffCommunication': 0.0,
      });

      expect(model.waitingTime, 5.0);
      expect(model.serviceQuality, 0.0);
      expect(model.hygiene, 5.0);
      expect(model.staffCommunication, 0.0);
    });
  });

  group('QuestionnaireModel.toMap()', () {
    test('round-trips correctly through fromMap → toMap', () {
      final original = QuestionnaireModel(
        waitingTime: 4.0,
        serviceQuality: 3.0,
        hygiene: 5.0,
        staffCommunication: 2.5,
      );

      final map = original.toMap();
      final restored = QuestionnaireModel.fromMap(map);

      expect(restored.waitingTime, original.waitingTime);
      expect(restored.serviceQuality, original.serviceQuality);
      expect(restored.hygiene, original.hygiene);
      expect(restored.staffCommunication, original.staffCommunication);
    });

    test('toMap() contains all four required keys', () {
      final model = QuestionnaireModel(
        waitingTime: 1.0,
        serviceQuality: 2.0,
        hygiene: 3.0,
        staffCommunication: 4.0,
      );

      final map = model.toMap();

      expect(map.containsKey('waitingTime'), isTrue);
      expect(map.containsKey('serviceQuality'), isTrue);
      expect(map.containsKey('hygiene'), isTrue);
      expect(map.containsKey('staffCommunication'), isTrue);
    });
  });

  group('QuestionnaireModel.average', () {
    // These tests call model.average — the production getter — not inline math.
    // A broken getter (e.g. divides by 2 instead of 4) will fail here.

    test('average of (4, 3, 5, 4) equals 4.0', () {
      final model = QuestionnaireModel(
        waitingTime: 4.0,
        serviceQuality: 3.0,
        hygiene: 5.0,
        staffCommunication: 4.0,
      );

      // (4 + 3 + 5 + 4) / 4 = 16 / 4 = 4.0
      expect(model.average, 4.0);
    });

    test('average of all-zero scores is 0.0', () {
      final model = QuestionnaireModel(
        waitingTime: 0.0,
        serviceQuality: 0.0,
        hygiene: 0.0,
        staffCommunication: 0.0,
      );

      expect(model.average, 0.0);
    });

    test('average of all-max scores is 5.0', () {
      final model = QuestionnaireModel(
        waitingTime: 5.0,
        serviceQuality: 5.0,
        hygiene: 5.0,
        staffCommunication: 5.0,
      );

      expect(model.average, 5.0);
    });

    test('average of asymmetric scores is correct to one decimal', () {
      final model = QuestionnaireModel(
        waitingTime: 2.0,
        serviceQuality: 4.0,
        hygiene: 3.0,
        staffCommunication: 3.0,
      );

      // (2 + 4 + 3 + 3) / 4 = 12 / 4 = 3.0
      expect(model.average, 3.0);
    });
  });
}
