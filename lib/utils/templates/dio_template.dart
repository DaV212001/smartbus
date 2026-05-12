import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../config/dio_config.dart';

class DioService {
  static Future<void> dioPost({
    required String path,
    Options? options,
    Object? data,
    Function(Response)? onSuccess,
    Function(Object, Response)? onFailure,
  }) async {
    Response response = Response(requestOptions: RequestOptions());
    try {
      response = await (await DioConfig.dio()).post(
        path,
        options: options,
        data: data,
      );
      Logger().d(response.statusCode);
      Logger().d(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (onSuccess != null) onSuccess(response);
      } else {
        if (onFailure != null) onFailure(response.statusCode!, response);
      }
    } catch (e, stack) {
      Logger().d(path);
      Logger().t(e.toString(), stackTrace: stack);
      // print(response.data);
      print(e.toString());
      print(stack);
      if (onFailure != null) onFailure(e, response);
    }
  }

  static Future<void> dioGet({
    required String path,
    Options? options,
    Object? data,
    Function(Response)? onSuccess,
    Function(Object, Response)? onFailure,
    Map<String, String>? queryParameters,
  }) async {
    Response response = Response(
      requestOptions: RequestOptions(queryParameters: queryParameters),
    );
    try {
      response = await (await DioConfig.dio()).get(
        path,
        options: options,
        data: data,
      );
      print(response.data);
      Logger().d(response.data);
      if (response.statusCode == 200) {
        if (onSuccess != null) onSuccess(response);
      } else {
        if (onFailure != null) onFailure(response.statusCode!, response);
      }
    } catch (e, stack) {
      Logger().d(path);
      Logger().t(e.toString(), stackTrace: stack);
      // print(response.data);
      print(e.toString());
      print(stack);
      if (onFailure != null) onFailure(e, response);
    }
  }
}
