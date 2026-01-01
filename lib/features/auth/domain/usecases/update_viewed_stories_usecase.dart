import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test_app/core/error/failures.dart';
import 'package:flutter_test_app/core/usecase/usecase.dart';
import 'package:flutter_test_app/features/auth/domain/repositories/auth_repository.dart';

class UpdateViewedStoriesUseCase
    extends UseCase<void, UpdateViewedStoriesParams> {
  final AuthRepository repository;

  UpdateViewedStoriesUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(UpdateViewedStoriesParams params) async {
    return await repository.updateViewedStories(
      uid: params.uid,
      viewedStories: params.viewedStories,
    );
  }
}

class UpdateViewedStoriesParams extends Equatable {
  final String uid;
  final List<String> viewedStories;

  const UpdateViewedStoriesParams({
    required this.uid,
    required this.viewedStories,
  });

  @override
  List<Object?> get props => [uid, viewedStories];
}
