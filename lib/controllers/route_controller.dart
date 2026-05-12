import 'package:dio/dio.dart' as dio_lib;
import 'package:get/get.dart';

import '../config/dio_config.dart';
import '../config/storage_config.dart';
import '../models/route.dart';
import '../utils/templates/dio_template.dart';

class RouteController extends GetxController {
  final isLoading = false.obs;
  final routes = <Route>[].obs;
  final searchResults = <Route>[].obs;
  final selectedRouteDetails = Rxn<Route>();

  @override
  void onInit() {
    super.onInit();
    fetchRoutes();
  }

  Future<void> fetchRoutes() async {
    isLoading.value = true;
    await DioService.dioGet(
      path: '/v1/routes',
      options: dio_lib.Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ConfigPreference.getAccessToken()}',
        },
      ),
      onSuccess: (response) {
        final List items = response.data['data']['items'] ?? [];
        routes.value = items.map((e) => Route.fromJson(e)).toList();
        isLoading.value = false;
      },
      onFailure: (error, response) => _handleError(error, response),
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
