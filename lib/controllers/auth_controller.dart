import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/dio_config.dart';
import '../config/storage_config.dart';
import '../utils/templates/dio_template.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  // Form controllers
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final fidController = TextEditingController();
  final nameController = TextEditingController();
  final otpController = TextEditingController();
  final otp = "".obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  void handleOtpInput(String value) {
    if (otp.value.length < 6) {
      otp.value += value;
    }
  }

  void handleOtpBackspace() {
    if (otp.value.isNotEmpty) {
      otp.value = otp.value.substring(0, otp.value.length - 1);
    }
  }

  Future<void> login() async {
    final identifier = identifierController.text.trim();
    final password = passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Determine identifierType
    String identifierType = 'FID'; // Default
    if (GetUtils.isEmail(identifier)) {
      identifierType = 'EMAIL';
    } else if (RegExp(r'^(09|07)\d{8}$').hasMatch(identifier) ||
        GetUtils.isPhoneNumber(identifier)) {
      identifierType = 'PHONE';
    }

    isLoading.value = true;
    await DioService.dioPost(
      path: '/v1/auth/login',
      data: {
        'identifier': identifier,
        'identifierType': identifierType,
        'password': password,
      },
      onSuccess: (response) async {
        final data = response.data['data'];
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final expiresIn = data['expiresIn'] ?? 3600;

        await ConfigPreference.setTokens(
          data['user'],
          accessToken,
          refreshToken,
          expiresIn,
        );
        isLoading.value = false;
        Get.offAllNamed('/home');
      },
      onFailure: (error, response) => _handleError(error, response),
    );
  }

  Future<void> register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    await DioService.dioPost(
      path: '/v1/auth/register',
      data: {
        'fullName': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'password': passwordController.text,
        'fid': fidController.text,
      },
      onSuccess: (response) {
        isLoading.value = false;
        Get.toNamed('/verify-otp', arguments: {'phone': phoneController.text});
      },
      onFailure: (error, response) => _handleError(error, response),
    );
  }

  Future<void> verifyOtp() async {
    if (otp.value.length < 6) {
      Get.snackbar(
        'Error',
        'Please enter valid OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    final phone = Get.arguments?['phone'] ?? phoneController.text;

    await DioService.dioPost(
      path: '/v1/auth/verify-otp',
      data: {'phone': phone, 'code': otp.value, 'purpose': 'REGISTRATION'},
      onSuccess: (response) async {
        final data = response.data['data'];

        if (data != null && data['accessToken'] != null) {
          final accessToken = data['accessToken'];
          final refreshToken = data['refreshToken'];
          final expiresIn = data['expiresIn'] ?? 3600;

          await ConfigPreference.setTokens(
            data,
            accessToken,
            refreshToken,
            expiresIn,
          );
          isLoading.value = false;
          Get.offAllNamed('/home');
        } else {
          isLoading.value = false;
          Get.snackbar(
            'Success',
            data?['message'] ?? 'Account verified successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.offAllNamed('/login');
        }
      },
      onFailure: (error, response) => _handleError(error, response),
    );
  }

  Future<void> resendOtp() async {
    isLoading.value = true;
    final phone = Get.arguments?['phone'] ?? phoneController.text;

    await DioService.dioPost(
      path: '/v1/auth/resend-otp',
      data: {'phone': phone, 'purpose': 'REGISTRATION'},
      onSuccess: (response) {
        isLoading.value = false;
        Get.snackbar(
          'Success',
          'OTP has been resent successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
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

  Future<void> logout() async {
    await ConfigPreference.clearTokens();
    Get.offAllNamed('/login');
  }
}
