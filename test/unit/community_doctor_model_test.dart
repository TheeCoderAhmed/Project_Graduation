// Unit tests for CommunityDoctorModel
//
// What we test: buildId() slug/grouping logic, averageRating math, and
// fromMap() safety. No Firebase needed — Timestamp is a plain value class.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drapo/models/community_doctor_model.dart';

void main() {
  group('CommunityDoctorModel.buildId', () {
    test('same name + hospital always produce the same id (grouping)', () {
      final a = CommunityDoctorModel.buildId('Dr. Ahmet Yılmaz', 'Acıbadem Hospital');
      final b = CommunityDoctorModel.buildId('Dr. Ahmet Yılmaz', 'Acıbadem Hospital');
      expect(a, b);
    });

    test('is case- and spacing-insensitive', () {
      final a = CommunityDoctorModel.buildId('Dr. Ahmet', 'City Clinic');
      final b = CommunityDoctorModel.buildId('  dr. AHMET  ', 'city   clinic');
      expect(a, b);
    });

    test('different hospital produces a different id', () {
      final a = CommunityDoctorModel.buildId('Dr. Ahmet', 'Hospital A');
      final b = CommunityDoctorModel.buildId('Dr. Ahmet', 'Hospital B');
      expect(a, isNot(b));
    });

    test('contains the name-hospital separator and no leading/trailing dashes', () {
      final id = CommunityDoctorModel.buildId('Dr. Ahmet', 'City Clinic');
      expect(id.contains('__'), isTrue);
      expect(id.startsWith('-'), isFalse);
      expect(id.endsWith('-'), isFalse);
    });

    test('empty hospital falls back to just the name slug', () {
      final id = CommunityDoctorModel.buildId('Dr. Ahmet', '');
      expect(id, 'dr-ahmet');
    });
  });

  group('CommunityDoctorModel.averageRating', () {
    test('returns 0 when there are no reviews (no divide-by-zero)', () {
      final d = CommunityDoctorModel(
        id: 'x', name: 'A', hospital: 'H', department: 'D', specialty: 'S',
      );
      expect(d.averageRating, 0.0);
    });

    test('is ratingSum / totalReviews', () {
      final d = CommunityDoctorModel(
        id: 'x', name: 'A', hospital: 'H', department: 'D', specialty: 'S',
        totalReviews: 4, ratingSum: 18.0,
      );
      expect(d.averageRating, 4.5);
    });
  });

  group('CommunityDoctorModel.fromMap', () {
    test('parses a well-formed map', () {
      final d = CommunityDoctorModel.fromMap('id1', {
        'name': 'Dr. Ahmet',
        'hospital': 'City Clinic',
        'department': 'Cardiology',
        'specialty': 'Cardiologist',
        'totalReviews': 3,
        'ratingSum': 12.0,
        'waitSum': 9.0,
        'serviceSum': 12.0,
        'hygieneSum': 15.0,
        'staffSum': 11.0,
        'updatedAt': Timestamp.now(),
      });
      expect(d.id, 'id1');
      expect(d.name, 'Dr. Ahmet');
      expect(d.totalReviews, 3);
      expect(d.averageRating, closeTo(4.0, 0.0001));
    });

    test('defaults missing/null fields safely', () {
      final d = CommunityDoctorModel.fromMap('id2', {});
      expect(d.name, '');
      expect(d.hospital, '');
      expect(d.totalReviews, 0);
      expect(d.ratingSum, 0.0);
      expect(d.averageRating, 0.0);
      expect(d.updatedAt, isNull);
    });

    test('tolerates wrong types without throwing', () {
      final d = CommunityDoctorModel.fromMap('id3', {
        'name': 123,
        'totalReviews': 'oops',
        'ratingSum': null,
      });
      expect(d.name, '123');
      expect(d.totalReviews, 0);
      expect(d.ratingSum, 0.0);
    });
  });
}
