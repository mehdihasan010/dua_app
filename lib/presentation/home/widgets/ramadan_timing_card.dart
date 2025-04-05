import 'package:dua/core/config/app_images.dart';
import 'package:dua/core/config/dua_color.dart';
import 'package:dua/core/config/dua_screen.dart';
import 'package:dua/core/utility/utility.dart';
import 'package:dua/core/external_libs/presentable_widget_builder.dart';
import 'package:dua/presentation/home/presenter/home_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RamadanTimingCard extends StatelessWidget {
  final HomePresenter presenter;

  const RamadanTimingCard({
    super.key,
    required this.presenter,
  });

  @override
  Widget build(BuildContext context) {
    return PresentableWidgetBuilder<HomePresenter>(
        presenter: presenter,
        builder: () {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DuaColor.shadeColorLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeWithIcon(
                  title: 'Sehri',
                  time: presenter.currentUiState.sehriTime ?? '04:45 AM',
                  hasNotification: true,
                  alignment: MainAxisAlignment.start,
                  context: context,
                ),
                _buildTimeWithIcon(
                  title: 'Iftar',
                  time: presenter.currentUiState.iftarTime ?? '06:00 PM',
                  hasNotification: true,
                  alignment: MainAxisAlignment.end,
                  context: context,
                ),
              ],
            ),
          );
        });
  }

  Widget _buildTimeWithIcon({
    required String title,
    required String time,
    required bool hasNotification,
    required MainAxisAlignment alignment,
    required BuildContext context,
  }) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        Container(
          margin: EdgeInsets.only(right: sixteenPx),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: DuaColor.iconShadeColorLight,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            hasNotification
                ? AppImages.icNotification
                : AppImages.icNotification,
            width: twentyFourPx,
            height: twentyFourPx,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: twelvePx,
                fontWeight: FontWeight.w500,
                color: context.color.headingTextColor,
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: time,
                    style: TextStyle(
                      fontSize: eighteenPx,
                      fontWeight: FontWeight.w600,
                      color: context.color.headingTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
