import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? name;
  final String? profileImageUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    this.name,
    this.profileImageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [uid, email, name, profileImageUrl, createdAt];
}
