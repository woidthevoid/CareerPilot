class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? profilePicture;
  final DateTime? birthday;

  const UserProfile({
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.birthday,
  });

  String get displayName {
    if (firstName != null && lastName != null) return '$firstName $lastName';
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return 'User';
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? profilePicture,
    DateTime? birthday,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePicture: profilePicture ?? this.profilePicture,
      birthday: birthday ?? this.birthday,
    );
  }
}