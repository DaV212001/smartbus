import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'route_controller.dart';

enum VoiceSearchState { idle, listening, processing, error }

class SpeechController extends GetxController {
  final _speech = stt.SpeechToText();

  final voiceState = VoiceSearchState.idle.obs;
  final transcribedText = ''.obs;
  final soundLevel = 0.0.obs;
  final isAvailable = false.obs;

  // Locale the STT engine uses (amharic or english)
  final selectedLocale = 'am-ET'.obs;

  @override
  void onInit() {
    super.onInit();
    // Default to app locale
    final appLocale = Get.locale?.languageCode ?? 'am';
    selectedLocale.value = appLocale == 'am' ? 'am-ET' : 'en-US';
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    isAvailable.value = await _speech.initialize(
      onError: (e) {
        voiceState.value = VoiceSearchState.error;
        transcribedText.value = '';
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (voiceState.value == VoiceSearchState.listening) {
            _onSpeechDone();
          }
        }
      },
    );
  }

  /// Check whether the am-ET locale is available on the device and fallback to en-US.
  Future<void> resolveLocale() async {
    final locales = await _speech.locales();
    final amAvailable = locales.any((l) => l.localeId.startsWith('am'));
    if (!amAvailable && selectedLocale.value == 'am-ET') {
      selectedLocale.value = 'en-US';
    }
  }

  void toggleLocale() {
    final nextLocale = selectedLocale.value == 'am-ET' ? 'en-US' : 'am-ET';
    selectedLocale.value = nextLocale;
    final langCode = nextLocale == 'am-ET' ? 'am' : 'en';
    Get.updateLocale(Locale(langCode));
    try {
      Get.find<RouteController>().fetchRoutes(page: 1);
    } catch (e) {
      Logger().e("Error refreshing routes: $e");
    }
  }

  Future<void> startListening() async {
    if (!isAvailable.value) {
      await _initSpeech();
      if (!isAvailable.value) {
        voiceState.value = VoiceSearchState.error;
        Get.snackbar(
          'voice_search'.tr,
          'mic_permission_denied'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
        return;
      }
    }

    transcribedText.value = '';
    voiceState.value = VoiceSearchState.listening;

    await _speech.listen(
      localeId: selectedLocale.value,
      onResult: (result) {
        transcribedText.value = result.recognizedWords;
        if (result.finalResult) {
          _onSpeechDone();
        }
      },
      onSoundLevelChange: (level) {
        soundLevel.value = (level + 2.0).clamp(0.0, 10.0) / 10.0;
      },
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _onSpeechDone();
  }

  void _onSpeechDone() {
    // Guard against multiple calls (e.g. from both onStatus and onResult)
    if (voiceState.value != VoiceSearchState.listening) return;

    if (transcribedText.value.trim().isEmpty) {
      voiceState.value = VoiceSearchState.idle;
      return;
    }
    voiceState.value = VoiceSearchState.processing;
    _parseAndSearch(transcribedText.value.trim().toLowerCase());
  }

  // ─────────────────────────────────────────────────────────────
  //  Intent Parser (Amharic + English)
  // ─────────────────────────────────────────────────────────────

  /// Returns all unique stop names from currently cached routes.
  List<String> _cachedStopNames() {
    final routeController = Get.find<RouteController>();
    final names = <String>{};
    for (final route in routeController.routes) {
      if (route.startStopName != null) {
        names.add(route.startStopName!.toLowerCase());
      }
      if (route.endStopName != null) {
        names.add(route.endStopName!.toLowerCase());
      }
      for (final stop in route.stops ?? []) {
        final n = stop.name;
        if (n.isNotEmpty) names.add(n.toLowerCase());
      }
    }
    return names.toList();
  }

  /// Simple Jaro-Winkler approximation: returns similarity score 0–1.
  double _similarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final matchDist = (a.length > b.length ? a.length : b.length) ~/ 2 - 1;
    if (matchDist < 0) return 0.0;

    final aMatches = List.filled(a.length, false);
    final bMatches = List.filled(b.length, false);
    int matches = 0;

    for (int i = 0; i < a.length; i++) {
      final start = (i - matchDist).clamp(0, b.length - 1);
      final end = (i + matchDist + 1).clamp(0, b.length);
      for (int j = start; j < end; j++) {
        if (!bMatches[j] && a[i] == b[j]) {
          aMatches[i] = true;
          bMatches[j] = true;
          matches++;
          break;
        }
      }
    }
    if (matches == 0) return 0.0;

    int transpositions = 0;
    int k = 0;
    for (int i = 0; i < a.length; i++) {
      if (aMatches[i]) {
        while (!bMatches[k]) {
          k++;
        }
        if (a[i] != b[k]) {
          transpositions++;
        }
        k++;
      }
    }

    final jaro =
        (matches / a.length +
            matches / b.length +
            (matches - transpositions / 2) / matches) /
        3;

    // Winkler prefix bonus (up to 4 chars)
    int prefix = 0;
    for (int i = 0; i < 4 && i < a.length && i < b.length; i++) {
      if (a[i] == b[i]) {
        prefix++;
      } else {
        break;
      }
    }
    return jaro + prefix * 0.1 * (1 - jaro);
  }

  /// Finds the best-matching stop name from the cache for a given fragment.
  String? _bestMatch(
    String fragment,
    List<String> stops, {
    double threshold = 0.75,
  }) {
    if (fragment.isEmpty) return null;
    String? best;
    double bestScore = 0.0;
    for (final stop in stops) {
      // Prefer exact substring match
      if (stop.contains(fragment) || fragment.contains(stop)) {
        return stop;
      }
      final score = _similarity(fragment, stop);
      if (score > bestScore && score >= threshold) {
        bestScore = score;
        best = stop;
      }
    }
    return best;
  }

  void _parseAndSearch(String text) {
    Logger().d(text);
    final stops = _cachedStopNames();
    String? departure;
    String? destination;

    if (selectedLocale.value == 'am-ET') {
      // Amharic: prepositions  ከ (from), ወደ/እስከ (to)
      final fromMatch = RegExp(r'ከ\s*(\S+(?:\s\S+)?)').firstMatch(text);
      final toMatch = RegExp(r'(?:ወደ|እስከ)\s*(\S+(?:\s\S+)?)').firstMatch(text);
      if (fromMatch != null) departure = _bestMatch(fromMatch.group(1)!, stops);
      if (toMatch != null) destination = _bestMatch(toMatch.group(1)!, stops);
    } else {
      // English: prepositions "from", "to"
      final fromMatch = RegExp(
        r'from\s+([a-z]+(?:\s[a-z]+)?)',
      ).firstMatch(text);
      final toMatch = RegExp(r'\bto\s+([a-z]+(?:\s[a-z]+)?)').firstMatch(text);
      if (fromMatch != null) departure = _bestMatch(fromMatch.group(1)!, stops);
      if (toMatch != null) destination = _bestMatch(toMatch.group(1)!, stops);
    }

    // Fallback: if no preposition found, try to match any two stops mentioned
    if (departure == null && destination == null) {
      final matched = stops
          .where((s) => text.contains(s) || _similarity(s, text) > 0.8)
          .toList();
      if (matched.length >= 2) {
        departure = matched[0];
        destination = matched[1];
      } else if (matched.length == 1) {
        destination = matched[0];
      }
    }

    // Resolve back to original casing from cached routes
    final routeController = Get.find<RouteController>();
    String? resolvedDep = _resolveOriginalName(departure, routeController);
    String? resolvedDest = _resolveOriginalName(destination, routeController);

    if (resolvedDep == null && resolvedDest == null) {
      voiceState.value = VoiceSearchState.idle;
      Get.snackbar(
        'voice_search'.tr,
        'speech_not_understood'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    routeController.searchRoutesAdvanced(
      departure: resolvedDep ?? '',
      destination: resolvedDest ?? '',
    );

    Get.back(
      result: {
        'departure': resolvedDep ?? '',
        'destination': resolvedDest ?? '',
      },
    );
    voiceState.value = VoiceSearchState.idle;
  }

  String? _resolveOriginalName(
    String? lowercaseName,
    RouteController controller,
  ) {
    if (lowercaseName == null) return null;
    for (final route in controller.routes) {
      for (final stop in route.stops ?? []) {
        final name = stop.name;
        if (name.toLowerCase() == lowercaseName) {
          return name;
        }
      }
      if ((route.startStopName?.toLowerCase() ?? '') == lowercaseName)
        return route.startStopName;
      if ((route.endStopName?.toLowerCase() ?? '') == lowercaseName)
        return route.endStopName;
    }
    return lowercaseName; // return as-is if no original found
  }
}
