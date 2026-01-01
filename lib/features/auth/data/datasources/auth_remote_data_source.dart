import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test_app/features/auth/data/models/user_model.dart';
import 'package:flutter_test_app/core/utils/supabase_storage_service.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<UserModel> signIn({required String email, required String password});

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<void> updateUserProfile({
    required String uid,
    required String name,
    String? profileImageUrl,
  });

  Future<void> updateUserProfileWithImage({
    required String uid,
    required String name,
    required File imageFile,
  });

  Future<void> updateViewedStories({
    required String uid,
    required List<String> viewedStories,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('User creation failed');

      final userModel = UserModel(
        uid: user.uid,
        email: email,
        name: name,
        profileImageUrl: null,
        createdAt: DateTime.now(),
      );

      await firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Sign in failed');

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) throw Exception('User data not found');

      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    String? profileImageUrl,
  }) async {
    try {
      await firestore.collection('users').doc(uid).update({
        'name': name,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfileWithImage({
    required String uid,
    required String name,
    required File imageFile,
  }) async {
    try {
      // Upload image to Supabase S3 storage
      final storageService = SupabaseStorageService();
      final imageUrl = await storageService.uploadProfileImage(imageFile, uid);

      // Update user profile in Firestore with new image URL
      await firestore.collection('users').doc(uid).update({
        'name': name,
        'profileImageUrl': imageUrl,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateViewedStories({
    required String uid,
    required List<String> viewedStories,
  }) async {
    try {
      await firestore.collection('users').doc(uid).update({
        'viewedStories': viewedStories,
      });
    } catch (e) {
      rethrow;
    }
  }
}
