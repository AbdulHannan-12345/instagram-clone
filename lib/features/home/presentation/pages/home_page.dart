import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test_app/core/utils/connectivity_service.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:flutter_test_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test_app/features/home/domain/entities/story_entity.dart';
import 'package:flutter_test_app/features/home/presentation/bloc/post_bloc.dart';
import 'package:flutter_test_app/features/home/presentation/bloc/post_event.dart';
import 'package:flutter_test_app/features/home/presentation/bloc/post_state.dart';
import 'package:flutter_test_app/features/home/presentation/pages/add_story_page.dart';
import 'package:flutter_test_app/features/home/presentation/pages/create_post_page.dart';
import 'package:flutter_test_app/features/home/presentation/pages/user_profile_page.dart';
import 'package:flutter_test_app/features/home/presentation/widgets/post_widget.dart';
import 'package:flutter_test_app/features/home/presentation/widgets/story_widget.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final ConnectivityService _connectivityService = ConnectivityService();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // Load posts and stories
    context.read<PostBloc>().add(GetPostsEvent(page: _currentPage));
    context.read<PostBloc>().add(const GetStoriesEvent());

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Monitor connectivity changes
    _checkInitialConnectivity();
    _connectivitySubscription = _connectivityService.connectivityStream.listen((
      results,
    ) {
      _handleConnectivityChange(results);
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final isConnected = await _connectivityService.isConnected();
    if (mounted) {
      setState(() {
        _isOffline = !isConnected;
      });
    }
  }

  Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final isConnected = await _connectivityService.isConnected();
    if (mounted) {
      setState(() {
        _isOffline = !isConnected;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    // Check if scrolled to bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  void _loadMorePosts() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    context.read<PostBloc>().add(GetPostsEvent(page: _currentPage));

    // Reset loading flag after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _currentPage = 1;
      _isLoadingMore = false;
    });
    context.read<PostBloc>().add(GetPostsEvent(page: _currentPage));
    context.read<PostBloc>().add(const GetStoriesEvent());
    // Wait for a short delay to allow the BLoC to process
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Map<String, List<StoryEntity>> _groupStoriesByUser(
    List<StoryEntity> stories,
  ) {
    final Map<String, List<StoryEntity>> groupedStories = {};
    for (var story in stories) {
      if (groupedStories.containsKey(story.userId)) {
        groupedStories[story.userId]!.add(story);
      } else {
        groupedStories[story.userId] = [story];
      }
    }
    return groupedStories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostPage()),
            );
          },
          icon: Icon(Icons.add),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Instagram',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        bottom: _isOffline
            ? PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Container(
                  color: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'You are currently offline',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.favorite_border, color: Colors.black),
        //     onPressed: () {},
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Stories Section
              SizedBox(
                height: 130,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    return BlocBuilder<PostBloc, PostState>(
                      builder: (context, postState) {
                        List<StoryEntity> allStories = [];

                        if (postState is StoriesLoaded) {
                          allStories = postState.stories;
                        } else if (postState is PostAndStoriesLoaded) {
                          allStories = postState.stories;
                        }

                        // Group stories by user
                        final groupedStories = _groupStoriesByUser(allStories);

                        if (authState is AuthSuccess) {
                          final currentUserId = authState.user.uid;
                          final userStories =
                              groupedStories[currentUserId] ?? [];

                          // Create own story entity
                          final ownStory = StoryEntity(
                            id: 'own_story',
                            userId: currentUserId,
                            userName: authState.user.name ?? 'User',
                            userImage:
                                authState.user.profileImageUrl ??
                                'https://i.pravatar.cc/150?img=1',
                            imageUrl: userStories.isNotEmpty
                                ? userStories.first.imageUrl
                                : '',
                            createdAt: DateTime.now(),
                          );

                          // Get other users' stories (one representative per user)
                          final otherUsersStories = groupedStories.entries
                              .where((entry) => entry.key != currentUserId)
                              .map((entry) => entry.value.first)
                              .toList();

                          return ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            children: [
                              // Own story first
                              StoryWidget(
                                story: ownStory,
                                isOwnStory: true,
                                userStories: userStories,
                                onAddStory: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AddStoryPage(),
                                    ),
                                  );
                                },
                              ),
                              // Other users' stories
                              ...otherUsersStories.map(
                                (story) => StoryWidget(
                                  story: story,
                                  userStories:
                                      groupedStories[story.userId] ?? [story],
                                ),
                              ),
                            ],
                          );
                        }

                        // Show stories even if not authenticated
                        final otherUsersStories = groupedStories.entries
                            .map((entry) => entry.value.first)
                            .toList();

                        return ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: otherUsersStories
                              .map(
                                (story) => StoryWidget(
                                  story: story,
                                  userStories:
                                      groupedStories[story.userId] ?? [story],
                                ),
                              )
                              .toList(),
                        );
                      },
                    );
                  },
                ),
              ),
              Divider(color: Colors.grey[300]),
              // Posts Section
              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  if (state is PostLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is PostsLoaded) {
                    if (state.posts.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No posts yet. Be the first to post!',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }
                    return Column(
                      children: state.posts
                          .map((post) => PostWidget(post: post))
                          .toList(),
                    );
                  } else if (state is PostAndStoriesLoaded) {
                    if (state.posts.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No posts yet. Be the first to post!',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }
                    return Column(
                      children: state.posts
                          .map((post) => PostWidget(post: post))
                          .toList(),
                    );
                  } else if (state is PostError) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Error: ${state.message}'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.read<PostBloc>().add(
                                const GetPostsEvent(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  // Initial state - show loading
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey[50],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            // Home - refresh posts and stories
            setState(() {
              _currentPage = 1;
              _isLoadingMore = false;
            });
            context.read<PostBloc>().add(GetPostsEvent(page: _currentPage));
            context.read<PostBloc>().add(const GetStoriesEvent());
          } else if (index == 1) {
            // Create Post
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostPage()),
            );
          } else if (index == 2) {
            // Profile
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
