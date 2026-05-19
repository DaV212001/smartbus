import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChapaPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  const ChapaPaymentScreen({super.key, required this.paymentUrl});

  @override
  State<ChapaPaymentScreen> createState() => _ChapaPaymentScreenState();
}

class _ChapaPaymentScreenState extends State<ChapaPaymentScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _isNavigatedBack = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (String url) {
            _checkSuccessUrl(url);
          },
          onPageFinished: (String url) {
            _checkSuccessUrl(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (_checkSuccessUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _checkSuccessUrl(String url) {
    if (_isNavigatedBack) return true;
    debugPrint('SmartBus Payment URL Log: $url');
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('receipt') ||
        lowerUrl.contains('status=mock_success') ||
        lowerUrl.contains('status=success') ||
        lowerUrl.contains('payment/success')) {
      _isNavigatedBack = true;
      Get.back(result: true);
      return true;
    }
    return false;
  }

  Future<bool> _onWillPop() async {
    final theme = Theme.of(context);
    final shouldPop = await Get.dialog<bool>(
      AlertDialog(
        title: Text('cancel_payment_title'.tr),
        content: Text('cancel_payment_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('no'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Get.back(result: true),
            child: Text('yes_cancel'.tr),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Get.back(result: false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.cardColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: theme.iconTheme.color),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop) {
                Get.back(result: false);
              }
            },
          ),
          title: Text(
            'payment_checkout'.tr,
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: _loadingProgress < 100
                ? LinearProgressIndicator(
                    value: _loadingProgress / 100.0,
                    backgroundColor: theme.dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  )
                : Container(color: theme.dividerColor, height: 1),
          ),
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
