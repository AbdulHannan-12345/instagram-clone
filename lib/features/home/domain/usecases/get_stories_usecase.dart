import 'package:dartz/dartz.dart';
import 'package:flutter_test_app/core/error/failures.dart';
import 'package:flutter_test_app/core/usecase/usecase.dart';
import 'package:flutter_test_app/features/home/domain/entities/story_entity.dart';
import 'package:flutter_test_app/features/home/domain/repositories/post_repository.dart';

class GetStoriesUseCase extends UseCase<List<StoryEntity>, NoParams> {
  final PostRepository repository;

  GetStoriesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<StoryEntity>>> call(NoParams params) async {
    return await repository.getStories();
  }
}
