import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/get_utils.dart';

class Stop {
  final String? id;
  final String? nameEn;
  final String? nameAm;
  final num? sequence;
  final num? distanceFromPreviousStop;
  final double? latitude;
  final double? longitude;

  const Stop({
    this.sequence,
    this.nameAm,
    this.distanceFromPreviousStop,
    this.id,
    this.nameEn,
    this.latitude,
    this.longitude,
  });

  factory Stop.fromJson(Map<String, dynamic> json,
      {required bool isDeparture, required bool isDestination}) {
    // List<dynamic> names = (json['names'] as List);
    return Stop(
      id: json['id'],
      nameEn: json['nameEn'],
      nameAm: json['nameAm'],
      sequence: json['sequence'],
      distanceFromPreviousStop:
          double.tryParse((json['distanceFromPreviousStop']).toString()),
      latitude: double.tryParse((json['latitude']).toString()),
      longitude: double.tryParse((json['longitude']).toString()),
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
