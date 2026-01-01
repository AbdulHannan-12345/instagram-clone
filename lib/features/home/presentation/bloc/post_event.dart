import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class GetPostsEvent extends PostEvent {
  final int page;

  const GetPostsEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class GetStoriesEvent extends PostEvent {
  const GetStoriesEvent();
}

class LikePostEvent extends PostEvent {
  final String postId;
  final String userId;

  const LikePostEvent({required this.postId, required this.userId});

  @override
  List<Object?> get props => [postId, userId];
}

class AddCommentEvent extends PostEvent {
  final String postId;
  final String userId;
  final String userName;
  final String userImage;
  final String text;

  const AddCommentEvent({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.text,
  });

  @override
  List<Object?> get props => [postId, userId, userName, userImage, text];
}
