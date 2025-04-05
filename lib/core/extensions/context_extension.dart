import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dua/presentation/dua_app.dart';

/// Extension to safely access BuildContext
extension ContextExtension on BuildContext? {
  /// Gets a safe context that won't throw exceptions
  /// If this context is null or invalid, falls back to navigator key or Get context
  static BuildContext? safeContext(BuildContext? context) {
    if (context != null) {
      return context;
    }

    // Try navigator key first
    if (DuaApp.navigatorKey.currentContext != null) {
      return DuaApp.navigatorKey.currentContext;
    }

    // Then try Get.context
    return Get.context;
  }

  /// Gets an overlay entry point safely
  static OverlayState? safeOverlay(BuildContext? context) {
    final ctx = safeContext(context);
    if (ctx == null) return null;

    try {
      // Check if an Overlay widget exists in the widget tree
      final NavigatorState? navigator = Navigator.maybeOf(ctx);
      if (navigator == null) {
        debugPrint('No Navigator found in context');
        return null;
      }

      // Try to get the overlay
      return Overlay.maybeOf(ctx);
    } catch (e) {
      debugPrint('Error getting overlay: $e');
      return null;
    }
  }

  /// Display a snackbar safely
  static void showSnackBar(String message,
      {BuildContext? context, Duration? duration}) {
    final ctx = safeContext(context);
    if (ctx == null) return;

    try {
      final scaffoldMessenger = ScaffoldMessenger.of(ctx);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration ?? const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error showing snackbar: $e');
    }
  }

  /// Navigate back safely
  static void safePop(BuildContext? context) {
    final ctx = safeContext(context);
    if (ctx == null) return;

    try {
      Navigator.of(ctx).pop();
    } catch (e) {
      // Fall back to Get navigation
      try {
        Get.back();
      } catch (e) {
        debugPrint('Error navigating back: $e');
      }
    }
  }
}
