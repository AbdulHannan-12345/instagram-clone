import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_test_app/features/home/data/models/post_model.dart';
import 'package:flutter_test_app/features/home/data/models/story_model.dart';

class LocalStorageService {
  static const String _postsBox = 'offline_posts_cache';
  static const String _storiesBox = 'offline_stories_cache';
  static const String _viewedStoriesBox = 'viewed_stories_cache';

  /// Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_postsBox);
    await Hive.openBox(_storiesBox);
    await Hive.openBox(_viewedStoriesBox);
  }

  /// Cache posts to local storage
  Future<void> cachePosts(List<PostModel> posts) async {
    try {
      final box = Hive.box(_postsBox);
      final postsJson = posts.map((post) => post.toMap()).toList();
      await box.put('cached_posts', postsJson);
      await box.put('last_updated', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching posts: $e');
    }
  }

  /// Get cached posts from local storage
  Future<List<PostModel>> getCachedPosts() async {
    try {
      final box = Hive.box(_postsBox);
      final postsJson = box.get('cached_posts') as List<dynamic>?;

      if (postsJson == null) return [];

      return postsJson
          .map((json) => PostModel.fromMap(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      print('Error getting cached posts: $e');
      return [];
    }
  }

  /// Get cached posts synchronously (instant, no await needed)
  List<PostModel> getCachedPostsSync() {
    try {
      final box = Hive.box(_postsBox);
      final postsJson = box.get('cached_posts') as List<dynamic>?;

      if (postsJson == null) return [];

      return postsJson
          .map((json) => PostModel.fromMap(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      print('Error getting cached posts: $e');
      return [];
    }
  }

  /// Cache stories to local storage
  Future<void> cacheStories(List<StoryModel> stories) async {
    try {
      final box = Hive.box(_storiesBox);
      final storiesJson = stories.map((story) => story.toMap()).toList();
      await box.put('cached_stories', storiesJson);
      await box.put('last_updated', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching stories: $e');
    }
  }

  /// Get cached stories from local storage
  Future<List<StoryModel>> getCachedStories() async {
    try {
      final box = Hive.box(_storiesBox);
      final storiesJson = box.get('cached_stories') as List<dynamic>?;

      if (storiesJson == null) return [];

      return storiesJson
          .map((json) => StoryModel.fromMap(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      print('Error getting cached stories: $e');
      return [];
    }
  }

  /// Get cached stories synchronously (instant, no await needed)
  List<StoryModel> getCachedStoriesSync() {
    try {
      final box = Hive.box(_storiesBox);
      final storiesJson = box.get('cached_stories') as List<dynamic>?;

      if (storiesJson == null) return [];

      return storiesJson
          .map((json) => StoryModel.fromMap(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      print('Error getting cached stories: $e');
      return [];
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      await Hive.box(_postsBox).clear();
      await Hive.box(_storiesBox).clear();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Check if cache is available
  Future<bool> hasCachedPosts() async {
    try {
      final box = Hive.box(_postsBox);
      return box.get('cached_posts') != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if stories cache is available
  Future<bool> hasCachedStories() async {
    try {
      final box = Hive.box(_storiesBox);
      return box.get('cached_stories') != null;
    } catch (e) {
      return false;
    }
  }

  /// Save viewed stories (user IDs)
  Future<void> saveViewedStories(Set<String> viewedUserIds) async {
    try {
      final box = Hive.box(_viewedStoriesBox);
      await box.put('viewed_stories', viewedUserIds.toList());
    } catch (e) {
      print('Error saving viewed stories: $e');
    }
  }

  /// Load viewed stories (user IDs)
  Future<Set<String>> loadViewedStories() async {
    try {
      final box = Hive.box(_viewedStoriesBox);
      final viewedList = box.get('viewed_stories') as List<dynamic>?;
      if (viewedList == null) return {};
      return viewedList.map((id) => id.toString()).toSet();
    } catch (e) {
      print('Error loading viewed stories: $e');
      return {};
    }
  }

  /// Add viewed story for a user
  Future<void> addViewedStory(String userId) async {
    try {
      final currentViewed = await loadViewedStories();
      currentViewed.add(userId);
      await saveViewedStories(currentViewed);
    } catch (e) {
      print('Error adding viewed story: $e');
    }
  }

  /// Check if story is viewed for a user
  Future<bool> isStoryViewed(String userId) async {
    try {
      final viewedStories = await loadViewedStories();
      return viewedStories.contains(userId);
    } catch (e) {
      return false;
    }
  }

  /// Clear viewed stories
  Future<void> clearViewedStories() async {
    try {
      final box = Hive.box(_viewedStoriesBox);
      await box.clear();
    } catch (e) {
      print('Error clearing viewed stories: $e');
    }
  }
}
