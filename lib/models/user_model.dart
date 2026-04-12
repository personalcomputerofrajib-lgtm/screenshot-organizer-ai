class UserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isPremium;
  final int scanCount;

  UserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isPremium = false,
    this.scanCount = 0,
  });

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isPremium,
    int? scanCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isPremium: isPremium ?? this.isPremium,
      scanCount: scanCount ?? this.scanCount,
    );
  }
}
