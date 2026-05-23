class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String role; // "patient" | "provider" | "admin"
  final String? profilePhotoUrl;
  final List<String> bookmarks;
  final String? tcKimlik; // Private national ID — person accounts only
  final String? gender;   // "male" | "female" — person accounts only

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.profilePhotoUrl,
    this.bookmarks = const [],
    this.tcKimlik,
    this.gender,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'patient',
      profilePhotoUrl: map['profilePhotoUrl'],
      bookmarks: List<String>.from(map['bookmarks'] ?? []),
      tcKimlik: map['tcKimlik'],
      gender: map['gender'],
    );
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? role,
    String? profilePhotoUrl,
    List<String>? bookmarks,
    String? tcKimlik,
    String? gender,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      bookmarks: bookmarks ?? this.bookmarks,
      tcKimlik: tcKimlik ?? this.tcKimlik,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'profilePhotoUrl': profilePhotoUrl,
      'bookmarks': bookmarks,
      'tcKimlik': tcKimlik,
      'gender': gender,
    };
  }
}
