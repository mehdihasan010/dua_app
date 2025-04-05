// toast_utility.dart

import 'package:dua/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom_toast.dart';
import 'debouncer.dart';

class ToastUtility {
  static final Debouncer _debouncer = Debouncer(milliseconds: 1300);

  static void showCustomToast({
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    double fontSize = 16.0,
    double xOffset = 0.0,
    double yOffset = 50.0,
    BuildContext? context,
  }) {
    _debouncer.run(() {
      // Get safe overlay using extension
      final overlay = ContextExtension.safeOverlay(context);

      // If we don't have a valid overlay, use GetX snackbar as fallback
      if (overlay == null) {
        debugPrint(
            'Toast Warning: No valid overlay, using GetX snackbar instead');
        Get.rawSnackbar(
          message: message,
          duration: duration,
          backgroundColor: backgroundColor,
          borderRadius: 8,
          margin: const EdgeInsets.all(8),
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final overlayEntry = OverlayEntry(
        builder: (context) => CustomToast(
          message: message,
          duration: duration,
          xOffset: xOffset,
          yOffset: yOffset,
        ),
      );

      overlay.insert(overlayEntry);

      Future.delayed(duration + const Duration(milliseconds: 300), () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
    });
  }

  static void dispose() {
    _debouncer.dispose();
  }
}
