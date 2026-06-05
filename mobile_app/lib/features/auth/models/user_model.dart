import '../../profile/models/profile_model.dart';

class UserModel {
  final String id;
  final String email;
  final String role;
  final String subscriptionPlan;
  final List<ProfileModel> profiles;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.subscriptionPlan,
    required this.profiles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var profileList = json['profiles'] as List? ?? [];
    List<ProfileModel> profilesMapped = profileList
        .map((p) => ProfileModel.fromJson(p as Map<String, dynamic>))
        .toList();

    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      subscriptionPlan: json['subscriptionPlan'] ?? 'free',
      profiles: profilesMapped,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'email': email,
      'role': role,
      'subscriptionPlan': subscriptionPlan,
      'profiles': profiles.map((p) => p.toJson()).toList(),
    };
  }
}
