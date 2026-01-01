import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_test_app/core/utils/connectivity_service.dart';
import 'package:flutter_test_app/core/utils/local_storage_service.dart';
import 'package:flutter_test_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_test_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_test_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutter_test_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:flutter_test_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:flutter_test_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test_app/features/home/data/datasources/post_remote_data_source.dart';
import 'package:flutter_test_app/features/home/data/repositories/post_repository_impl.dart';
import 'package:flutter_test_app/features/home/domain/repositories/post_repository.dart';
import 'package:flutter_test_app/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:flutter_test_app/features/home/domain/usecases/get_stories_usecase.dart';
import 'package:flutter_test_app/features/home/presentation/bloc/post_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core Services
  getIt.registerSingleton<ConnectivityService>(ConnectivityService());
  getIt.registerSingleton<LocalStorageService>(LocalStorageService());

  // Firebase
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  getIt.registerSingleton<FirebaseAuth>(firebaseAuth);
  getIt.registerSingleton<FirebaseFirestore>(firestore);

  // Auth DataSources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Auth Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );

  // Auth UseCases
  getIt.registerSingleton<SignUpUseCase>(
    SignUpUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerSingleton<SignInUseCase>(
    SignInUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerSingleton<SignOutUseCase>(
    SignOutUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetCurrentUserUseCase>(
    GetCurrentUserUseCase(repository: getIt<AuthRepository>()),
  );

  // Auth BLoC
  getIt.registerSingleton<AuthBloc>(
    AuthBloc(
      signUpUseCase: getIt<SignUpUseCase>(),
      signInUseCase: getIt<SignInUseCase>(),
      signOutUseCase: getIt<SignOutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );

  // Post DataSources
  getIt.registerSingleton<PostRemoteDataSource>(
    PostRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  // Post Repositories
  getIt.registerSingleton<PostRepository>(
    PostRepositoryImpl(
      remoteDataSource: getIt<PostRemoteDataSource>(),
      localStorageService: getIt<LocalStorageService>(),
      connectivityService: getIt<ConnectivityService>(),
    ),
  );

  // Post UseCases
  getIt.registerSingleton<GetPostsUseCase>(
    GetPostsUseCase(repository: getIt<PostRepository>()),
  );
  getIt.registerSingleton<GetStoriesUseCase>(
    GetStoriesUseCase(repository: getIt<PostRepository>()),
  );

  // Post BLoC
  getIt.registerSingleton<PostBloc>(
    PostBloc(
      getPostsUseCase: getIt<GetPostsUseCase>(),
      getStoriesUseCase: getIt<GetStoriesUseCase>(),
      postRepository: getIt<PostRepository>(),
      localStorageService: getIt<LocalStorageService>(),
    ),
  );
}
