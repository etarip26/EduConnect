class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isEmailVerified;
  final bool isSuspended;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isEmailVerified,
    required this.isSuspended,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      isSuspended: json['isSuspended'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "role": role,
      "isEmailVerified": isEmailVerified,
      "isSuspended": isSuspended,
    };
  }

  // -------------------------------------------------------
  // copyWith -> CRITICAL for editable profile UI
  // -------------------------------------------------------
  UserModel copyWith({String? name, String? email, String? phone}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role,
      isEmailVerified: isEmailVerified,
      isSuspended: isSuspended,
    );
  }
}
