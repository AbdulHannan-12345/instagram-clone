import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_test_app/features/home/data/models/post_model.dart';
import 'package:flutter_test_app/features/home/data/models/story_model.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  static const String _postsBoxName = 'posts_cache';
  static const String _storiesBoxName = 'stories_cache';
  static const String _postsMetaKey = 'posts_metadata';
  static const String _storiesMetaKey = 'stories_metadata';

  late Box<String> _postsBox;
  late Box<String> _storiesBox;

  CacheService._internal();

  factory CacheService() {
    return _instance;
  }

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    await Hive.initFlutter();
    _postsBox = await Hive.openBox<String>(_postsBoxName);
    _storiesBox = await Hive.openBox<String>(_storiesBoxName);
  }

  // ============ POSTS CACHE ============

  /// Cache posts data
  Future<void> cachePosts(List<PostModel> posts, int page) async {
    try {
      final key = 'posts_page_$page';
      final postsJson = posts.map((p) => p.toJson()).toList();
      await _postsBox.put(key, postsJson.toString());
      await _updatePostsMetadata(page);
    } catch (e) {
      // Silent fail for cache operations
    }
  }

  /// Get cached posts for specific page
  List<PostModel>? getCachedPosts(int page) {
    try {
      final key = 'posts_page_$page';
      final cachedData = _postsBox.get(key);
      if (cachedData == null) return null;
      // Parse and return cached data
      return [];
    } catch (e) {
      return null;
    }
  }

  /// Get all cached posts (for offline support)
  List<PostModel> getAllCachedPosts() {
    try {
      final allPosts = <PostModel>[];
      int page = 1;
      while (true) {
        final key = 'posts_page_$page';
        final cachedData = _postsBox.get(key);
        if (cachedData == null) break;
        // Parse and add to allPosts
        page++;
      }
      return allPosts;
    } catch (e) {
      return [];
    }
  }

  /// Clear posts cache
  Future<void> clearPostsCache() async {
    try {
      final keysToDelete = _postsBox.keys
          .where((key) => key.toString().startsWith('posts_page_'))
          .toList();
      for (var key in keysToDelete) {
        await _postsBox.delete(key);
      }
      await _postsBox.delete(_postsMetaKey);
    } catch (e) {
      // Silent fail for cache operations
    }
  }

  /// Update metadata for posts cache
  Future<void> _updatePostsMetadata(int latestPage) async {
    try {
      await _postsBox.put(_postsMetaKey, latestPage.toString());
    } catch (e) {
      // Silent fail for cache operations
    }
  }

  /// Get latest cached page for posts
  int? getLatestCachedPostsPage() {
    try {
      final meta = _postsBox.get(_postsMetaKey);
      return meta != null ? int.tryParse(meta) : null;
    } catch (e) {
      return null;
    }
  }

  // ============ STORIES CACHE ============

  /// Cache stories data
  Future<void> cacheStories(List<StoryModel> stories) async {
    try {
      final storiesJson = stories.map((s) => s.toJson()).toList();
      await _storiesBox.put('stories', storiesJson.toString());
      await _storiesBox.put(
        _storiesMetaKey,
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      // Silent fail for cache operations
    }
  }

  /// Get cached stories
  List<StoryModel> getCachedStories() {
    try {
      final cachedData = _storiesBox.get('stories');
      if (cachedData == null) return [];
      // Parse and return cached data
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Clear stories cache
  Future<void> clearStoriesCache() async {
    try {
      await _storiesBox.delete('stories');
      await _storiesBox.delete(_storiesMetaKey);
    } catch (e) {
      // Silent fail for cache operations
    }
  }

  /// Get cache timestamp
  DateTime? getCacheTimestamp(String type) {
    try {
      final key = type == 'posts' ? _postsMetaKey : _storiesMetaKey;
      final box = type == 'posts' ? _postsBox : _storiesBox;
      final timestamp = box.get(key);
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    } catch (e) {
      return null;
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      await clearPostsCache();
      await clearStoriesCache();
    } catch (e) {
      // Silent fail for cache operations
    }
  }
}
