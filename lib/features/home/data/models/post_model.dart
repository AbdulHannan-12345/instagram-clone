import 'package:flutter_test_app/features/home/domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userImage,
    required super.description,
    required super.imageUrl,
    required super.createdAt,
    required super.likes,
    required super.comments,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userImage: map['userImage'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      likes: List<String>.from(map['likes'] as List? ?? []),
      comments: List<Map<String, String>>.from(
        (map['comments'] as List? ?? []).map(
          (c) => Map<String, String>.from(c as Map),
        ),
      ),
    );
  }

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      userImage: entity.userImage,
      description: entity.description,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      likes: entity.likes,
      comments: entity.comments,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
