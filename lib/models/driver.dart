import 'user.dart';

class Driver extends User {
  final String? email;
  final String? phone;
  final String? plateNumber;

  const Driver({
    super.id,
    super.firstName,
    super.lastName,
    super.imageUrl,
    this.email,
    this.phone,
    this.plateNumber,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      imageUrl: json['imageUrl'],
      email: json['email'],
      phone: json['phone'],
      plateNumber: json['plateNumber'],
    );
  }
}
// if(response.statusCode == 200 && response.data['status']){
//
// } else {
//   throw Exception(response.statusCode);
// }
// {
//   'status': bool,
//   'message': string,
//   'data': {}, []
// }
