import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/cards/error_card.dart';
import '../api_call_status.dart';
import '../error_data.dart';

class LoadedWidget extends StatelessWidget {
  final ApiCallStatus apiCallStatus;
  final ErrorData? errorData;
  final Widget child;
  final Widget? errorChild;
  final Widget loadingChild;
  final VoidCallback? onReload;
  const LoadedWidget(
      {super.key,
      required this.apiCallStatus,
      this.errorData,
      required this.child,
      required this.loadingChild,
      required this.errorChild,
      required this.onReload});

  @override
  Widget build(BuildContext context) {
    return apiCallStatus == ApiCallStatus.loading
        ? loadingChild
        : apiCallStatus == ApiCallStatus.error
            ? Center(
                child: errorChild ??
                    ErrorCard(errorData: errorData!, refresh: onReload!))
            : child;
  }
}

class LoadedListWidget extends StatelessWidget {
  ///Api call status governing this list
  final ApiCallStatus apiCallStatus;

  ///We will construct an error card based on this error data.
  ///You have to provide this if you don't want to provide your own error child
  final ErrorData? errorData;

  ///What you want to happen when a user encounters an error(if you haven't provided your own error child) or pulls down to refresh
  final Future<void> Function() onReload;

  ///What you want to display when the list is not empty, (set shrinkWrap to true if using a ListView)
  final Widget child;

  ///Your own custom widget to display when an error occurs
  final Widget? errorChild;

  ///What you want to display when the list is still loading
  final Widget loadingChild;

  ///The list you want to display
  final List list;

  ///What you want to display when the list is empty
  final Widget onEmpty;
  const LoadedListWidget(
      {super.key,
      required this.apiCallStatus,
      this.errorData,
      required this.child,
      required this.loadingChild,
      this.errorChild,
      required this.list,
      required this.onEmpty,
      required this.onReload});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onReload,
      child: apiCallStatus == ApiCallStatus.loading
          ? loadingChild
          : apiCallStatus == ApiCallStatus.error
              ? Center(
                  child: errorChild ??
                      ErrorCard(errorData: errorData!, refresh: onReload))
              : list.isEmpty
                  ? onEmpty
                  : SingleChildScrollView(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RefreshIndicator(
                              onRefresh: onReload,
                              child: child,
                            ),
                            SizedBox(height: 70.h),
                          ]),
                    ),
    );
  }
}
