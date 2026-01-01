import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test_app/core/usecase/usecase.dart';
import 'package:flutter_test_app/core/utils/local_storage_service.dart';
import 'package:flutter_test_app/features/home/domain/entities/post_entity.dart';
import 'package:flutter_test_app/features/home/domain/repositories/post_repository.dart';
import 'package:flutter_test_app/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:flutter_test_app/features/home/domain/usecases/get_stories_usecase.dart';
import 'package:flutter_test_app/features/home/presentation/bloc/post_event.dart';
import 'package:flutter_test_app/features/home/presentation/bloc/post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPostsUseCase;
  final GetStoriesUseCase getStoriesUseCase;
  final PostRepository postRepository;
  final LocalStorageService localStorageService;

  PostBloc({
    required this.getPostsUseCase,
    required this.getStoriesUseCase,
    required this.postRepository,
    required this.localStorageService,
  }) : super(const PostInitial()) {
    on<GetPostsEvent>(_onGetPosts);
    on<GetStoriesEvent>(_onGetStories);
    on<LikePostEvent>(_onLikePost);
    on<AddCommentEvent>(_onAddComment);
  }

  Future<void> _onGetPosts(GetPostsEvent event, Emitter<PostState> emit) async {
    final currentState = state;

    // Instantly load cached data ONLY on first app load (PostInitial state)
    if (event.page == 1 && currentState is PostInitial) {
      final cachedPosts = localStorageService.getCachedPostsSync();
      final cachedStories = localStorageService.getCachedStoriesSync();

      if (cachedPosts.isNotEmpty) {
        // Emit cached data immediately - NO LOADING STATE!
        if (cachedStories.isNotEmpty) {
          emit(
            PostAndStoriesLoaded(posts: cachedPosts, stories: cachedStories),
          );
        } else {
          emit(PostsLoaded(posts: cachedPosts));
        }
      }
    }

    // Always fetch fresh data from network
    final postsResult = await getPostsUseCase(
      GetPostsParams(page: event.page, limit: 5),
    );

    final storiesResult = await getStoriesUseCase(const NoParams());

    postsResult.fold((failure) => emit(PostError(message: failure.message)), (
      newPosts,
    ) {
      // If loading more posts (page > 1), append to existing posts
      List<PostEntity> allPosts = newPosts;
      if (event.page > 1 && currentState is PostAndStoriesLoaded) {
        allPosts = [...currentState.posts, ...newPosts];
      } else if (event.page > 1 && currentState is PostsLoaded) {
        allPosts = [...currentState.posts, ...newPosts];
      }

      // Always emit fresh data (this updates the UI after network fetch)
      storiesResult.fold(
        (failure) => emit(PostsLoaded(posts: allPosts)),
        (stories) =>
            emit(PostAndStoriesLoaded(posts: allPosts, stories: stories)),
      );
    });
  }

  Future<void> _onGetStories(
    GetStoriesEvent event,
    Emitter<PostState> emit,
  ) async {
    // Don't emit loading to avoid disrupting posts display
    final currentState = state;
    final result = await getStoriesUseCase(const NoParams());

    result.fold(
      (failure) {
        // Keep current state on error
        if (currentState is PostAndStoriesLoaded) {
          emit(
            PostAndStoriesLoaded(
              posts: currentState.posts,
              stories: currentState.stories,
            ),
          );
        }
      },
      (stories) {
        if (currentState is PostAndStoriesLoaded) {
          emit(
            PostAndStoriesLoaded(posts: currentState.posts, stories: stories),
          );
        } else if (currentState is PostsLoaded) {
          emit(
            PostAndStoriesLoaded(posts: currentState.posts, stories: stories),
          );
        } else {
          emit(StoriesLoaded(stories: stories));
        }
      },
    );
  }

  Future<void> _onLikePost(LikePostEvent event, Emitter<PostState> emit) async {
    // Call repository to like/unlike the post
    await postRepository.likePost(event.postId, event.userId);

    // Just update the like in the current state without refetching all posts
    final currentState = state;
    if (currentState is PostAndStoriesLoaded) {
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          final likes = List<String>.from(post.likes);
          if (likes.contains(event.userId)) {
            likes.remove(event.userId);
          } else {
            likes.add(event.userId);
          }
          return post.copyWith(likes: likes);
        }
        return post;
      }).toList();
      emit(
        PostAndStoriesLoaded(
          posts: updatedPosts,
          stories: currentState.stories,
        ),
      );
      return;
    } else if (currentState is PostsLoaded) {
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          final likes = List<String>.from(post.likes);
          if (likes.contains(event.userId)) {
            likes.remove(event.userId);
          } else {
            likes.add(event.userId);
          }
          return post.copyWith(likes: likes);
        }
        return post;
      }).toList();
      emit(PostsLoaded(posts: updatedPosts));
      return;
    }

    // Fallback: refresh all posts
    final result = await getPostsUseCase(
      const GetPostsParams(page: 1, limit: 10),
    );

    result.fold((failure) => emit(PostError(message: failure.message)), (
      posts,
    ) {
      if (currentState is PostAndStoriesLoaded) {
        emit(PostAndStoriesLoaded(posts: posts, stories: currentState.stories));
      } else {
        emit(PostsLoaded(posts: posts));
      }
    });
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<PostState> emit,
  ) async {
    // Call repository to add the comment
    await postRepository.addComment(
      postId: event.postId,
      userId: event.userId,
      userName: event.userName,
      userImage: event.userImage,
      text: event.text,
    );

    // Refresh posts after comment, preserving stories
    final currentState = state;
    final result = await getPostsUseCase(
      const GetPostsParams(page: 1, limit: 5),
    );

    result.fold((failure) => emit(PostError(message: failure.message)), (
      posts,
    ) {
      if (currentState is PostAndStoriesLoaded) {
        emit(PostAndStoriesLoaded(posts: posts, stories: currentState.stories));
      } else {
        emit(PostsLoaded(posts: posts));
      }
    });
  }
}
