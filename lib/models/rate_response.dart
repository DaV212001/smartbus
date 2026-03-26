import 'package:get/get.dart';

class RateResponse {
  final double ratePerKm;
  final Map<String, Factor> factors;
  final DateTime startDateTime;
  final DateTime? endDateTime;

  RateResponse({
    required this.ratePerKm,
    required this.factors,
    required this.startDateTime,
    this.endDateTime,
  });

  factory RateResponse.fromJson(Map<String, dynamic> json) {
    final rawFactors = json['factors'] as Map<String, dynamic>;
    return RateResponse(
      ratePerKm: (json['ratePerKm'] as num).toDouble(),
      factors: rawFactors.map(
        (k, v) => MapEntry(k, Factor.fromJson(v)),
      ),
      startDateTime: DateTime.parse(json['startDateTime']),
      endDateTime: json['endDateTime'] != null
          ? DateTime.parse(json['endDateTime'])
          : null,
    );
  }
}

class Factor {
  final double value;
  final String nameEn;
  final String nameAm;
  final int days;

  Factor({
    required this.value,
    required this.nameEn,
    required this.nameAm,
    required this.days,
  });

  factory Factor.fromJson(Map<String, dynamic> json) {
    return Factor(
      value: json['value'] is int
          ? (json['value'] as int).toDouble()
          : (json['value'] as num).toDouble(),
      nameEn: json['nameEn'] ?? '',
      nameAm: json['nameAm'] ?? '',
      days: json['days'] ?? 0,
    );
  }

  /// Auto-localized name
  String get name {
    if (Get.locale?.languageCode == 'am') {
      return nameAm;
    }
    return nameEn;
  }
}
