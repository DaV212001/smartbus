import 'route.dart';
import 'user.dart';
import 'passenger.dart';

class Student extends User {
  final Passenger? parent;
  final Route? subscribedRoute;

  const Student({
    super.id,
    super.firstName,
    super.lastName,
    super.imageUrl,
    this.parent,
    this.subscribedRoute,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      imageUrl: json['imageUrl'],
      parent:
          json['parent'] != null ? Passenger.fromJson(json['parent']) : null,
      subscribedRoute: json['subscribedRoute'] != null
          ? Route.fromJson(json['subscribedRoute'])
          : null,
    );
  }
}
