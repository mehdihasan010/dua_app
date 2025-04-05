import 'dart:async';
import 'package:dua/core/base/base_presenter.dart';
import 'package:dua/core/utility/utility.dart';
import 'package:dua/presentation/home/presenter/home_ui_state.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';

class HomePresenter extends BasePresenter<HomeUiState> {
  HomePresenter() {
    _fetchPrayerTimes(); // Fetch prayer times on initialization
  }

  final Obs<HomeUiState> uiState = Obs(HomeUiState.empty());

  HomeUiState get currentUiState => uiState.value;

  // Prayer times will be fetched dynamically
  Map<String, String> prayerTimes = {
    'Fajr': '05:30',
    'Dhuhr': '12:00',
    'Asr': '3:30',
    'Maghrib': '5:45',
    'Isha': '7:15',
  };

  @override
  void onInit() {
    super.onInit();
    _updateTime();
    _scheduleDailyUpdate(); // Schedule daily update at midnight
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime(); // Update every second for real-time accuracy
    });
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      // Set location for Khilgaon, Dhaka
      final coordinates = Coordinates(
          23.7547, 90.4125); // Latitude, Longitude for Khilgaon, Dhaka
      final params = CalculationMethod.karachi.getParameters();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes.today(coordinates, params);

      // Format prayer times in 24-hour format (HH:mm)
      final Map<String, String> newPrayerTimes = {
        'Fajr': DateFormat('HH:mm').format(prayerTimes.fajr),
        'Dhuhr': DateFormat('HH:mm').format(prayerTimes.dhuhr),
        'Asr': DateFormat('HH:mm').format(prayerTimes.asr),
        'Maghrib': DateFormat('HH:mm').format(prayerTimes.maghrib),
        'Isha': DateFormat('HH:mm').format(prayerTimes.isha),
      };

      // Calculate Sehri and Iftar times
      final sehriTime = prayerTimes.fajr.subtract(const Duration(minutes: 15));
      final iftarTime = prayerTimes.maghrib;

      this.prayerTimes = newPrayerTimes;

      uiState.value = currentUiState.copyWith(
        sehriTime: DateFormat('hh:mm a').format(sehriTime),
        iftarTime: DateFormat('hh:mm a').format(iftarTime),
      );

      // Print for debugging
      print('Prayer Times: ${this.prayerTimes}');
      print('Sehri Time: ${DateFormat('hh:mm a').format(sehriTime)}');
      print('Iftar Time: ${DateFormat('hh:mm a').format(iftarTime)}');
    } catch (e) {
      print('Error fetching prayer times: $e');
    }
  }

  void _scheduleDailyUpdate() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final difference = midnight.difference(now);

    Timer(difference, () {
      _fetchPrayerTimes(); // Update timings at midnight
      _scheduleDailyUpdate(); // Reschedule for the next day
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm').format(now);
    final formattedAmPm = DateFormat('a').format(now);

    String? currentPrayer = _getCurrentPrayer(formattedTime);
    String? nextPrayer = _getNextPrayerTime(formattedTime);
    String remainingTime =
        _calculateRemainingTime(formattedTime, nextPrayer ?? '00:00');
    double progressValue =
        _calculateProgress(formattedTime, currentPrayer, nextPrayer);

    // Print for debugging
    //print('Current Time: $formattedTime, Remaining Time: $remainingTime');

    uiState.value = currentUiState.copyWith(
      currentTime: DateFormat('hh:mm').format(now),
      amPm: formattedAmPm,
      currentPrayer: currentPrayer,
      nextPrayerTime: nextPrayer,
      remainingTime: remainingTime,
      progressValue: progressValue,
    );
  }

  String? _getCurrentPrayer(String currentTime) {
    String? currentPrayer;
    for (var entry in prayerTimes.entries) {
      if (entry.value.compareTo(currentTime) <= 0) {
        currentPrayer = entry.key;
      }
    }
    return currentPrayer ?? prayerTimes.entries.last.key;
  }

  String? _getNextPrayerTime(String currentTime) {
    for (var time in prayerTimes.values) {
      if (time.compareTo(currentTime) > 0) {
        return time;
      }
    }
    return prayerTimes.values.first; // If past Isha, return Fajr of next day
  }

  String _calculateRemainingTime(String currentTime, String nextPrayerTime) {
    try {
      DateTime now = DateFormat('HH:mm').parse(currentTime);
      DateTime nextPrayer = DateFormat('HH:mm').parse(nextPrayerTime);

      // Handle crossing midnight
      if (nextPrayer.isBefore(now)) {
        nextPrayer = nextPrayer.add(const Duration(days: 1));
      }

      Duration difference = nextPrayer.difference(now);
      int hours = difference.inHours;
      int minutes = difference.inMinutes.remainder(60);
      int seconds = difference.inSeconds.remainder(60);

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00:00';
    }
  }

  double _calculateProgress(
      String currentTime, String? currentPrayer, String? nextPrayerTime) {
    if (currentPrayer == null || nextPrayerTime == null) return 0.0;

    try {
      DateTime now = DateFormat('HH:mm').parse(currentTime);
      DateTime prayerStart =
          DateFormat('HH:mm').parse(prayerTimes[currentPrayer] ?? '00:00');
      DateTime prayerEnd = DateFormat('HH:mm').parse(nextPrayerTime);

      // Handle crossing midnight
      if (prayerEnd.isBefore(prayerStart)) {
        prayerEnd = prayerEnd.add(const Duration(days: 1));
      }
      if (now.isBefore(prayerStart)) {
        return 0.0;
      }

      Duration totalDuration = prayerEnd.difference(prayerStart);
      Duration elapsedDuration = now.difference(prayerStart);

      double progress = elapsedDuration.inSeconds / totalDuration.inSeconds;
      return progress.clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<void> addUserMessage(String message) {
    return showMessage(message: message);
  }

  @override
  Future<void> toggleLoading({required bool loading}) {
    return toggleLoading(loading: loading);
  }
}
