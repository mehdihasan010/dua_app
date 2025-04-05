import 'package:dua/core/base/base_ui_state.dart';

class HomeUiState extends BaseUiState {
  const HomeUiState({
    required super.isLoading,
    required super.userMessage,
    required this.count,
    this.currentTime,
    this.amPm,
    this.currentPrayer,
    this.nextPrayerTime,
    this.remainingTime,
    this.progressValue = 0.0,
    this.sehriTime,
    this.iftarTime,
  });

  factory HomeUiState.empty() {
    return HomeUiState(
      isLoading: false,
      userMessage: '',
      count: 0,
      currentTime: '12:27',
      amPm: 'PM',
      currentPrayer: 'Dhuhr',
      nextPrayerTime: '13:54', // Placeholder (Dhuhr)
      remainingTime: '01:27:00', // Placeholder
      progressValue: 0.0,
      sehriTime: '04:45 AM',
      iftarTime: '06:00 PM',
    );
  }

  final int count;
  final String? currentTime;
  final String? amPm;
  final String? currentPrayer;
  final String? nextPrayerTime;
  final String? remainingTime;
  final double progressValue;
  final String? sehriTime;
  final String? iftarTime;

  @override
  List<Object?> get props => [
        isLoading,
        userMessage,
        count,
        currentTime,
        amPm,
        currentPrayer,
        nextPrayerTime,
        remainingTime,
        progressValue,
        sehriTime,
        iftarTime,
      ];

  HomeUiState copyWith({
    bool? isLoading,
    String? userMessage,
    int? count,
    String? currentTime,
    String? amPm,
    String? currentPrayer,
    String? nextPrayerTime,
    String? remainingTime,
    double? progressValue,
    String? sehriTime,
    String? iftarTime,
  }) {
    return HomeUiState(
      isLoading: isLoading ?? this.isLoading,
      userMessage: userMessage ?? this.userMessage,
      count: count ?? this.count,
      currentTime: currentTime ?? this.currentTime,
      amPm: amPm ?? this.amPm,
      currentPrayer: currentPrayer ?? this.currentPrayer,
      nextPrayerTime: nextPrayerTime ?? this.nextPrayerTime,
      remainingTime: remainingTime ?? this.remainingTime,
      progressValue: progressValue ?? this.progressValue,
      sehriTime: sehriTime ?? this.sehriTime,
      iftarTime: iftarTime ?? this.iftarTime,
    );
  }
}
