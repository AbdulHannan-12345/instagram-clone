import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test_app/core/error/failures.dart';
import 'package:flutter_test_app/core/usecase/usecase.dart';
import 'package:flutter_test_app/features/home/domain/entities/post_entity.dart';
import 'package:flutter_test_app/features/home/domain/repositories/post_repository.dart';

class GetPostsUseCase extends UseCase<List<PostEntity>, GetPostsParams> {
  final PostRepository repository;

  GetPostsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<PostEntity>>> call(GetPostsParams params) async {
    return await repository.getPosts(page: params.page, limit: params.limit);
  }
}

class GetPostsParams extends Equatable {
  final int page;
  final int limit;

  const GetPostsParams({this.page = 1, this.limit = 5});

  @override
  List<Object?> get props => [page, limit];
}
