import 'package:dartz/dartz.dart';
import 'package:flutter_test_app/core/error/failures.dart';
import 'package:flutter_test_app/features/home/domain/entities/post_entity.dart';
import 'package:flutter_test_app/features/home/domain/entities/story_entity.dart';

abstract class PostRepository {
  Future<Either<Failure, List<PostEntity>>> getPosts({
    int page = 1,
    int limit = 5,
  });
  Future<Either<Failure, List<StoryEntity>>> getStories();
  Future<Either<Failure, void>> createPost(PostEntity post);
  Future<Either<Failure, void>> createStory(StoryEntity story);
  Future<Either<Failure, void>> likePost(String postId, String userId);
  Future<Either<Failure, void>> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String userImage,
    required String text,
  });
}
