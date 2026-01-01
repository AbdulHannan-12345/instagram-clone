import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test_app/core/error/failures.dart';
import 'package:flutter_test_app/core/utils/connectivity_service.dart';
import 'package:flutter_test_app/core/utils/local_storage_service.dart';
import 'package:flutter_test_app/features/home/data/datasources/post_remote_data_source.dart';
import 'package:flutter_test_app/features/home/data/models/post_model.dart';
import 'package:flutter_test_app/features/home/data/models/story_model.dart';
import 'package:flutter_test_app/features/home/domain/entities/post_entity.dart';
import 'package:flutter_test_app/features/home/domain/entities/story_entity.dart';
import 'package:flutter_test_app/features/home/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final LocalStorageService localStorageService;
  final ConnectivityService connectivityService;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorageService,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts({
    int page = 1,
    int limit = 5,
  }) async {
    try {
      // Try to fetch from remote first (for fresh data when online)
      try {
        final posts = await remoteDataSource
            .getPosts(page: page, limit: limit)
            .timeout(const Duration(seconds: 5));

        // Cache the posts for offline use
        if (page == 1 && posts.isNotEmpty) {
          await localStorageService.cachePosts(posts);
        }

        return Right(posts);
      } catch (e) {
        // On timeout or error, return cached data as fallback
        final cachedPosts = await localStorageService.getCachedPosts();
        if (cachedPosts.isNotEmpty) {
          return Right(cachedPosts);
        }
        return Left(
          ServerFailure('Unable to load posts. Please check your connection.'),
        );
      }
    } catch (e) {
      // On error, try to return cached data
      final cachedPosts = await localStorageService.getCachedPosts();
      if (cachedPosts.isNotEmpty) {
        return Right(cachedPosts);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  // Background fetch and cache
  Future<void> _fetchAndCachePosts(int page, int limit) async {
    try {
      final isConnected = await connectivityService.isConnected();
      if (isConnected) {
        final posts = await remoteDataSource.getPosts(page: page, limit: limit);
        if (posts.isNotEmpty) {
          await localStorageService.cachePosts(posts);
        }
      }
    } catch (e) {
      // Silently fail background fetch
      print('Background fetch failed: $e');
    }
  }

  @override
  Future<Either<Failure, List<StoryEntity>>> getStories() async {
    try {
      // Try to fetch from remote first (for fresh data when online)
      try {
        final stories = await remoteDataSource.getStories().timeout(
          const Duration(seconds: 5),
        );

        // Cache the stories for offline use
        if (stories.isNotEmpty) {
          await localStorageService.cacheStories(stories);
        }

        return Right(stories);
      } catch (e) {
        // On timeout or error, return cached data as fallback
        final cachedStories = await localStorageService.getCachedStories();
        if (cachedStories.isNotEmpty) {
          return Right(cachedStories);
        }
        return Left(
          ServerFailure(
            'Unable to load stories. Please check your connection.',
          ),
        );
      }
    } catch (e) {
      // On error, try to return cached data
      final cachedStories = await localStorageService.getCachedStories();
      if (cachedStories.isNotEmpty) {
        return Right(cachedStories);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  // Background fetch and cache for stories
  Future<void> _fetchAndCacheStories() async {
    try {
      final isConnected = await connectivityService.isConnected();
      if (isConnected) {
        final stories = await remoteDataSource.getStories();
        if (stories.isNotEmpty) {
          await localStorageService.cacheStories(stories);
        }
      }
    } catch (e) {
      // Silently fail background fetch
      print('Background fetch for stories failed: $e');
    }
  }

  @override
  Future<Either<Failure, void>> createPost(PostEntity post) async {
    try {
      final postModel = PostModel(
        id: post.id,
        userId: post.userId,
        userName: post.userName,
        userImage: post.userImage,
        description: post.description,
        imageUrl: post.imageUrl,
        createdAt: post.createdAt,
        likes: post.likes,
        comments: post.comments,
      );
      await remoteDataSource.createPost(postModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createStory(StoryEntity story) async {
    try {
      final storyModel = StoryModel(
        id: story.id,
        userId: story.userId,
        userName: story.userName,
        userImage: story.userImage,
        imageUrl: story.imageUrl,
        createdAt: story.createdAt,
      );
      await remoteDataSource.createStory(storyModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> likePost(String postId, String userId) async {
    try {
      await remoteDataSource.likePost(postId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String userImage,
    required String text,
  }) async {
    try {
      await remoteDataSource.addComment(
        postId: postId,
        userId: userId,
        userName: userName,
        userImage: userImage,
        text: text,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
