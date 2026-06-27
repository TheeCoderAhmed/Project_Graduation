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
  final String? gender; // "male" | "female" | null — drives doctor avatar
  final String? hospital; // hospital/clinic the doctor practices at
  final String? department; // ward/department the doctor works in
  final String? room; // room/office number
  // Pending practice change awaiting admin approval. Live fields above are
  // only mutated by an admin; the doctor's edits land here first.
  final String? pendingHospital;
  final String? pendingDepartment;
  final String? pendingRoom;
  final String? practiceChangeStatus; // 'pending' | null

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
    this.gender,
    this.hospital,
    this.department,
    this.room,
    this.pendingHospital,
    this.pendingDepartment,
    this.pendingRoom,
    this.practiceChangeStatus,
  });

  /// True when the doctor has submitted a practice change still awaiting
  /// admin approval.
  bool get hasPendingPracticeChange => practiceChangeStatus == 'pending';

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
      gender: map['gender'],
      hospital: map['hospital'],
      department: map['department'],
      room: map['room'],
      pendingHospital: map['pendingHospital'],
      pendingDepartment: map['pendingDepartment'],
      pendingRoom: map['pendingRoom'],
      practiceChangeStatus: map['practiceChangeStatus'],
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
    String? gender,
    String? hospital,
    String? department,
    String? room,
    String? pendingHospital,
    String? pendingDepartment,
    String? pendingRoom,
    String? practiceChangeStatus,
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
      gender: gender ?? this.gender,
      hospital: hospital ?? this.hospital,
      department: department ?? this.department,
      room: room ?? this.room,
      pendingHospital: pendingHospital ?? this.pendingHospital,
      pendingDepartment: pendingDepartment ?? this.pendingDepartment,
      pendingRoom: pendingRoom ?? this.pendingRoom,
      practiceChangeStatus: practiceChangeStatus ?? this.practiceChangeStatus,
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
      'gender': gender,
      'hospital': hospital,
      'department': department,
      'room': room,
      'pendingHospital': pendingHospital,
      'pendingDepartment': pendingDepartment,
      'pendingRoom': pendingRoom,
      'practiceChangeStatus': practiceChangeStatus,
    };
  }
}
