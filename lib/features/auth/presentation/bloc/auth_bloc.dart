import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutter_test_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:flutter_test_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:flutter_test_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:flutter_test_app/features/auth/domain/usecases/update_viewed_stories_usecase.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test_app/core/usecase/usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateViewedStoriesUseCase updateViewedStoriesUseCase;

  AuthBloc({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.updateViewedStoriesUseCase,
  }) : super(const AuthInitial()) {
    on<SignUpEvent>(_onSignUp);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
    on<CheckCurrentUserEvent>(_onCheckCurrentUser);
    on<UpdateViewedStoriesEvent>(_onUpdateViewedStories);
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signUpUseCase(
      SignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthSuccess(user: user)),
    );
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signInUseCase(
      SignInParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthSuccess(user: user)),
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signOutUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(const AuthSignedOut()),
    );
  }

  Future<void> _onCheckCurrentUser(
    CheckCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await getCurrentUserUseCase(const NoParams());

    result.fold((failure) => emit(const AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthSuccess(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  Future<void> _onUpdateViewedStories(
    UpdateViewedStoriesEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await updateViewedStoriesUseCase(
      UpdateViewedStoriesParams(
        uid: event.uid,
        viewedStories: event.viewedStories,
      ),
    );

    // We don't emit a new state here since this is a background operation
    // The UI will handle the result through callbacks
    result.fold(
      (failure) {
        // Could emit an error state if needed, but for now just log
        // This is a silent operation
      },
      (_) {
        // Success - no state change needed
      },
    );
  }
}
