import 'package:flutter_test_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.name,
    super.profileImageUrl,
    required super.createdAt,
    super.viewedStories,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      viewedStories: (map['viewedStories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      name: entity.name,
      profileImageUrl: entity.profileImageUrl,
      createdAt: entity.createdAt,
      viewedStories: entity.viewedStories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'viewedStories': viewedStories,
    };
  }
}
