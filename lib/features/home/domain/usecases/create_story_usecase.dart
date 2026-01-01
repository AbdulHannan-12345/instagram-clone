import 'package:dartz/dartz.dart';
import 'package:flutter_test_app/core/error/failures.dart';
import 'package:flutter_test_app/core/usecase/usecase.dart';
import 'package:flutter_test_app/features/home/domain/entities/story_entity.dart';
import 'package:flutter_test_app/features/home/domain/repositories/post_repository.dart';

class CreateStoryUseCase extends UseCase<void, CreateStoryParams> {
  final PostRepository repository;

  CreateStoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateStoryParams params) {
    return repository.createStory(params.story);
  }
}

class CreateStoryParams {
  final StoryEntity story;

  CreateStoryParams({required this.story});
}
