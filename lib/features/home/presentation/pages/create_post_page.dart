import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_test_app/core/utils/image_picker_service.dart';
import 'package:flutter_test_app/core/utils/compression_service.dart';
import 'package:flutter_test_app/core/utils/supabase_storage_service.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test_app/features/home/domain/entities/post_entity.dart';
import 'package:flutter_test_app/features/home/domain/repositories/post_repository.dart';
import 'package:flutter_test_app/service_locator/service_locator.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late TextEditingController _descriptionController;
  File? _selectedMedia;
  bool _isImage = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = source == ImageSource.gallery
          ? await ImagePickerService.pickImageFromGallery()
          : await ImagePickerService.pickImageFromCamera();
      if (file != null) {
        setState(() {
          _selectedMedia = file;
          _isImage = true;
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

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final file = source == ImageSource.gallery
          ? await ImagePickerService.pickVideoFromGallery()
          : await ImagePickerService.pickVideoFromCamera();
      if (file != null) {
        setState(() {
          _selectedMedia = file;
          _isImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking video: $e')));
      }
    }
  }

  void _showMediaPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Media',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Video from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _publishPost() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    if (_selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image or video')),
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

      File mediaToUpload = _selectedMedia!;

      if (_isImage) {
        mediaToUpload = await CompressionService().compressImageSmart(
          _selectedMedia!,
          isStory: false, // Optimized for post format
        );
      } else {
        final compressedPath = await CompressionService().compressVideo(
          _selectedMedia!.path,
        );
        if (compressedPath != null) {
          mediaToUpload = File(compressedPath);
        }
      }

      final storageService = SupabaseStorageService();
      final mediaUrl = await storageService.uploadPostImage(
        mediaToUpload,
        authState.user.uid,
      );

      final postEntity = PostEntity(
        id: const Uuid().v4(),
        userId: authState.user.uid,
        userName: authState.user.name ?? 'Unknown',
        userImage: authState.user.profileImageUrl ?? '',
        description: _descriptionController.text,
        imageUrl: mediaUrl,
        createdAt: DateTime.now(),
        likes: const [],
        comments: const [],
      );

      final postRepository = getIt<PostRepository>();
      final result = await postRepository.createPost(postEntity);

      result.fold((failure) => throw Exception(failure.message), (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post published successfully!')),
          );
          Navigator.pop(context, true);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          'Create Post',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _publishPost,
            child: Text(
              'Share',
              style: TextStyle(
                color: Colors.blue[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_selectedMedia != null)
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.black,
                child: _isImage
                    ? Image.file(_selectedMedia!, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
              ),
            if (_selectedMedia != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showMediaPickerBottomSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                    ),
                    child: const Text(
                      'Change Media',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            if (_selectedMedia == null)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No media selected',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select an image or video to get started',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _showMediaPickerBottomSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                        ),
                        child: const Text(
                          'Select Media',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _descriptionController,
                enabled: !_isLoading,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
