import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderModel {
  final String providerId;
  final String type; // "doctor" | "pharmacy"
  final String name;
  final String specialty;
  final String address;
  final String phone;
  final GeoPoint? location;
  final String? photoUrl;
  final double averageRating;
  final int totalReviews;
  final double rankingScore;
  final String? ownerId;

  ProviderModel({
    required this.providerId,
    required this.type,
    required this.name,
    required this.specialty,
    required this.address,
    required this.phone,
    this.location,
    this.photoUrl,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.rankingScore = 0.0,
    this.ownerId,
  });

  factory ProviderModel.fromMap(String id, Map<String, dynamic> map) {
    return ProviderModel(
      providerId: id,
      type: map['category'] ?? map['type'] ?? 'doctor',
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      location: map['location'],
      photoUrl: map['photoUrl'],
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      rankingScore: (map['rankingScore'] ?? 0.0).toDouble(),
      ownerId: map['ownerId'],
    );
  }

  ProviderModel copyWith({
    String? providerId,
    String? type,
    String? name,
    String? specialty,
    String? address,
    String? phone,
    GeoPoint? location,
    String? photoUrl,
    double? averageRating,
    int? totalReviews,
    double? rankingScore,
    String? ownerId,
  }) {
    return ProviderModel(
      providerId: providerId ?? this.providerId,
      type: type ?? this.type,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      rankingScore: rankingScore ?? this.rankingScore,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': type,
      'type': type,
      'name': name,
      'specialty': specialty,
      'address': address,
      'phone': phone,
      'location': location,
      'photoUrl': photoUrl,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'rankingScore': rankingScore,
      'ownerId': ownerId,
    };
  }
}
