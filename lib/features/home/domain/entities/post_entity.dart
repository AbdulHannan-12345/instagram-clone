import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String description;
  final String imageUrl;
  final DateTime createdAt;
  final List<String> likes;
  final List<Map<String, String>> comments;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    required this.likes,
    required this.comments,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userImage,
    description,
    imageUrl,
    createdAt,
    likes,
    comments,
  ];

  PostEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImage,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    List<String>? likes,
    List<Map<String, String>>? comments,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}
