import 'user.dart';

class Passenger extends User {
  final String? email;
  final String? phone;
  // final List<Route>? subscribedRoutes;

  const Passenger({
    super.id,
    super.firstName,
    super.lastName,
    super.imageUrl,
    this.email,
    this.phone,
    // this.subscribedRoutes,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    String name = '';
    if (json.containsKey('name')) {
      name = json['name'];
    }
    return Passenger(
      id: json['id'],
      firstName: name.isNotEmpty ? name.split(' ').first : json['firstName'],
      lastName: name.isNotEmpty ? name.split(' ').last : json['lastName'],
      imageUrl: json['imageUrl'],
      email: json['email'],
      phone: json['phone'],
      // subscribedRoutes: ((json['subscribedRoutes'] ?? []) as List)
      //     .map((route) => Route.fromJson(route))
      //     .toList(),
    );
  }
}
