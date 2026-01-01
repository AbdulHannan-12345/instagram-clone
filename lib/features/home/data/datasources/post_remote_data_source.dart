import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test_app/features/home/data/models/post_model.dart';
import 'package:flutter_test_app/features/home/data/models/story_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts({
    int page = 1,
    int limit = 5,
    DocumentSnapshot? lastDocument,
  });
  Future<List<StoryModel>> getStories();
  Future<void> createPost(PostModel post);
  Future<void> createStory(StoryModel story);
  Future<void> likePost(String postId, String userId);
  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String userImage,
    required String text,
  });
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final FirebaseFirestore firestore;
  DocumentSnapshot? _lastDocument;

  PostRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<PostModel>> getPosts({
    int page = 1,
    int limit = 5,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      // Reset pagination when starting fresh (page 1)
      if (page == 1) {
        _lastDocument = null;
      }

      Query query = firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // Use stored _lastDocument for pagination when page > 1
      if (page > 1 && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      // Store last document for next pagination
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  DocumentSnapshot? get lastDocument => _lastDocument;

  void resetPagination() {
    _lastDocument = null;
  }

  @override
  Future<List<StoryModel>> getStories() async {
    try {
      final snapshot = await firestore
          .collection('stories')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => StoryModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createPost(PostModel post) async {
    try {
      await firestore.collection('posts').doc(post.id).set(post.toMap());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createStory(StoryModel story) async {
    try {
      await firestore.collection('stories').doc(story.id).set(story.toMap());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    try {
      final postRef = firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();

      if (postDoc.exists) {
        final data = postDoc.data()!;
        final likes = List<String>.from(data['likes'] ?? []);

        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }

        await postRef.update({'likes': likes});
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String userImage,
    required String text,
  }) async {
    try {
      final postRef = firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();

      if (postDoc.exists) {
        final data = postDoc.data()!;
        final comments = List<Map<String, dynamic>>.from(
          data['comments'] ?? [],
        );

        comments.add({
          'userId': userId,
          'userName': userName,
          'userImage': userImage,
          'text': text,
          'createdAt': DateTime.now().toIso8601String(),
        });

        await postRef.update({'comments': comments});
      }
    } catch (e) {
      rethrow;
    }
  }
}
