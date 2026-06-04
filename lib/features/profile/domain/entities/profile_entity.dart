// lib/features/profile/domain/entities/profile_entity.dart

class ProfileEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String studentId;
  final String department;
  final String program;
  final String level;
  final String? avatarUrl;
  final bool isActive;

  const ProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentId,
    required this.department,
    required this.program,
    required this.level,
    this.avatarUrl,
    required this.isActive,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }
}
