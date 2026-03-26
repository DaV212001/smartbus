import 'package:get/get.dart';

import 'driver.dart';
import 'stop_tcs.dart';

class Route {
  final String? id;
  final String? nameEn;
  final String? nameAm;
  final double? distance;
  final double? duration;
  // final double? ratePerKm;
  final double? rateFactor;
  // final bool? isStudentRoute;
  final List<Stop>? stops;
  final List<Driver>? drivers;
  // final Subscription? subscription;

  const Route({
    this.nameAm,
    this.id,
    this.nameEn,
    this.distance,
    this.duration,
    // this.ratePerKm,
    this.rateFactor,
    // this.isStudentRoute,
    this.stops,
    this.drivers,
    // this.subscription,
  });

  static Route sampleRoute = const Route(
    id: "1",
    nameEn: 'Route',
    nameAm: 'Route',
    stops: [
      Stop(id: "1", nameEn: 'Stop', latitude: 8.0, longitude: 40.0),
      Stop(id: "1", nameEn: 'Stop', latitude: 8.0, longitude: 42.0),
    ],
    distance: 0.0,
    duration: 0.0,
  );

  factory Route.fromJson(Map<String, dynamic> json) {
    // Find the stop with the highest sequence to mark as the destination
    final maxSequence = ((json['stops'] ?? []) as List).isEmpty
        ? 0
        : ((json['stops'] ?? []) as List)
              .map((stop) => stop['sequence'])
              .reduce((a, b) => a > b ? a : b); // Get the max sequence
    // List<dynamic> names = (json['names'] as List);
    return Route(
      id: json['id'],
      nameEn: json['nameEn'],
      nameAm: json['nameAm'],
      distance: json['distance'] is int
          ? json['distance'].toDouble()
          : json['distance'] is String?
          ? double.tryParse(json['distance'])
          : json['distance'],
      duration: json['duration'] is int
          ? json['duration'].toDouble()
          : json['duration'] is String?
          ? double.tryParse(json['duration'])
          : json['duration'],
      // ratePerKm: json['ratePerKm'],
      rateFactor: json['rateFactor'] is int
          ? json['rateFactor'].toDouble()
          : json['rateFactor'] is String?
          ? double.tryParse(json['rateFactor'])
          : json['rateFactor'],
      // isStudentRoute: json['isStudentRoute'],
      stops: ((json['stops'] ?? []) as List)
          .map(
            (stop) => Stop.fromJson(
              stop,
              isDestination: stop['sequence'] == maxSequence,
              isDeparture: stop['sequence'] == 1,
            ),
          )
          .toList(),
      drivers: ((json['drivers'] ?? []) as List)
          .map((driver) => Driver.fromJson(driver))
          .toList(),
      // subscription: json['subscription'] != null
      //     ? Subscription.fromJson(json['subscription'])
      //     : null,
    );
  }

  String get name {
    if (Get.locale!.languageCode == 'en') {
      return nameEn!;
    } else {
      return nameAm!;
    }
  }
}
