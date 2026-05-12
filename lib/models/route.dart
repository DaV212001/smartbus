import 'package:get/get.dart';

import 'driver.dart';
import 'stop_tcs.dart';

class Route {
  final String? id;
  final String? nameEn;
  final String? nameAm;
  final String? routeNumber;
  final String? description;
  final double? distance;
  final double? duration;
  final double? rateFactor;
  final double? price; // Price in Birr (ETB)
  final bool? isActive;
  final int? totalStops;
  final String? startStopName;
  final String? endStopName;
  final List<Stop>? stops;
  final List<Driver>? drivers;

  const Route({
    this.nameAm,
    this.id,
    this.nameEn,
    this.routeNumber,
    this.description,
    this.distance,
    this.duration,
    this.rateFactor,
    this.price,
    this.isActive,
    this.totalStops,
    this.startStopName,
    this.endStopName,
    this.stops,
    this.drivers,
  });

  static Route sampleRoute = const Route(
    id: "1",
    nameEn: 'Route',
    nameAm: 'Route',
    routeNumber: 'R01',
    stops: [
      Stop(id: "1", nameEn: 'Stop', latitude: 8.0, longitude: 40.0),
      Stop(id: "1", nameEn: 'Stop', latitude: 8.0, longitude: 42.0),
    ],
    distance: 0.0,
    duration: 0.0,
    price: 0.0,
  );

  factory Route.fromJson(Map<String, dynamic> json) {
    // Find the stop with the highest sequence to mark as the destination
    final stopsList = (json['stops'] ?? []) as List;
    final maxSequence = stopsList.isEmpty
        ? 0
        : stopsList
              .map((stop) => stop['sequence'] ?? 0)
              .reduce((a, b) => a > b ? a : b);

    // Convert price from Santim to Birr
    double? convertedPrice;
    if (json['price'] != null) {
      convertedPrice =
          (json['price'] is num
              ? json['price'].toDouble()
              : double.tryParse(json['price'].toString())) ??
          0.0;
      convertedPrice = (convertedPrice! / 100)!;
    }

    return Route(
      id: json['id']?.toString(),
      nameEn: json['name'] ?? json['nameEn'],
      nameAm: json['nameAm'] ?? json['name'],
      routeNumber: json['routeNumber'],
      description: json['description'],
      price: convertedPrice,
      isActive: json['isActive'],
      totalStops: json['totalStops'],
      startStopName: json['startStopName'],
      endStopName: json['endStopName'],
      distance: json['distance'] is num
          ? json['distance'].toDouble()
          : double.tryParse(json['distance']?.toString() ?? ''),
      duration: json['duration'] is num
          ? json['duration'].toDouble()
          : double.tryParse(json['duration']?.toString() ?? ''),
      rateFactor: json['rateFactor'] is num
          ? json['rateFactor'].toDouble()
          : double.tryParse(json['rateFactor']?.toString() ?? ''),
      stops: stopsList
          .map(
            (stop) => Stop.fromJson(
              stop,
              isDeparture: stop['sequence'] == 1,
              isDestination: stop['sequence'] == maxSequence,
            ),
          )
          .toList(),
      drivers: ((json['drivers'] ?? []) as List)
          .map((driver) => Driver.fromJson(driver))
          .toList(),
    );
  }

  String get name {
    if (Get.locale!.languageCode == 'en') {
      return nameEn ?? 'N/A';
    } else {
      return nameAm ?? nameEn ?? 'N/A';
    }
  }
}
