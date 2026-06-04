// lib/features/profile/data/models/profile_model.dart

import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.studentId,
    required super.department,
    required super.program,
    required super.level,
    super.avatarUrl,
    required super.isActive,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        email: json['email'] as String,
        studentId: json['student_id'] as String,
        department: json['department'] as String,
        program: json['program'] as String,
        level: json['level'] as String,
        avatarUrl: json['avatar_url'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'student_id': studentId,
        'department': department,
        'program': program,
        'level': level,
        'avatar_url': avatarUrl,
        'is_active': isActive,
      };

  factory ProfileModel.fromEntity(ProfileEntity e) => ProfileModel(
        id: e.id,
        firstName: e.firstName,
        lastName: e.lastName,
        email: e.email,
        studentId: e.studentId,
        department: e.department,
        program: e.program,
        level: e.level,
        avatarUrl: e.avatarUrl,
        isActive: e.isActive,
      );
}
