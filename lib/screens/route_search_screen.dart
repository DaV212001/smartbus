import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/route_controller.dart';
import '../controllers/speech_controller.dart';
import '../utils/api_call_status.dart';
import 'home_screen.dart';

class RouteSearchScreen extends StatefulWidget {
  const RouteSearchScreen({super.key});

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  final routeController = Get.find<RouteController>();
  late final SpeechController speechController;
  final departureTextController = TextEditingController();
  final destinationTextController = TextEditingController();

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    speechController = Get.put(SpeechController());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    departureTextController.dispose();
    destinationTextController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      routeController.searchRoutesAdvanced(
        departure: departureTextController.text.trim(),
        destination: destinationTextController.text.trim(),
      );
    });
  }

  void _openVoiceSearch() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VoiceSearchSheet(speechController: speechController),
    );

    // If the parser returned results, fill the text fields
    if (result != null) {
      final dep = result['departure'] ?? '';
      final dest = result['destination'] ?? '';
      if (dep.isNotEmpty) departureTextController.text = dep;
      if (dest.isNotEmpty) destinationTextController.text = dest;
      routeController.searchRoutesAdvanced(departure: dep, destination: dest);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "find_route".tr,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _searchSection(context),
                    _sectionHeader(context),
                    _routeList(context, routeController),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SEARCH SECTION =================
  Widget _searchSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "where_to".tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              // ── Mic Button ──
              Tooltip(
                message: 'voice_search'.tr,
                child: InkWell(
                  onTap: _openVoiceSearch,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mic_rounded,
                      color: theme.primaryColor,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Positioned(
                left: 23,
                top: 30,
                bottom: 30,
                child: Container(width: 2, color: theme.dividerColor),
              ),
              Column(
                children: [
                  _SearchField(
                    icon: Icons.circle,
                    hint: "departure_stop".tr,
                    controller: departureTextController,
                    onChanged: (_) => _onSearchChanged(),
                  ),
                  const SizedBox(height: 12),
                  _SearchField(
                    icon: Icons.location_on,
                    hint: "destination_stop".tr,
                    controller: destinationTextController,
                    onChanged: (_) => _onSearchChanged(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _filters(context),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context) {
    final List<Map<String, String>> filters = [
      {"label": "filter_lowest_price".tr, "key": "price", "order": "asc"},
      {"label": "filter_fastest".tr, "key": "duration", "order": "asc"},
      {"label": "filter_route_num".tr, "key": "routeNumber", "order": "asc"},
    ];

    return SizedBox(
      height: 40,
      child: Obx(() {
        final activeSortBy = routeController.currentSortBy.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          itemBuilder: (context, i) {
            final filter = filters[i];
            final bool isActive = activeSortBy == filter["key"];
            return GestureDetector(
              onTap: () {
                routeController.currentSortBy.value = filter["key"]!;
                routeController.currentSortOrder.value = filter["order"]!;
                routeController.sortSearchResults();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isActive
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: isActive
                      ? null
                      : Border.all(color: Theme.of(context).dividerColor),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter["label"]!,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ================= SECTION HEADER =================
  Widget _sectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "available_routes".tr,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
      ),
    );
  }

  // ================= ROUTE LIST =================
  Widget _routeList(BuildContext context, RouteController controller) {
    final theme = Theme.of(context);
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.searchStatus.value == ApiCallStatus.empty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: theme.disabledColor,
              ),
              const SizedBox(height: 12),
              Text(
                'no_routes_found'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      final list =
          controller.searchResults.isEmpty && !controller.isLoading.value
          ? controller.routes
          : controller.searchResults;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: list.map((route) {
            return RouteCard(
              routeId: route.id?.toString() ?? '',
              routeName: route.routeNumber ?? 'Route',
              price: "${route.price?.toStringAsFixed(2) ?? '0.00'} ETB",
              start: route.startStopName ?? 'Start',
              end: route.endStopName ?? 'End',
              duration: "${route.duration ?? '0'} mins",
              stops: "${route.totalStops ?? '0'} stops",
            );
          }).toList(),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Voice Search Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _VoiceSearchSheet extends StatelessWidget {
  final SpeechController speechController;
  const _VoiceSearchSheet({required this.speechController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.65,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Obx(() {
                    final state = speechController.voiceState.value;
                    final locale = speechController.selectedLocale.value;
                    final isListening = state == VoiceSearchState.listening;
                    final isProcessing = state == VoiceSearchState.processing;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Title
                        Text(
                          'voice_search'.tr,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),

                        // Language toggle
                        GestureDetector(
                          onTap: speechController.toggleLocale,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.language_rounded,
                                  size: 16,
                                  color: theme.primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  locale == 'am-ET'
                                      ? 'switch_to_english'.tr
                                      : 'switch_to_amharic'.tr,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Waveform / mic button
                        _WaveformButton(
                          isListening: isListening,
                          isProcessing: isProcessing,
                          soundLevel: speechController.soundLevel.value,
                          primaryColor: theme.primaryColor,
                          onTap: () {
                            if (isListening) {
                              speechController.stopListening();
                            } else {
                              speechController.startListening();
                            }
                          },
                        ),

                        // Status text / transcription
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isProcessing
                              ? Text(
                                  'processing_speech'.tr,
                                  key: const ValueKey('processing'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : isListening
                              ? Column(
                                  key: const ValueKey('listening'),
                                  children: [
                                    Text(
                                      'listening'.tr,
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (speechController
                                        .transcribedText
                                        .value
                                        .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          speechController
                                              .transcribedText
                                              .value,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              : Text(
                                  'voice_search_prompt'.tr,
                                  key: const ValueKey('idle'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Pulsating Waveform Mic Button
// ─────────────────────────────────────────────────────────────────────────────

class _WaveformButton extends StatelessWidget {
  final bool isListening;
  final bool isProcessing;
  final double soundLevel;
  final Color primaryColor;
  final VoidCallback onTap;

  const _WaveformButton({
    required this.isListening,
    required this.isProcessing,
    required this.soundLevel,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double rippleSize = 80 + (soundLevel * 24);
    return GestureDetector(
      onTap: isProcessing ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: rippleSize,
        height: rippleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isListening
              ? primaryColor
              : primaryColor.withValues(alpha: 0.12),
          boxShadow: isListening
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: soundLevel * 8,
                  ),
                ]
              : [],
        ),
        child: isProcessing
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: primaryColor,
                ),
              )
            : Icon(
                isListening ? Icons.stop_rounded : Icons.mic_rounded,
                size: 34,
                color: isListening ? Colors.white : primaryColor,
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Search Field Widget
// ─────────────────────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const _SearchField({
    required this.icon,
    required this.hint,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: Icon(
            icon,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
