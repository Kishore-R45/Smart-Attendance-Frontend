class User {
  final String id;
  final String studentId;
  final String name;
  final String email;
  final String department;
  final String year;
  final String? profileImage;
  final String? phone;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.studentId,
    required this.name,
    required this.email,
    required this.department,
    required this.year,
    this.profileImage,
    this.phone,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] ?? '',
      year: json['year'] ?? '',
      profileImage: json['profile_image'],
      phone: json['phone'],
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'name': name,
      'email': email,
      'department': department,
      'year': year,
      'profile_image': profileImage,
      'phone': phone,
    };
  }
}