class ProfileModel {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isKids;
  final String? pin;
  final String languagePreference;

  ProfileModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isKids,
    this.pin,
    this.languagePreference = 'en',
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? 'https://api.dicebear.com/7.x/bottts/png?seed=Vanix',
      isKids: json['isKids'] ?? false,
      pin: json['pin'],
      languagePreference: json['languagePreference'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'isKids': isKids,
      'pin': pin,
      'languagePreference': languagePreference,
    };
  }
}
