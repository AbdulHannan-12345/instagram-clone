import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const SignUpEvent({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

class CheckCurrentUserEvent extends AuthEvent {
  const CheckCurrentUserEvent();
}

class UpdateViewedStoriesEvent extends AuthEvent {
  final String uid;
  final List<String> viewedStories;

  const UpdateViewedStoriesEvent({
    required this.uid,
    required this.viewedStories,
  });

  @override
  List<Object?> get props => [uid, viewedStories];
}
