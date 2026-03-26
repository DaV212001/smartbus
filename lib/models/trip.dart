import 'package:flutter/material.dart';

import '../utils/functions/date_time_to_ethiopian_time.dart';
import 'driver.dart';
import 'route.dart' as r;
import 'stop_tcs.dart';

class Trip {
  final int? id;
  final r.Route? route;
  final DateTime? departureDateTime;
  final DateTime? destinationDateTime;
  final Stop? departureStop;
  final Stop? destinationStop;
  final Driver? driver;
  final TripStatus? status;

  const Trip({
    this.id,
    this.route,
    this.departureDateTime,
    this.destinationDateTime,
    this.departureStop,
    this.destinationStop,
    this.driver,
    this.status,
  });

  static Trip sampleTrip = Trip(
    departureDateTime: DateTime.now(),
    departureStop: const Stop(nameEn: 'Megenagna'),
    destinationStop: const Stop(nameEn: 'Bole'),
    driver: const Driver(
      firstName: 'John',
      lastName: 'Doe',
      phone: '+25115151515',
      imageUrl:
          'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    ),
    status: TripStatus.completed,
    destinationDateTime: DateTime.now().add(const Duration(hours: 2)),
  );

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      route: json['route'] != null ? r.Route.fromJson(json['route']) : null,
      departureDateTime: json['departureDateTime'] != null
          ? toEthiopian(DateTime.parse(json['departureDateTime']))
          : null,
      destinationDateTime: json['destinationDateTime'] != null
          ? toEthiopian(DateTime.parse(json['destinationDateTime']))
          : null,
      departureStop: json['departureStop'] != null
          ? Stop.fromJson(
              json['departureStop'],
              isDeparture: true,
              isDestination: false,
            )
          : null,
      destinationStop: json['destinationStop'] != null
          ? Stop.fromJson(
              json['destinationStop'],
              isDeparture: false,
              isDestination: true,
            )
          : null,
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
      status: TripStatusExtension.fromName(json['status']),
    );
  }
}

enum TripStatus { cancelled, completed, inProgress, interrupted, pending }

extension TripStatusExtension on TripStatus {
  String get displayStatus {
    switch (this) {
      case TripStatus.cancelled:
        return 'Cancelled';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.inProgress:
        return 'In Progress';
      case TripStatus.interrupted:
        return 'Interrupted';
      case TripStatus.pending:
        return 'Pending';
    }
  }

  Widget get badge {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Text(
          displayStatus,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Color get color {
    switch (this) {
      case TripStatus.cancelled:
        return Colors.grey;
      case TripStatus.completed:
        return Colors.green;
      case TripStatus.inProgress:
        return Colors.blue;
      case TripStatus.interrupted:
        return Colors.red;
      case TripStatus.pending:
        return Colors.orange;
    }
  }

  static TripStatus fromName(String name) {
    return TripStatus.values.firstWhere(
      (tripStatus) => tripStatus.name == name,
    );
  }
}
