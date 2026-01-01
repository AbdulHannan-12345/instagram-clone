import 'package:equatable/equatable.dart';

class StoryEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String imageUrl;
  final DateTime createdAt;

  const StoryEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userImage,
    imageUrl,
    createdAt,
  ];
}
