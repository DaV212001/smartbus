class User {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? imageUrl;
  final String? role;

  const User({
    this.role,
    this.email,
    this.id,
    this.firstName,
    this.lastName,
    this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String name = json['fullName'];
    List<String> names = name.split(' ');
    String firstName = names[0];
    String lastName = names[1];
    return User(
      id: json['id'],
      firstName: firstName,
      email: json['email'],
      lastName: lastName,
      imageUrl: json['image'],
      role: json['role'],
    );
  }
}
