import 'package:test_face_recognition/features/attendance/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.faceEmbedding,
    super.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      faceEmbedding: json['face_embedding'] != null
          ? List<double>.from(json['face_embedding'])
          : [],
      imageUrl: json['image_url'], // Map from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'face_embedding': faceEmbedding,
      'image_url': imageUrl,
    };
  }
}
