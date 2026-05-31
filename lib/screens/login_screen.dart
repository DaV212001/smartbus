import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smartbus/controllers/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'login'.tr,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Theme.of(context).dividerColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Obx(
              () => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    _buildTypeToggle(
                      context,
                      'PHONE',
                      LucideIcons.phone,
                      'Phone',
                    ),
                    _buildTypeToggle(
                      context,
                      'EMAIL',
                      LucideIcons.mail,
                      'Email',
                    ),
                    _buildTypeToggle(context, 'Fayda ID', LucideIcons.qrCode, 'Fayda ID'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.loginType.value == 'PHONE') {
                return _buildInputField(
                  context: context,
                  controller: controller.phoneController,
                  label: 'phone_number'.tr,
                  icon: LucideIcons.phone,
                  hint: '09xxxxxxxx',
                  keyboardType: TextInputType.phone,
                );
              } else if (controller.loginType.value == 'EMAIL') {
                return _buildInputField(
                  context: context,
                  controller: controller.emailController,
                  label: 'email'.tr,
                  icon: LucideIcons.mail,
                  hint: 'example@mail.com',
                  keyboardType: TextInputType.emailAddress,
                );
              } else {
                return _buildInputField(
                  context: context,
                  controller: controller.fidController,
                  label: 'Fayda ID',
                  icon: LucideIcons.qrCode,
                  hint: '16-character Fayda ID',
                  suffixIcon: IconButton(
                    icon: const Icon(
                      LucideIcons.scanLine,
                      color: Color(0xFF2563EB),
                    ),
                    onPressed: controller.scanBarcode,
                  ),
                );
              }
            }),
            const SizedBox(height: 20),
            Obx(
              () => _buildInputField(
                context: context,
                controller: controller.passwordController,
                label: 'password'.tr,
                icon: LucideIcons.lock,
                hint: '••••••••',
                isPassword: true,
                obscureText: !controller.isPasswordVisible.value,
                toggleVisibility: controller.togglePasswordVisibility,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.toNamed('/forgot-password'),
                child: Text(
                  'forgot_password'.tr,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.login,
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
                          'login'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'dont_have_account'.tr,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/signup'),
                  child: Text(
                    'sign_up'.tr,
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle(
    BuildContext context,
    String type,
    IconData icon,
    String label,
  ) {
    final isSelected = controller.loginType.value == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setLoginType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                        color: const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: toggleVisibility,
                    )
                  : suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
