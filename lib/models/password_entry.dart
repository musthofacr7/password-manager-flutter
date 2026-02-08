class PasswordEntry {
  int? id;
  String appName;
  String appLink;
  String username;
  String password;
  DateTime createdAt;
  DateTime updatedAt;

  PasswordEntry({
    this.id,
    required this.appName,
    required this.appLink,
    required this.username,
    required this.password,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appName': appName,
      'appLink': appLink,
      'username': username,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'] as int?,
      appName: map['appName'] as String,
      appLink: map['appLink'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  PasswordEntry copyWith({
    int? id,
    String? appName,
    String? appLink,
    String? username,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      appLink: appLink ?? this.appLink,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
