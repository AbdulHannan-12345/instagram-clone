import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_test_app/core/utils/image_picker_service.dart';
import 'package:flutter_test_app/core/utils/compression_service.dart';
import 'package:flutter_test_app/core/utils/supabase_storage_service.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test_app/features/home/domain/entities/story_entity.dart';
import 'package:flutter_test_app/features/home/domain/repositories/post_repository.dart';
import 'package:flutter_test_app/service_locator/service_locator.dart';

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({super.key});

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImageFromGallery() async {
    try {
      final file = await ImagePickerService.pickImageFromGallery();
      if (file != null) {
        setState(() {
          _selectedImage = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final file = await ImagePickerService.pickImageFromCamera();
      if (file != null) {
        setState(() {
          _selectedImage = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  Future<void> _uploadStory() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or take a photo')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthSuccess) {
        throw Exception('User not authenticated');
      }

      // Compress image with smart compression optimized for stories
      final compressedImage = await CompressionService().compressImageSmart(
        _selectedImage!,
        isStory: true, // Optimized for story format
      );

      // Upload to Supabase
      final storageService = SupabaseStorageService();
      final imageUrl = await storageService.uploadStoryImage(
        compressedImage,
        authState.user.uid,
      );

      // Create story entity
      final storyEntity = StoryEntity(
        id: const Uuid().v4(),
        userId: authState.user.uid,
        userName: authState.user.name ?? 'Unknown',
        userImage: authState.user.profileImageUrl ?? '',
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      final postRepository = getIt<PostRepository>();
      final result = await postRepository.createStory(storyEntity);

      result.fold((failure) => throw Exception(failure.message), (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Story uploaded successfully!')),
          );
          Navigator.pop(context, true);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading story: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Add Story',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _selectedImage == null
          ? _buildMediaSelector()
          : _buildPreviewScreen(),
    );
  }

  Widget _buildMediaSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_back_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          const Text(
            'Add to your story',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Share a photo or video to your story',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 280,
            child: ElevatedButton.icon(
              onPressed: _pickImageFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take a Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 280,
            child: ElevatedButton.icon(
              onPressed: _pickImageFromGallery,
              icon: const Icon(Icons.image),
              label: const Text('Choose from Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewScreen() {
    return Stack(
      children: [
        // Full screen image preview
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Image.file(_selectedImage!, fit: BoxFit.contain),
        ),
        // Bottom buttons
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
                    child: const Text(
                      'Change',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _uploadStory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Share',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
