import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:video_compress/video_compress.dart';

class CompressionService {
  static final CompressionService _instance = CompressionService._internal();

  CompressionService._internal();

  factory CompressionService() {
    return _instance;
  }

  /// Smart compression with dynamic quality based on file size
  /// Automatically optimizes compression for large images
  Future<File> compressImageSmart(
    File imageFile, {
    int? targetWidth,
    bool isStory = false,
  }) async {
    try {
      // Get original file size
      final originalSize = await imageFile.length();
      final originalSizeMB = originalSize / (1024 * 1024);

      print('📸 Smart Image Compression Started');
      print(
        'Original size: ${originalSizeMB.toStringAsFixed(2)} MB ($originalSize bytes)',
      );

      // Determine quality based on file size (more aggressive for larger files)
      int quality;
      int effectiveTargetWidth;

      if (originalSizeMB > 10) {
        quality = 35; // Very aggressive for >10MB
        effectiveTargetWidth = isStory ? 720 : 960;
        print(
          '🔥 Large file detected (>10MB): Using aggressive compression (quality: $quality, width: $effectiveTargetWidth)',
        );
      } else if (originalSizeMB > 5) {
        quality = 45;
        effectiveTargetWidth = isStory ? 720 : 1080;
        print(
          '⚡ Medium-large file (5-10MB): Using high compression (quality: $quality, width: $effectiveTargetWidth)',
        );
      } else if (originalSizeMB > 2) {
        quality = 60;
        effectiveTargetWidth = isStory ? 720 : 1080;
        print(
          '📊 Medium file (2-5MB): Using moderate compression (quality: $quality, width: $effectiveTargetWidth)',
        );
      } else {
        quality = 75;
        effectiveTargetWidth = isStory ? 720 : 1080;
        print(
          '✨ Small file (<2MB): Using light compression (quality: $quality, width: $effectiveTargetWidth)',
        );
      }

      // Override with custom targetWidth if provided
      if (targetWidth != null) {
        effectiveTargetWidth = targetWidth;
      }

      // Read and decode image
      final imageData = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageData);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      print('Original dimensions: ${image.width}x${image.height}');

      // Resize image if width exceeds target
      if (image.width > effectiveTargetWidth) {
        final newHeight = (image.height * effectiveTargetWidth / image.width)
            .toInt();
        image = img.copyResize(
          image,
          width: effectiveTargetWidth,
          height: newHeight,
          interpolation: img.Interpolation.linear,
        );
        print('Resized to: ${image.width}x${image.height}');
      }

      // Encode with calculated quality
      final compressedImage = img.encodeJpg(image, quality: quality);

      // Save compressed image
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(compressedImage);

      // Calculate compression stats
      final compressedSize = await tempFile.length();
      final compressedSizeMB = compressedSize / (1024 * 1024);
      final compressionPercentage =
          ((originalSize - compressedSize) / originalSize * 100);
      final spaceSaved = (originalSize - compressedSize) / (1024 * 1024);

      print(
        'Compressed size: ${compressedSizeMB.toStringAsFixed(2)} MB ($compressedSize bytes)',
      );
      print(
        '✅ Compression: ${compressionPercentage.toStringAsFixed(2)}% reduction',
      );
      print('💾 Space saved: ${spaceSaved.toStringAsFixed(2)} MB');
      print('🎯 Final quality used: $quality');
      print('---');

      return tempFile;
    } catch (e) {
      throw Exception('Image compression failed: $e');
    }
  }

  /// Legacy compress image method (for backward compatibility)
  /// Quality: 0-100 (default 70)
  /// targetWidth: width for resizing (optional)
  Future<File> compressImage(
    File imageFile, {
    int quality = 70,
    int? targetWidth,
  }) async {
    try {
      // Get original file size
      final originalSize = await imageFile.length();
      final originalSizeMB = originalSize / (1024 * 1024);
      print('📸 Image Compression Started');
      print(
        'Original size: ${originalSizeMB.toStringAsFixed(2)} MB ($originalSize bytes)',
      );

      // Read image file
      final imageData = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageData);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if targetWidth provided
      if (targetWidth != null) {
        image = img.copyResize(
          image,
          width: targetWidth,
          height: (image.height * targetWidth / image.width).toInt(),
          interpolation: img.Interpolation.linear,
        );
      }

      // Encode and compress
      final compressedImage = img.encodeJpg(image, quality: quality);

      // Save compressed image to temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(compressedImage);

      // Get compressed file size and calculate compression percentage
      final compressedSize = await tempFile.length();
      final compressedSizeMB = compressedSize / (1024 * 1024);
      final compressionPercentage =
          ((originalSize - compressedSize) / originalSize * 100);

      print(
        'Compressed size: ${compressedSizeMB.toStringAsFixed(2)} MB ($compressedSize bytes)',
      );
      print(
        '✅ Compression: ${compressionPercentage.toStringAsFixed(2)}% reduction',
      );
      print(
        'Space saved: ${((originalSize - compressedSize) / (1024 * 1024)).toStringAsFixed(2)} MB',
      );
      print('---');

      return tempFile;
    } catch (e) {
      throw Exception('Image compression failed: $e');
    }
  }

  /// Compress video file
  /// Returns the path to compressed video
  Future<String?> compressVideo(
    String videoPath, {
    VideoQuality quality = VideoQuality.MediumQuality,
  }) async {
    try {
      // Get original file size
      final originalFile = File(videoPath);
      final originalSize = await originalFile.length();
      final originalSizeMB = originalSize / (1024 * 1024);
      print('🎥 Video Compression Started');
      print(
        'Original size: ${originalSizeMB.toStringAsFixed(2)} MB ($originalSize bytes)',
      );

      final compressedVideo = await VideoCompress.compressVideo(
        videoPath,
        quality: quality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (compressedVideo == null || compressedVideo.file == null) {
        throw Exception('Video compression failed');
      }

      // Get compressed file size and calculate compression percentage
      final compressedSize = await compressedVideo.file!.length();
      final compressedSizeMB = compressedSize / (1024 * 1024);
      final compressionPercentage =
          ((originalSize - compressedSize) / originalSize * 100);

      print(
        'Compressed size: ${compressedSizeMB.toStringAsFixed(2)} MB ($compressedSize bytes)',
      );
      print(
        '✅ Compression: ${compressionPercentage.toStringAsFixed(2)}% reduction',
      );
      print(
        'Space saved: ${((originalSize - compressedSize) / (1024 * 1024)).toStringAsFixed(2)} MB',
      );
      print('---');

      return compressedVideo.file?.path;
    } catch (e) {
      throw Exception('Video compression failed: $e');
    }
  }

  /// Get compression progress
  Stream<double?> getCompressionProgress() {
    return VideoCompress.compressProgress$ as Stream<double?>;
  }

  /// Cancel ongoing compression
  Future<void> cancelCompression() async {
    await VideoCompress.cancelCompression();
  }

  /// Delete temporary compressed file
  Future<void> deleteTempFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silent fail - file may have already been deleted
    }
  }
}
