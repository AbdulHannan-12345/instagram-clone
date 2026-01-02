import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class ImagePreloaderService {
  static final ImagePreloaderService _instance =
      ImagePreloaderService._internal();
  factory ImagePreloaderService() => _instance;
  ImagePreloaderService._internal();

  final Set<String> _preloadingUrls = {};
  final Map<String, Completer<void>> _preloadCompleters = {};

  /// Preloads a single image into cache
  Future<void> preloadImage(String imageUrl) async {
    if (imageUrl.isEmpty || _preloadingUrls.contains(imageUrl)) {
      return;
    }

    _preloadingUrls.add(imageUrl);

    try {
      final cachedImage = CachedNetworkImageProvider(imageUrl);
      final completer = Completer<void>();

      final imageStream = cachedImage.resolve(ImageConfiguration.empty);
      imageStream.addListener(
        ImageStreamListener(
          (ImageInfo image, bool synchronousCall) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          onError: (exception, stackTrace) {
            if (!completer.isCompleted) {
              completer.completeError(exception);
            }
          },
        ),
      );

      // Wait for the image to load with timeout
      await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Image preload timeout: $imageUrl');
        },
      );
    } catch (e) {
      debugPrint('Failed to preload image: $imageUrl - $e');
    } finally {
      _preloadingUrls.remove(imageUrl);
    }
  }

  /// Preloads multiple images in parallel with limited concurrency
  Future<void> preloadImages(
    List<String> imageUrls, {
    int maxConcurrent = 3,
  }) async {
    if (imageUrls.isEmpty) return;

    final validUrls = imageUrls.where((url) => url.isNotEmpty).toList();
    if (validUrls.isEmpty) return;

    debugPrint('Starting to preload ${validUrls.length} images');

    // Process images in batches to avoid overwhelming the network
    for (int i = 0; i < validUrls.length; i += maxConcurrent) {
      final batch = validUrls.skip(i).take(maxConcurrent).toList();
      final futures = batch.map((url) => preloadImage(url));
      await Future.wait(futures);
    }

    debugPrint('Finished preloading images');
  }

  /// Preloads images for posts (post images + user profile images)
  Future<void> preloadPostImages(List<Map<String, dynamic>> posts) async {
    final imageUrls = <String>[];

    for (final post in posts) {
      // Add post image
      if (post['imageUrl'] != null && post['imageUrl'].toString().isNotEmpty) {
        imageUrls.add(post['imageUrl'].toString());
      }

      // Add user profile image
      if (post['userImage'] != null &&
          post['userImage'].toString().isNotEmpty) {
        imageUrls.add(post['userImage'].toString());
      }
    }

    await preloadImages(imageUrls);
  }

  /// Preloads images for stories (story images + user profile images)
  Future<void> preloadStoryImages(List<Map<String, dynamic>> stories) async {
    final imageUrls = <String>[];

    for (final story in stories) {
      // Add story image
      if (story['imageUrl'] != null &&
          story['imageUrl'].toString().isNotEmpty) {
        imageUrls.add(story['imageUrl'].toString());
      }

      // Add user profile image
      if (story['userImage'] != null &&
          story['userImage'].toString().isNotEmpty) {
        imageUrls.add(story['userImage'].toString());
      }
    }

    await preloadImages(imageUrls);
  }

  /// Clears the preload cache (useful for memory management)
  void clearPreloadCache() {
    _preloadingUrls.clear();
    _preloadCompleters.clear();
  }
}
