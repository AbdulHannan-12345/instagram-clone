import 'package:equatable/equatable.dart';
import 'package:flutter_test_app/features/home/domain/entities/post_entity.dart';
import 'package:flutter_test_app/features/home/domain/entities/story_entity.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {
  const PostInitial();
}

class PostLoading extends PostState {
  const PostLoading();
}

class PostsLoaded extends PostState {
  final List<PostEntity> posts;

  const PostsLoaded({required this.posts});

  @override
  List<Object?> get props => [posts];
}

class StoriesLoaded extends PostState {
  final List<StoryEntity> stories;

  const StoriesLoaded({required this.stories});

  @override
  List<Object?> get props => [stories];
}

class PostError extends PostState {
  final String message;

  const PostError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PostAndStoriesLoaded extends PostState {
  final List<PostEntity> posts;
  final List<StoryEntity> stories;

  const PostAndStoriesLoaded({required this.posts, required this.stories});

  @override
  List<Object?> get props => [posts, stories];
}
