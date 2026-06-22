class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? profilePic;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.profilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profilePic': profilePic,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'],
    );
  }
}
