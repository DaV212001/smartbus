import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:smartbus/screens/login_screen.dart';

import '../../config/storage_config.dart';
import '../../constants/constants.dart';
import '../../controllers/theme_mode_controller.dart';
import '../../controllers/user_controller.dart';
import '../../widgets/cards/profile_list_card.dart';
import '../../widgets/language_change_selector.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final List<Map<String, dynamic>> routesList = [
    // {
    //   'name': 'my_wallet'.tr,
    //   'icon': EneftyIcons.wallet_2_bold,
    //   'onTap': () {
    //     SocketController.instance.emitTripUpdate();
    //   },
    //   'isFirstTile': true,
    //   'isLastTile': true,
    // },
    {
      'name': 'help_support'.tr,
      'icon': Ionicons.help_circle,
      'onTap': () {},
      'isFirstTile': true,
      'isLastTile': false,
    },
    {
      'name': 'about_us'.tr,
      'icon': EneftyIcons.info_circle_bold,
      'onTap': () {},
      'isFirstTile': false,
      'isLastTile': false,
    },
    {
      'name': 'terms_conditions'.tr,
      'icon': Ionicons.document_text,
      'onTap': () {},
      'isFirstTile': false,
      'isLastTile': false,
    },
    {
      'name': 'privacy_policy'.tr,
      'icon': Ionicons.lock_closed,
      'onTap': () {},
      'isFirstTile': false,
      'isLastTile': true,
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: BoxDecoration(
                color: ThemeModeController.isLightTheme.value
                    ? maincolor
                    : Theme.of(context).cardColor,
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LanguageSelectorButton(onChange: () {}),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: maincolor),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AnimatedToggleSwitch<bool>.dual(
                              current: ThemeModeController.isLightTheme.value,
                              first: false,
                              second: true,
                              borderWidth: 0.0,
                              height: 40,
                              onChanged: (val) {
                                ThemeModeController.toggleThemeMode(); // Toggle theme
                              },
                              style: ToggleStyle(
                                indicatorColor:
                                    ThemeModeController.isLightTheme.value
                                    ? maincolor
                                    : null,
                                // backgroundGradient: LinearGradient(colors: [
                                //   ThemeModeController.isLightTheme.value
                                //       ? Colors.white
                                //       : maincolor,
                                //   ThemeModeController.isLightTheme.value
                                //       ? Colors.grey
                                //       : Colors.black
                                // ]),
                                indicatorBorder: Border.all(
                                  color: ThemeModeController.isLightTheme.value
                                      ? Colors.white
                                      : maincolor,
                                ),
                              ),
                              iconBuilder: (value) => value
                                  ? const Icon(
                                      Icons.light_mode,
                                      color: Colors.white,
                                    )
                                  : const Icon(
                                      Icons.dark_mode,
                                      color: Colors.white,
                                    ),
                              textBuilder: (value) => value
                                  ? const Center(child: Text('Light'))
                                  : const Center(child: Text('Dark')),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24,
                        left: 8,
                        right: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                EneftyIcons.profile_circle_bold,
                                color: !ThemeModeController.isLightTheme.value
                                    ? maincolor
                                    : Colors.white,
                                size: MediaQuery.of(context).size.width * 0.2,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Obx(
                                    () => SizedBox(
                                      width:
                                          (MediaQuery.of(context).size.width *
                                              0.48) -
                                          16,
                                      child: AutoSizeText(
                                        '${UserController.instance.user.value?.firstName ?? 'Guest'} ${UserController.instance.user.value?.lastName ?? 'User'}',
                                        maxLines: 1,
                                        minFontSize: 9,
                                        maxFontSize: 16,
                                        stepGranularity: 0.5,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Obx(() => SizedBox(
                                  //       width:
                                  //           (MediaQuery.of(context).size.width *
                                  //                   0.48) -
                                  //               16,
                                  //       child: AutoSizeText(
                                  //         '+${UserController.user.value.phone ?? ''}',
                                  //         maxLines: 1,
                                  //         minFontSize: 5,
                                  //         maxFontSize: 12,
                                  //         stepGranularity: 0.5,
                                  //         style: TextStyle(
                                  //             color: Colors.white,
                                  //             fontSize: 12.sp),
                                  //       ),
                                  //     )),
                                  Obx(
                                    () => Text(
                                      (UserController
                                                  .instance
                                                  .user
                                                  .value
                                                  ?.email ??
                                              'guest@email.com')
                                          .toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ...routesList.map(
                    (e) => ProfileListCard(
                      icon: e['icon'],
                      name: e['name'],
                      onTap: e['onTap'],
                      isFirstTile: e['isFirstTile'],
                      isLastTile: e['isLastTile'],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ConfigPreference.logOut();
                    Get.offAll(LoginScreen());
                  },
                  child: Text(
                    'logout'.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
