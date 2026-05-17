import 'dart:convert';

import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/widgets.dart' hide Route;
import 'package:get/get.dart';

import '../config/dio_config.dart';
import '../config/storage_config.dart';
import '../models/route.dart';
import '../utils/templates/dio_template.dart';

class RouteController extends GetxController {
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final routes = <Route>[].obs;
  final searchResults = <Route>[].obs;
  final selectedRouteDetails = Rxn<Route>();

  final currentSortBy = 'createdAt'.obs;
  final currentSortOrder = 'desc'.obs;

  final scrollController = ScrollController();
  int currentPage = 1;
  int totalPages = 1;

  static const String _cachedRoutesKey = 'cached_routes_list';

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadCachedRoutes();
    fetchRoutes(page: 1);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoading.value && !isLoadingMore.value && hasMore.value) {
        fetchRoutes(page: currentPage + 1);
      }
    }
  }

  // --- Offline Cache Storage ---
  void loadCachedRoutes() {
    try {
      final cachedString = ConfigPreference.getStorage().getString(
        _cachedRoutesKey,
      );
      if (cachedString != null) {
        final List decoded = json.decode(cachedString);
        routes.value = decoded.map((e) => Route.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error loading cached routes: $e");
    }
  }

  // --- Optimistic Local Sort ---
  void _sortLocalRoutes(String sortBy, String sortOrder) {
    final bool isAsc = sortOrder == 'asc';
    routes.sort((a, b) {
      if (sortBy == 'price') {
        final double valA = a.price ?? 0.0;
        final double valB = b.price ?? 0.0;
        return isAsc ? valA.compareTo(valB) : valB.compareTo(valA);
      } else if (sortBy == 'duration') {
        final double valA = a.duration ?? 0.0;
        final double valB = b.duration ?? 0.0;
        return isAsc ? valA.compareTo(valB) : valB.compareTo(valA);
      }
      return 0;
    });
  }

  Future<void> fetchRoutes({
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  }) async {
    if (sortBy != null) currentSortBy.value = sortBy;
    if (sortOrder != null) currentSortOrder.value = sortOrder;

    if (page == 1) {
      isLoading.value = true;
      hasMore.value = true;
      currentPage = 1;

      // Apply optimistic sort locally if we have cached data
      if (routes.isNotEmpty) {
        _sortLocalRoutes(currentSortBy.value, currentSortOrder.value);
      }
    } else {
      isLoadingMore.value = true;
    }

    await DioService.dioGet(
      path:
          '/v1/routes?page=$page&limit=$limit&sortBy=${currentSortBy.value}&sortOrder=${currentSortOrder.value}',
      // queryParameters: {
      //   'page': page.toString(),
      //   'limit': limit.toString(),
      //   'sortBy': currentSortBy.value,
      //   'sortOrder': currentSortOrder.value,
      // },
      options: dio_lib.Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ConfigPreference.getAccessToken()}',
        },
      ),
      onSuccess: (response) {
        final List items = response.data['data']['items'] ?? [];
        final List<Route> newRoutes = items
            .map((e) => Route.fromJson(e))
            .toList();

        final meta = response.data['data']['meta'];
        if (meta != null) {
          currentPage = (meta['page'] as num).toInt();
          totalPages = (meta['totalPages'] as num).toInt();
          hasMore.value = currentPage < totalPages;
        } else {
          hasMore.value = false;
        }

        if (page == 1) {
          routes.value = newRoutes;
          // Store first page offline
          ConfigPreference.getStorage().setString(
            _cachedRoutesKey,
            json.encode(items),
          );
        } else {
          routes.addAll(newRoutes);
        }

        isLoading.value = false;
        isLoadingMore.value = false;
      },
      onFailure: (error, response) {
        isLoading.value = false;
        isLoadingMore.value = false;
        // Only show full screen error if we don't have any cached routes
        if (routes.isEmpty) {
          _handleError(error, response);
        }
      },
    );
  }

  Future<void> searchRoutes(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    isLoading.value = true;
    await DioService.dioGet(
      path: '/v1/routes/search',
      queryParameters: {'q': query},
      onSuccess: (response) {
        final List items = response.data['data'] ?? [];
        searchResults.value = items.map((e) => Route.fromJson(e)).toList();
        isLoading.value = false;
      },
      onFailure: (error, response) => _handleError(error, response),
    );
  }

  Future<void> fetchRouteById(String id) async {
    selectedRouteDetails.value = null;
    isLoading.value = true;
    await DioService.dioGet(
      path: '/v1/routes/$id',
      onSuccess: (response) {
        selectedRouteDetails.value = Route.fromJson(response.data['data']);
        isLoading.value = false;
      },
      onFailure: (error, response) => _handleError(error, response),
    );
  }

  void _handleError(dynamic error, dynamic response) {
    isLoading.value = false;
    String errorMsg = "An error occurred";

    if (error is dio_lib.DioException) {
      errorMsg = DioConfig.convertDioError(error);
      if (error.response?.data != null) {
        final backendMsg = _parseMessage(error.response!.data);
        if (backendMsg != null) errorMsg = backendMsg;
      }
    } else if (response != null && response.data != null) {
      final backendMsg = _parseMessage(response.data);
      if (backendMsg != null) errorMsg = backendMsg;
    }

    Get.snackbar('Error', errorMsg, snackPosition: SnackPosition.BOTTOM);
  }

  String? _parseMessage(dynamic data) {
    if (data == null) return null;
    final dynamic message = data['message'] ?? data['messages'];
    if (message == null) return null;

    if (message is List) {
      return message.join('\n');
    }
    return message.toString();
  }
}
