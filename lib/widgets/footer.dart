import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/pages.dart';

class Footer extends StatelessWidget {
  final bool isLogin;
  const Footer({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
      child: GestureDetector(
        onTap: () {
          if (isLogin) {
            Get.toNamed(AppRoutes.signupRoute);
          } else {
            Get.toNamed(AppRoutes.loginRoute);
          }
        },
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: isLogin ? 'no_account'.tr : 'have_account'.tr,
                style: const TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: isLogin ? 'sign_up_here'.tr : 'log_in_here'.tr,
                style: const TextStyle(
                  fontFamily: 'Readex Pro',
                  color: Color(0xFF4B39EF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          textScaler: TextScaler.linear(
            MediaQuery.of(context).textScaler.textScaleFactor,
          ),
        ),
      ),
    );
  }
}
