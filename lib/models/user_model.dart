class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? profilePic;
  final String role;
  final List<String> ownedCourts;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.profilePic,
    this.role = 'user',
    this.ownedCourts = const [],
    this.createdAt,
  });

  bool get isUser => role == 'user';
  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profilePic': profilePic,
      'role': role,
      'ownedCourts': ownedCourts,
      if (createdAt != null) 'createdAt': createdAt!.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime? parsedCreatedAt;
    try {
      final ca = map['createdAt'];
      if (ca is int) {
        parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(ca);
      }
    } catch (_) {}

    return UserModel(
      uid: map['uid'] is String ? map['uid'] : '',
      email: map['email'] is String ? map['email'] : '',
      name: map['name'] is String ? map['name'] : '',
      profilePic: map['profilePic'] is String ? map['profilePic'] : null,
      role: map['role'] is String ? map['role'] : 'user',
      ownedCourts: map['ownedCourts'] is List
          ? List<String>.from(map['ownedCourts'])
          : [],
      createdAt: parsedCreatedAt,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? profilePic,
    String? role,
    List<String>? ownedCourts,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      role: role ?? this.role,
      ownedCourts: ownedCourts ?? this.ownedCourts,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
