import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test_app/core/config/supabase_config.dart';

class SupabaseStorageService {
  static final SupabaseStorageService _instance =
      SupabaseStorageService._internal();

  SupabaseStorageService._internal();

  factory SupabaseStorageService() {
    return _instance;
  }

  /// Upload profile image to Supabase Storage
  /// Returns the public URL of the uploaded file
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${SupabaseConfig.profileImagesPath}/$fileName';

      // Use upload instead of uploadBinary for file paths
      await Supabase.instance.client.storage
          .from(SupabaseConfig.s3Bucket)
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = Supabase.instance.client.storage
          .from(SupabaseConfig.s3Bucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Upload post image to Supabase Storage
  /// Returns the public URL of the uploaded file
  Future<String> uploadPostImage(File imageFile, String userId) async {
    try {
      final fileName =
          'post_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${SupabaseConfig.postsPath}/$fileName';

      // Use upload instead of uploadBinary for file paths
      await Supabase.instance.client.storage
          .from(SupabaseConfig.s3Bucket)
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = Supabase.instance.client.storage
          .from(SupabaseConfig.s3Bucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading post image: $e');
      throw Exception('Failed to upload post image: $e');
    }
  }

  /// Upload story image to Supabase Storage
  /// Returns the public URL of the uploaded file
  Future<String> uploadStoryImage(File imageFile, String userId) async {
    try {
      final fileName =
          'story_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${SupabaseConfig.storiesPath}/$fileName';

      // Use upload instead of uploadBinary for file paths
      await Supabase.instance.client.storage
          .from(SupabaseConfig.s3Bucket)
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = Supabase.instance.client.storage
          .from(SupabaseConfig.s3Bucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload story image: $e');
    }
  }

  /// Delete file from Supabase Storage
  Future<void> deleteFile(String filePath) async {
    try {
      await Supabase.instance.client.storage
          .from(SupabaseConfig.s3Bucket)
          .remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}
