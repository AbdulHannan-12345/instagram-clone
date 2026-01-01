import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test_app/core/error/failures.dart';
import 'package:flutter_test_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_test_app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
        name: name,
      );
      return Right(user);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    required String uid,
    required String name,
    String? profileImageUrl,
  }) async {
    try {
      await remoteDataSource.updateUserProfile(
        uid: uid,
        name: name,
        profileImageUrl: profileImageUrl,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfileWithImage({
    required String uid,
    required String name,
    required File imageFile,
  }) async {
    try {
      await remoteDataSource.updateUserProfileWithImage(
        uid: uid,
        name: name,
        imageFile: imageFile,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateViewedStories({
    required String uid,
    required List<String> viewedStories,
  }) async {
    try {
      await remoteDataSource.updateViewedStories(
        uid: uid,
        viewedStories: viewedStories,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
