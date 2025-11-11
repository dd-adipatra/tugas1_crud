class Password {
  int? id;
  String title;
  String username;
  String password;

  Password({
    this.id,
    required this.title,
    required this.username,
    required this.password,
  });

  factory Password.fromMap(Map<String, dynamic> json) => Password(
    id: json['id'],
    title: json['title'],
    username: json['username'],
    password: json['password'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
    };
  }
}
