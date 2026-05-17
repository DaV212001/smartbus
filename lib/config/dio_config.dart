import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../config/storage_config.dart';
import '../constants/constants.dart';
import '../constants/pages.dart';

class AuthInterceptor extends Interceptor {
  static Future<String?>? _refreshFuture;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip for auth endpoints to avoid infinite loops
    if (options.path.contains('/auth/')) {
      return handler.next(options);
    }

    if (ConfigPreference.isAccessTokenExpired()) {
      Logger().d('Token expired proactive check. Refreshing...');
      final newToken = await _refreshAccessToken();
      if (newToken == null) {
        await ConfigPreference.clearTokens();
        Get.offAllNamed(AppRoutes.loginRoute);
        return;
      }
    }

    final token = ConfigPreference.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/')) {
      Logger().d('401 Unauthorized detected. Attempting reactive refresh...');
      // Try to refresh token
      final newToken = await _refreshAccessToken();
      if (newToken != null) {
        // Retry original request with new token
        final req = err.requestOptions;
        req.headers['Authorization'] = 'Bearer $newToken';

        // Use the same Dio instance (which is a singleton) to retry
        final dio = await DioConfig.dio();
        try {
          final cloneResponse = await dio.fetch(req);
          return handler.resolve(cloneResponse);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        await ConfigPreference.clearTokens();
        Get.offAllNamed(AppRoutes.loginRoute);
        return;
      }
    }
    return handler.next(err);
  }

  Future<String?> _refreshAccessToken() async {
    // If a refresh is already in progress, join that future
    if (_refreshFuture != null) {
      Logger().d('Token refresh already in progress, joining future...');
      return _refreshFuture;
    }

    _refreshFuture = _performTokenRefresh();
    try {
      final result = await _refreshFuture;
      return result;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<String?> _performTokenRefresh() async {
    Logger().d('Starting token refresh request...');
    final refreshToken = ConfigPreference.getRefreshToken();
    if (refreshToken == null) {
      Logger().e('No refresh token found in storage');
      return null;
    }

    try {
      // Create a dedicated Dio instance for refresh to avoid interceptor recursion
      final dio = Dio(
        BaseOptions(
          baseUrl: kApiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await dio.post(
        '/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      Logger().d('Refresh response: ${response.data}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data['data'];
        if (data != null) {
          final newAccessToken = data['accessToken'];
          final newRefreshToken = data['refreshToken'] ?? refreshToken;
          final expiresIn = data['expiresIn'] ?? 3600;

          if (newAccessToken != null) {
            await ConfigPreference.updateTokens(
              newAccessToken,
              newRefreshToken,
              expiresIn,
            );
            Logger().i('Token refresh successful');
            return newAccessToken;
          }
        }
      }
      Logger().e(
        'Token refresh failed: Invalid response or status ${response.statusCode}',
      );
    } catch (e) {
      Logger().e('Token refresh failed with exception', error: e);
    }
    return null;
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger().i({
      'url': options.uri.toString(),
      'method': options.method,
      'headers': options.headers,
      'body': options.data,
      'queryParameters': options.queryParameters,
    });
    super.onRequest(options, handler);
  }
}

class DioConfig {
  static PersistCookieJar? cookieJar;
  static Dio? _dioInstance;

  static Future<Dio> dio() async {
    if (_dioInstance != null) return _dioInstance!;

    if (cookieJar == null) {
      final dir = await getApplicationDocumentsDirectory();
      cookieJar = PersistCookieJar(
        storage: FileStorage('${dir.path}/.cookies/'),
      );
    }

    _dioInstance = Dio(
      BaseOptions(
        baseUrl: kApiBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );

    _dioInstance!.interceptors.addAll([
      // CookieManager(cookieJar!), // 👈 enables cookie/session persistence
      LoggingInterceptor(),
      AuthInterceptor(),
    ]);

    return _dioInstance!;
  }

  static String convertDioError(DioException e) {
    String errorMessage = 'Unknown error occurred';
    switch (e.type) {
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout';
        break;
      case DioExceptionType.badResponse:
        errorMessage =
            'HTTP error ${e.response!.statusCode}: ${e.response!.statusMessage}';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Other Dio error occurred';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Bad certificate, try switching devices';
      case DioExceptionType.connectionError:
        errorMessage = 'Connection error, check your internet';
    }
    return errorMessage;
  }
}
