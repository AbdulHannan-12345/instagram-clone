import 'package:dartz/dartz.dart';
import 'package:flutter_test_app/core/error/failures.dart';
import 'package:flutter_test_app/core/usecase/usecase.dart';
import 'package:flutter_test_app/features/home/domain/entities/post_entity.dart';
import 'package:flutter_test_app/features/home/domain/repositories/post_repository.dart';

class CreatePostUseCase extends UseCase<void, CreatePostParams> {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreatePostParams params) {
    return repository.createPost(params.post);
  }
}

class CreatePostParams {
  final PostEntity post;

  CreatePostParams({required this.post});
}
