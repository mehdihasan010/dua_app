import 'package:dua/core/config/app_images.dart';
import 'package:dua/core/di/service_locator.dart';
import 'package:dua/core/static/constants.dart';
import 'package:dua/core/static/ui_const.dart';
import 'package:dua/presentation/common/widgets/custom_app_bar.dart';
import 'package:dua/presentation/home/presenter/home_presenter.dart';
import 'package:dua/presentation/home/widgets/tab_content.dart';
import 'package:dua/presentation/home/widgets/prayer_card.dart';
import 'package:dua/presentation/home/widgets/quick_access_menu.dart';
import 'package:dua/presentation/home/widgets/tab_bar.dart';
import 'package:dua/presentation/home/widgets/ramadan_timing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomePresenter presenter = locate<HomePresenter>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          title: duaTitle,
          centerTitle: true,
          icon: AppImages.icCategory2,
          actions: [
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(AppImages.icSearch),
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: paddingH16,
                  child: Column(
                    children: [
                      PrayerCard(theme: theme, presenter: presenter),
                      gapH16,
                      RamadanTimingCard(
                        presenter: presenter,
                      ),
                      gapH32,
                      QuickAccessMenu(),
                      gapH16,
                    ],
                  ),
                ),
              ),
              TabBarSection(),
            ];
          },
          body: TabBarView(
            children: [
              TabContent(),
              TabContent(),
            ],
          ),
        ),
      ),
    );
  }
}
