import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../config/storage_config.dart';
import '../constants/constants.dart';
import '../constants/pages.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.headers.containsKey('Authorization')) {
      return super.onRequest(options, handler);
    }

    if (ConfigPreference.isAccessTokenExpired()) {
      final newToken = await _refreshAccessToken();
      if (newToken == null) {
        await ConfigPreference.clearTokens();
        Logger().i('Here 6');
        Get.toNamed(AppRoutes.loginRoute);
      }
    }

    final token = ConfigPreference.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final newToken = await _refreshAccessToken();
      if (newToken != null) {
        // Retry original request with new token
        final req = err.requestOptions;
        req.headers['Authorization'] = 'Bearer $newToken';
        final cloneResponse = await (await DioConfig.dio()).fetch(req);
        return handler.resolve(cloneResponse);
      } else {
        await ConfigPreference.clearTokens();
        Logger().i('Here 5');
        Get.toNamed(AppRoutes.loginRoute);
      }
    }
    return handler.next(err);
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = ConfigPreference.getRefreshToken();
    if (refreshToken == null) return null;
    try {
      final dio = Dio(BaseOptions(baseUrl: kApiBaseUrl));
      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken =
            response.data['refreshToken'] ?? refreshToken; // fallback
        await ConfigPreference.setTokens(
          response.data,
          newAccessToken,
          newRefreshToken,
          response.data['expiresIn'],
        );
        return newAccessToken;
      }
    } catch (e) {
      Logger().e('Token refresh failed', error: e);
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
    });
    super.onRequest(options, handler);
  }
}

class DioConfig {
  static PersistCookieJar? cookieJar;

  static Future<Dio> dio() async {
    if (cookieJar == null) {
      final dir = await getApplicationDocumentsDirectory();
      cookieJar = PersistCookieJar(
        storage: FileStorage('${dir.path}/.cookies/'),
      );
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: kApiBaseUrl,
        validateStatus: (status) => true,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );

    dio.interceptors.addAll([
      // CookieManager(cookieJar!), // 👈 enables cookie/session persistence
      LoggingInterceptor(),
      // AuthInterceptor(),
    ]);

    return dio;
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
