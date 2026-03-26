import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../constants/assets.dart';
import 'error_data.dart';

class ErrorUtil {
  /// Returns an [ErrorData] object based on the provided [error] string.
  ///
  /// The function checks the [error] string for specific error codes and error messages
  /// and returns the corresponding [ErrorData] object. If the [error] string does not
  /// match any of the specific error codes or error messages, it returns an [ErrorData]
  /// object with a generic "Unknown Error" title, body, image, and button text.
  ///
  /// Parameters:
  /// - [error] (String): The error string to be checked.
  ///
  /// Returns:
  /// - [ErrorData]: An object containing the error title, body, image, and button text.
  static Future<ErrorData> getErrorData(String error,
      {String? customMessage}) async {
    print("Here in error Util $error");

    var connectivityResult = await (Connectivity().checkConnectivity());
    // Logger().d(connectivityResult);
    // Logger().d(connectivityResult[0] == ConnectivityResult.none);
    if (connectivityResult[0] == ConnectivityResult.none) {
      return ErrorData(
        title: "no_internet".tr,
        body: "no_internet_description".tr,
        image: 'assets/images/errors/no_connection.svg',
        buttonText: "retry".tr,
      );
    }

    if (error.contains("no_internet") ||
        error.toString().contains('No Internet Found') ||
        error.contains('Failed host lookup') ||
        error.contains('No address associated with hostname') ||
        error.contains('Connection refused') ||
        error.contains('Connection reset by peer') ||
        error.contains('ClientException with SocketException') ||
        error.contains('Connection timed out') ||
        error.contains('connection timeout') ||
        error.contains('receive timeout') ||
        error.contains('Connection closed')) {
      return ErrorData(
        title: "",
        body: "check_connection".tr,
        image: 'assets/images/errors/no_connection.svg',
        buttonText: "refresh".tr,
      );
    } else if (error.contains("500") ||
        error.toString().contains('Internal Server Error')) {
      return ErrorData(
        title: "internal_server_error".tr,
        body: customMessage ?? "internal_server_error_desc".tr,
        image: Assets.errorsInternalServer,
        buttonText: "refresh".tr,
      );
    } else if (error.contains("503")) {
      return ErrorData(
        title: "service_unavailable".tr,
        body: customMessage ?? "service_unavailable_desc".tr,
        image: Assets.errorsServiceUnavailable,
        buttonText: "refresh".tr,
      );
    } else if (error.contains("404")) {
      return ErrorData(
        title: "not_found".tr,
        body: customMessage ?? "not_found_desc".tr,
        image: Assets.errorsNotFound,
        buttonText: "refresh".tr,
      );
    } else if (error.contains("504")) {
      return ErrorData(
        title: "gateway_timeout".tr,
        body: customMessage ?? "gateway_timeout_desc".tr,
        image: Assets.errorsGatewayTimeout,
        buttonText: "refresh".tr,
      );
    } else if (error.contains("401")) {
      return ErrorData(
        title: "unauthorized".tr,
        body: customMessage ?? "unauthorized_desc".tr,
        image: Assets.errorsUnauthorized,
        buttonText: "refresh".tr,
      );
    } else if (error.contains("403")) {
      return ErrorData(
        title: "forbidden".tr,
        body: customMessage ?? "forbidden_desc".tr,
        image: Assets.errorsForbidden,
        buttonText: "refresh".tr,
      );
    } else if (error.contains("429")) {
      return ErrorData(
        title: "too_many_requests".tr,
        body: customMessage ?? "too_many_requests_desc".tr,
        image: Assets.errorsTooManyRequests,
        buttonText: "retry".tr,
      );
    } else if (error.startsWith('custom')) {
      return ErrorData(
        title: "error".tr,
        body: error.replaceFirst('custom', ''),
        image: Assets.errorsUnknown,
        buttonText: "refresh".tr,
      );
    } else {
      return ErrorData(
        title: "unknown_error".tr,
        body: 'unexpected_error'.tr,
        image: Assets.errorsUnknown,
        buttonText: "refresh".tr,
      );
    }
  }
}

Future<void> errorReport(dio.Response<dynamic> response) async {
  Map errorMap = {};
  String errorString = '';
  if (response.data is Map) {
    Logger().d('Map');
    errorMap = response.data;
    if (errorMap.containsKey('errors')) {
      Logger().d('List');
      List<dynamic> errorList = errorMap['errors'];
      for (var error in errorList) {
        if (error.containsKey('message')) {
          Get.snackbar('Error', error['message']);
        } else {
          Get.snackbar('Error', error as String);
        }
      }
    } else if (errorMap.containsKey('error')) {
      errorString = errorMap['error'];
      Get.snackbar('Error', errorString);
    } else {
      errorString = (await ErrorUtil.getErrorData(response.toString())).body;
      Get.snackbar('Error', errorString);
    }
  } else {
    errorString = (await ErrorUtil.getErrorData(response.toString())).body;
    Get.snackbar('Error', errorString);
  }
}
