// Unit tests for ProviderModel
//
// What we test: fromMap(), copyWith(), and toMap().
// No Firebase dependency — GeoPoint is a plain value class from cloud_firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drapo/models/provider_model.dart';

// A valid Firestore-shaped map for a doctor provider.
Map<String, dynamic> _doctorMap() => {
      'category': 'doctor',
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Cardiologist',
      'address': '15 Medical District, Cairo',
      'phone': '+20-100-000-0001',
      'photoUrl': 'https://example.com/photo.jpg',
      'averageRating': 4.7,
      'totalReviews': 42,
      'rankingScore': 4.82,
      'ownerId': 'owner_001',
    };

Map<String, dynamic> _pharmacyMap() => {
      'type': 'pharmacy',
      'name': 'City Pharmacy',
      'specialty': 'General Pharmacy',
      'address': '7 Tahrir Square, Cairo',
      'phone': '+20-100-000-0002',
      'averageRating': 3.9,
      'totalReviews': 15,
      'rankingScore': 3.94,
    };

void main() {
  group('ProviderModel.fromMap() — happy path', () {
    test('parses a complete doctor document correctly', () {
      final provider = ProviderModel.fromMap('doc_001', _doctorMap());

      expect(provider.providerId, 'doc_001');
      expect(provider.type, 'doctor');
      expect(provider.name, 'Dr. Sarah Johnson');
      expect(provider.specialty, 'Cardiologist');
      expect(provider.address, '15 Medical District, Cairo');
      expect(provider.phone, '+20-100-000-0001');
      expect(provider.photoUrl, 'https://example.com/photo.jpg');
      expect(provider.averageRating, 4.7);
      expect(provider.totalReviews, 42);
      expect(provider.rankingScore, 4.82);
      expect(provider.ownerId, 'owner_001');
    });

    test('parses a pharmacy document correctly', () {
      final provider = ProviderModel.fromMap('pharm_001', _pharmacyMap());

      expect(provider.type, 'pharmacy');
      expect(provider.name, 'City Pharmacy');
      expect(provider.totalReviews, 15);
    });
  });

  group('ProviderModel.fromMap() — type/category field', () {
    // The schema uses "category" in some documents and "type" in others.
    // fromMap() must handle both.

    test('reads type from "category" key when "type" is absent', () {
      final map = {'category': 'doctor', 'name': 'Test', 'specialty': '',
                   'address': '', 'phone': ''};
      final provider = ProviderModel.fromMap('id', map);

      expect(provider.type, 'doctor');
    });

    test('reads type from "type" key when "category" is absent', () {
      final map = {'type': 'pharmacy', 'name': 'Test', 'specialty': '',
                   'address': '', 'phone': ''};
      final provider = ProviderModel.fromMap('id', map);

      expect(provider.type, 'pharmacy');
    });

    test('prefers "category" over "type" when both present', () {
      final map = {'category': 'doctor', 'type': 'pharmacy', 'name': 'Test',
                   'specialty': '', 'address': '', 'phone': ''};
      final provider = ProviderModel.fromMap('id', map);

      // category takes priority in the fromMap logic
      expect(provider.type, 'doctor');
    });

    test('defaults to "doctor" when neither "category" nor "type" is present', () {
      final provider = ProviderModel.fromMap('id', {});

      expect(provider.type, 'doctor');
    });
  });

  group('ProviderModel.fromMap() — numeric defaults', () {
    test('averageRating defaults to 0.0 when missing', () {
      final provider = ProviderModel.fromMap('id', {});

      expect(provider.averageRating, 0.0);
    });

    test('totalReviews defaults to 0 when missing', () {
      final provider = ProviderModel.fromMap('id', {});

      expect(provider.totalReviews, 0);
    });

    test('rankingScore defaults to 0.0 when missing', () {
      final provider = ProviderModel.fromMap('id', {});

      expect(provider.rankingScore, 0.0);
    });

    test('averageRating converts int to double', () {
      final map = _doctorMap()..['averageRating'] = 4;
      final provider = ProviderModel.fromMap('id', map);

      expect(provider.averageRating, 4.0);
      expect(provider.averageRating, isA<double>());
    });
  });

  group('ProviderModel.fromMap() — optional fields', () {
    test('photoUrl is null when not provided', () {
      final provider = ProviderModel.fromMap('id', _pharmacyMap());

      expect(provider.photoUrl, isNull);
    });

    test('location is null when not provided', () {
      final provider = ProviderModel.fromMap('id', _doctorMap());

      expect(provider.location, isNull);
    });

    test('location is parsed when provided as GeoPoint', () {
      final map = _doctorMap()
        ..['location'] = const GeoPoint(30.0444, 31.2357); // Cairo coords

      final provider = ProviderModel.fromMap('id', map);

      expect(provider.location, isNotNull);
      expect(provider.location!.latitude, 30.0444);
      expect(provider.location!.longitude, 31.2357);
    });

    test('ownerId is null when not provided', () {
      final provider = ProviderModel.fromMap('id', _pharmacyMap());

      expect(provider.ownerId, isNull);
    });
  });

  group('ProviderModel.fromMap() — empty map', () {
    test('does not throw and fills all defaults', () {
      expect(
        () => ProviderModel.fromMap('empty', {}),
        returnsNormally,
      );

      final provider = ProviderModel.fromMap('empty', {});
      expect(provider.providerId, 'empty');
      expect(provider.type, 'doctor');
      expect(provider.name, '');
      expect(provider.averageRating, 0.0);
      expect(provider.totalReviews, 0);
    });
  });

  group('ProviderModel.copyWith()', () {
    test('returns new instance with updated field', () {
      final original = ProviderModel.fromMap('id', _doctorMap());
      final updated = original.copyWith(name: 'Dr. Ahmed');

      expect(updated.name, 'Dr. Ahmed');
      expect(updated.specialty, original.specialty); // unchanged
      expect(updated.providerId, original.providerId); // unchanged
    });

    test('updating averageRating does not affect other fields', () {
      final original = ProviderModel.fromMap('id', _doctorMap());
      final updated = original.copyWith(averageRating: 2.5);

      expect(updated.averageRating, 2.5);
      expect(updated.totalReviews, original.totalReviews);
      expect(updated.name, original.name);
    });

    test('copyWith with no arguments returns equivalent object', () {
      final original = ProviderModel.fromMap('id', _doctorMap());
      final copy = original.copyWith();

      expect(copy.providerId, original.providerId);
      expect(copy.name, original.name);
      expect(copy.type, original.type);
      expect(copy.averageRating, original.averageRating);
    });
  });

  group('ProviderModel.toMap()', () {
    test('contains all required keys', () {
      final provider = ProviderModel.fromMap('id', _doctorMap());
      final map = provider.toMap();

      expect(map.containsKey('category'), isTrue);
      expect(map.containsKey('type'), isTrue);
      expect(map.containsKey('name'), isTrue);
      expect(map.containsKey('specialty'), isTrue);
      expect(map.containsKey('address'), isTrue);
      expect(map.containsKey('phone'), isTrue);
      expect(map.containsKey('averageRating'), isTrue);
      expect(map.containsKey('totalReviews'), isTrue);
      expect(map.containsKey('rankingScore'), isTrue);
    });

    test('toMap() stores type under both "category" and "type" keys', () {
      // Schema requires both keys for backward compatibility.
      final provider = ProviderModel.fromMap('id', _doctorMap());
      final map = provider.toMap();

      expect(map['category'], 'doctor');
      expect(map['type'], 'doctor');
    });

    test('round-trips name, specialty, address through fromMap → toMap → fromMap', () {
      final original = ProviderModel.fromMap('id', _doctorMap());
      final restored = ProviderModel.fromMap('id', original.toMap());

      expect(restored.name, original.name);
      expect(restored.specialty, original.specialty);
      expect(restored.address, original.address);
      expect(restored.averageRating, original.averageRating);
    });
  });
}
