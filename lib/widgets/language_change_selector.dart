import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/theme_mode_controller.dart';
import '../utils/languages.dart';
// import '../utils/screen_utils.dart';

class LanguageSelectorButton extends StatefulWidget {
  final Function() onChange;
  const LanguageSelectorButton({super.key, required this.onChange});

  @override
  State<LanguageSelectorButton> createState() => _LanguageSelectorButtonState();
}

class _LanguageSelectorButtonState extends State<LanguageSelectorButton> {
  late Timer timer;
  late bool changed = false;
  @override
  Widget build(BuildContext context) {
    // final bool isTablet = ScreenUtils.isTablet(context);
    ThemeData theme = Theme.of(context);
    return DropdownButtonHideUnderline(
      child: DropdownButton2<Language>(
        customButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Text(
                ThemeModeController.getLanguage(),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 5.w),
              const Icon(Icons.expand_circle_down, color: Colors.white),
            ],
          ),
        ),
        items: [
          ...Language.languages.map(
            (item) => DropdownItem<Language>(
              value: item,
              child: Text(
                item.name,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            Language.selectedLanguage = value!;
            Get.updateLocale(value.code);
            ThemeModeController.saveLanguage(value.code);
            changed = true;
          });
          widget.onChange();
        },
        dropdownStyleData: DropdownStyleData(
          width: 160,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          offset: const Offset(0, 8),
        ),
        menuItemStyleData: MenuItemStyleData(
          // customHeights: List<double>.filled(Language.languages.length, 48),
          padding: const EdgeInsets.only(left: 16, right: 16),
        ),
      ),
    );
  }
}
