import 'package:dua/core/config/app_images.dart';
import 'package:dua/core/external_libs/presentable_widget_builder.dart';
import 'package:dua/core/static/ui_const.dart';
import 'package:dua/presentation/home/presenter/home_presenter.dart';
import 'package:dua/presentation/home/widgets/date_info.dart';
import 'package:dua/presentation/home/widgets/next_prayer_info.dart';
import 'package:flutter/material.dart';
import 'package:dua/core/config/dua_screen.dart';

class PrayerCard extends StatelessWidget {
  final ThemeData theme;
  final HomePresenter presenter;
  const PrayerCard({super.key, required this.theme, required this.presenter});

  @override
  Widget build(BuildContext context) {
    return PresentableWidgetBuilder<HomePresenter>(
        presenter: presenter,
        builder: () {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.banner),
                fit: BoxFit.cover,
              ),
              borderRadius: radius30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationRow(context: context, theme: theme),
                gapH22,
                _buildPrayerTimeInfo(),
                gapH8,
                _buildProgressBar(context),
                gapH4,
                _buildRemainingTime(),
                const SizedBox(height: 22),
                _buildBottomRow(),
              ],
            ),
          );
        });
  }

  Widget _buildLocationRow({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 18, color: Color(0xFF282E29)),
        const SizedBox(width: 8),
        Text(
          'Khilgaon, Dhaka',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildPrayerTimeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          presenter.currentUiState.currentPrayer ?? 'Dhuhr',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF282E29),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: presenter.currentUiState.currentTime.toString(),
                style: TextStyle(
                  fontSize: twentyEightPx,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6E833F),
                ),
              ),
              TextSpan(
                text: ' ${presenter.currentUiState.amPm} ',
                style: TextStyle(
                  fontSize: thirteenPx,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6E833F),
                ),
              ),
              TextSpan(
                text: ' to ',
                style: TextStyle(
                  fontSize: twelvePx,
                  color: const Color(0xFF282E29),
                ),
              ),
              TextSpan(
                text: presenter.currentUiState.nextPrayerTime ?? '--:--',
                style: TextStyle(
                  fontSize: twelvePx,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF282E29),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFB0C18C),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 6,
          width: MediaQuery.of(context).size.width *
              presenter.currentUiState.progressValue,
          decoration: BoxDecoration(
            color: const Color(0xFF6E833F),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingTime() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF282E29),
        ),
        children: [
          const TextSpan(text: 'Remaining: '),
          TextSpan(
            text: presenter.currentUiState.remainingTime ?? '00:00:00',
            style: TextStyle(fontSize: twelvePx, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        NextPrayerInfo(
          icon: AppImages.icTime,
          title: 'Next Prayer',
          time: presenter.currentUiState.nextPrayerTime ?? '--:--',
        ),
        SizedBox(width: twentyFourPx),
        const DateInfo(
          icon: AppImages.icDate,
          title: 'Date',
          date: 'Dhuʻl-Hijjah 26, 1445 AH',
        ),
      ],
    );
  }
}
