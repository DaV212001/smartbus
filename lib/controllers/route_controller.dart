import 'dart:convert';

import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/widgets.dart' hide Route;
import 'package:get/get.dart';
import 'package:smartbus/controllers/theme_mode_controller.dart';

import '../config/dio_config.dart';
import '../config/storage_config.dart';
import '../constants/assets.dart';
import '../models/route.dart';
import '../utils/api_call_status.dart';
import '../utils/error_data.dart';
import '../utils/error_utils.dart';
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

  // Split reactive state trackers
  final routesStatus = ApiCallStatus.holding.obs;
  final routesError = Rxn<ErrorData>();

  final searchStatus = ApiCallStatus.holding.obs;
  final searchError = Rxn<ErrorData>();

  final detailsStatus = ApiCallStatus.holding.obs;
  final detailsError = Rxn<ErrorData>();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadCachedRoutes();
    fetchRoutes(page: 1);
    ever(ThemeModeController.languageCode, (c) => fetchRoutes());
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
      } else if (sortBy == 'routeNumber') {
        final numA = a.routeNumber ?? '';
        final numB = b.routeNumber ?? '';
        return isAsc ? numA.compareTo(numB) : numB.compareTo(numA);
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
    if (page == 1 && isLoading.value) return;
    if (page > 1 && isLoadingMore.value) return;

    if (sortBy != null) currentSortBy.value = sortBy;
    if (sortOrder != null) currentSortOrder.value = sortOrder;

    if (page == 1) {
      isLoading.value = true;
      routesStatus.value = ApiCallStatus.loading;
      routesError.value = null;
      hasMore.value = true;
      currentPage = 1;

      // Apply optimistic sort locally if we have cached data
      if (routes.isNotEmpty) {
        _sortLocalRoutes(currentSortBy.value, currentSortOrder.value);
      }
    } else {
      isLoadingMore.value = true;
    }
    final appLocale = Get.locale?.languageCode ?? 'en';
    await DioService.dioGet(
      path: '/v1/routes',
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': currentSortBy.value,
        'sortOrder': currentSortOrder.value,
      },
      options: dio_lib.Options(
        headers: {
          'Accept': 'application/json',
          "Accept-Language": appLocale,

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
        if (routes.isEmpty) {
          routesStatus.value = ApiCallStatus.empty;
        } else {
          routesStatus.value = ApiCallStatus.success;
        }
      },
      onFailure: (error, response) async {
        isLoading.value = false;
        isLoadingMore.value = false;
        routesStatus.value = ApiCallStatus.error;
        final err = await _getErrorData(error);
        routesError.value = err;
        // Only show full screen error if we don't have any cached routes
        if (routes.isEmpty) {
          _handleError(error, response);
        }
      },
    );
  }

  // Reactive properties to store search parameters
  final searchDeparture = ''.obs;
  final searchDestination = ''.obs;
  final searchKeyword = ''.obs;

  /// Trigger a search query with explicit support for all backend query parameters
  Future<void> searchRoutesAdvanced({
    String? q,
    String? departure,
    String? destination,
  }) async {
    // Sync state variables
    if (q != null) searchKeyword.value = q;
    if (departure != null) searchDeparture.value = departure;
    if (destination != null) searchDestination.value = destination;

    // If all fields are empty, clear search and exit
    if (searchKeyword.value.isEmpty &&
        searchDeparture.value.isEmpty &&
        searchDestination.value.isEmpty) {
      searchResults.clear();
      searchStatus.value = ApiCallStatus.holding;
      return;
    }

    isLoading.value = true;
    searchStatus.value = ApiCallStatus.loading;
    searchError.value = null;

    // Build query map dynamically (only include non-empty values)
    final Map<String, String> params = {};
    params['q'] = searchKeyword.value;
    params['departure'] = searchDeparture.value;
    params['destination'] = searchDestination.value;
    final appLocale = Get.locale?.languageCode ?? 'en';
    await DioService.dioGet(
      path: '/v1/routes/search',
      queryParameters: params,
      options: dio_lib.Options(
        headers: {
          'Accept': 'application/json',
          'Accept-Language': appLocale,
          'Authorization': 'Bearer ${ConfigPreference.getAccessToken()}',
        },
      ),
      onSuccess: (response) {
        final List items =
            response.data['data']['items'] ?? response.data['data'] ?? [];
        searchResults.value = items.map((e) => Route.fromJson(e)).toList();

        // Dynamic client sorting
        _applyClientSortToSearchResults();

        isLoading.value = false;
        searchStatus.value = searchResults.isEmpty
            ? ApiCallStatus.empty
            : ApiCallStatus.success;
      },
      onFailure: (error, response) async {
        isLoading.value = false;
        searchStatus.value = ApiCallStatus.error;
        final err = await _getErrorData(error);
        searchError.value = err;
        _handleError(error, response);
      },
    );
  }

  void sortSearchResults() {
    // Sort whichever list is currently displayed
    if (searchResults.isNotEmpty) {
      _applyClientSortToSearchResults();
    } else {
      _sortLocalRoutes(currentSortBy.value, currentSortOrder.value);
    }
  }

  /// Dynamic client-side sorting since backend fields 'price' & 'duration' are computed
  void _applyClientSortToSearchResults() {
    final sortBy = currentSortBy.value;
    final isAsc = currentSortOrder.value == 'asc';

    searchResults.sort((a, b) {
      if (sortBy == 'price') {
        return isAsc
            ? (a.price ?? 0.0).compareTo(b.price ?? 0.0)
            : (b.price ?? 0.0).compareTo(a.price ?? 0.0);
      } else if (sortBy == 'duration') {
        return isAsc
            ? (a.duration ?? 0.0).compareTo(b.duration ?? 0.0)
            : (b.duration ?? 0.0).compareTo(a.duration ?? 0.0);
      } else if (sortBy == 'routeNumber') {
        final numA = a.routeNumber ?? '';
        final numB = b.routeNumber ?? '';
        return isAsc ? numA.compareTo(numB) : numB.compareTo(numA);
      }
      return 0;
    });
  }

  Future<void> fetchRouteById(String id) async {
    selectedRouteDetails.value = null;
    isLoading.value = true;
    detailsStatus.value = ApiCallStatus.loading;
    detailsError.value = null;
    await DioService.dioGet(
      path: '/v1/routes/$id',
      options: dio_lib.Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ConfigPreference.getAccessToken()}',
          'Accept-Language': Get.locale?.languageCode ?? 'en',
        },
      ),
      onSuccess: (response) {
        selectedRouteDetails.value = Route.fromJson(response.data['data']);
        isLoading.value = false;
        detailsStatus.value = ApiCallStatus.success;
      },
      onFailure: (error, response) async {
        isLoading.value = false;
        detailsStatus.value = ApiCallStatus.error;
        final err = await _getErrorData(error);
        detailsError.value = err;
        _handleError(error, response);
      },
    );
  }

  Future<ErrorData> _getErrorData(Object error) async {
    try {
      return await ErrorUtil.getErrorData(error.toString());
    } catch (_) {
      return ErrorData(
        title: 'error'.tr,
        body: 'unexpected_error'.tr,
        image: Assets.errorsUnknown,
        buttonText: 'refresh'.tr,
      );
    }
  }

  void _handleError(dynamic error, dynamic response) {
    isLoading.value = false;
    if (DioConfig.isSessionExpiredError(error)) return;

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
