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

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final rawAvatarUrl = json['avatarUrl']?.toString();
    final avatarUrl = rawAvatarUrl == null || rawAvatarUrl.trim().isEmpty ||
            rawAvatarUrl.trim().toLowerCase() == 'null'
        ? null
        : rawAvatarUrl.trim();

    return ProfileModel(
      id: json['id']?.toString() ?? '',
      firstName: (json['fullName'] ?? '').toString().split(' ').first,
      lastName:
          (json['fullName'] ?? '').toString().split(' ').skip(1).join(' '),
      email: json['email']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      program: json['program']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      avatarUrl: avatarUrl,
      isActive: json['isActive'] ?? true,
    );
  }

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
