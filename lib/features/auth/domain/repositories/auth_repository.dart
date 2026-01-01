import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test_app/core/error/failures.dart';
import 'package:flutter_test_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> updateUserProfile({
    required String uid,
    required String name,
    String? profileImageUrl,
  });

  Future<Either<Failure, void>> updateUserProfileWithImage({
    required String uid,
    required String name,
    required File imageFile,
  });

  Future<Either<Failure, void>> updateViewedStories({
    required String uid,
    required List<String> viewedStories,
  });
}
