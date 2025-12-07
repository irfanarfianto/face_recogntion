import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final List<double> faceEmbedding;
  final String? imageUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.faceEmbedding,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, faceEmbedding, imageUrl];
}
