import 'dart:async';

import 'package:dua/core/base/base_presenter.dart';
import 'package:dua/core/base/base_ui_state.dart';
import 'package:dua/core/utility/logger_utility.dart';
import 'package:dua/core/utility/trial_utility.dart';
import 'package:dua/core/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _fileName = 'ui_helper.dart';

class UiHelper {
  UiHelper._();

  static Future<void> onMessage<T extends BaseUiState>(
    Obs<T> uiStateStream,
  ) async {
    StreamSubscription<T>? subscription;
    await doOnPageLoaded(() {
      try {
        subscription = uiStateStream.listen(
          (uiState) => showMessage(
            message: uiState.userMessage,
          ),
          onDone: () => subscription?.cancel(),
          onError: (e) => subscription?.cancel(),
          cancelOnError: true,
        );
      } catch (e) {
        logErrorStatic(e, _fileName);
        subscription?.cancel();
        subscription = null;
      }
    });
  }

  static bool onScrollNotification({
    required ScrollNotification scrollNotification,
    required void Function({required bool toTop}) onScrolled,
  }) {
    if (scrollNotification is! ScrollUpdateNotification) return false;
    final bool reachedAtTop = scrollNotification.metrics.pixels == 0;
    onScrolled(toTop: reachedAtTop);
    return false;
  }

  // static Future<void> onNoteClick({
  //   required HadithEntity hadith,
  //   required Future<List<BookmarkEntity>> Function() onGetFolders,
  //   required Future<bool> Function(HadithEntity, BookmarkEntity?)
  //       onNoteIconTapped,
  //   required BuildContext context,
  // }) async {
  //   // If the Hadith is not bookmarked, show a dialog to select the bookmark folder.
  //   await AddNoteBottomSheet.show(
  //     hadith: hadith,
  //     onGetFolders: onGetFolders,
  //     onBookmarkAdded: (hadith, folder) => onNoteIconTapped(hadith, folder),
  //     context: context,
  //   );
  // }

  static Future<void> doOnPageLoaded(void Function() onLoaded) async {
    // Takes a callback function onLoaded as a parameter. When called, this
    // method schedules the onLoaded callback to be executed after the current
    // frame has finished rendering, by adding it to the end of the post-frame
    // callbacks list using WidgetsBinding.instance.addPostFrameCallback.
    //
    // To add a slight delay to the execution of the onLoaded callback, the
    // method also uses Future.delayed to wait for 64 milliseconds before
    // invoking the callback. The entire method is wrapped in a
    // catchFutureOrVoid function which catches any exceptions thrown during the
    // execution of the callback and handles them appropriately.
    await catchFutureOrVoid(() async {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        onLoaded();
      });
    });
  }

  static void doOnPageDestroy(VoidCallback onDestroy) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onDestroy();
    });
  }

  static Future<void> toggleFullScreen({required bool makeFullScreen}) async {
    await catchFutureOrVoid(() async {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: makeFullScreen ? [] : SystemUiOverlay.values,
      );
    });
  }

  /// Listens to the scroll events and triggers the provided callback function when scrolled.
  ///
  /// The [scrollController] is an instance of [ItemScrollController] that controls the scrolling behavior.
  /// The [onScrolled] is a callback function that takes a boolean parameter [toTop] indicating whether the scroll is towards the top or not.
  ///
  /// Example usage:
  /// ```dart
  /// await UiHelper.listenToScroll(
  ///   scrollController: myScrollController,
  ///   onScrolled: ({required bool toTop}) {
  ///     // Handle scroll event
  ///   },
  /// );
  /// ```
}
