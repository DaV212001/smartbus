import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smartbus/controllers/auth_controller.dart';

class OtpScreen extends GetView<AuthController> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'verification'.tr,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Theme.of(context).dividerColor, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'verify_code'.tr,
                    style: TextStyle(
                      color:
                          Theme.of(context).textTheme.headlineMedium?.color ??
                          const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'otp_prompt'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  const SizedBox(height: 48),

                  // OTP Input Fields
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        6,
                        (index) => _buildOtpDigit(index, context),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'verify'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'dont_receive_code'.tr,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  Obx(
                    () => TextButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.resendOtp,
                      child: Text(
                        controller.isLoading.value
                            ? 'resending'.tr
                            : 'resend_code'.tr,
                        style: TextStyle(
                          color: controller.isLoading.value
                              ? Colors.grey
                              : const Color(0xFF2563EB),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Custom On-Screen Keypad for OTP entry
          _buildCustomKeypad(context),
        ],
      ),
    );
  }

  Widget _buildOtpDigit(int index, BuildContext context) {
    final String digit = controller.otp.value.length > index
        ? controller.otp.value[index]
        : "";
    return Container(
      width: 45,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: digit.isNotEmpty
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor,
          width: digit.isNotEmpty ? 2 : 1,
        ),
      ),
      child: Text(
        digit,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildCustomKeypad(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 32,
        childAspectRatio: 1.6,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 1; i <= 9; i++)
            _buildKeypadButton(
              i.toString(),
              context,
              onTap: () => controller.handleOtpInput(i.toString()),
            ),
          const SizedBox(),
          _buildKeypadButton(
            '0',
            context,
            onTap: () => controller.handleOtpInput('0'),
          ),
          _buildKeypadButton(
            'backspace',
            context,
            onTap: controller.handleOtpBackspace,
            isIcon: true,
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(
    String content,
    BuildContext context, {
    required VoidCallback onTap,
    bool isIcon = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: isIcon
            ? Icon(
                LucideIcons.delete,
                color: Theme.of(context).iconTheme.color,
                size: 28,
              )
            : Text(
                content,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
      ),
    );
  }
}
