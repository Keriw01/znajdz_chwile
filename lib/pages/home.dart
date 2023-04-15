import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:znajdz_chwile/colors/colors.dart';
import 'package:znajdz_chwile/pages/settings.dart';
import 'package:znajdz_chwile/pages/stats.dart';
import 'package:znajdz_chwile/users/userPreferences/current_user.dart';

import 'home_second.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CurrentUser _rememberCurrentUser = Get.put(CurrentUser());

  final List<Widget> _pages = [
    const StatsPage(),
    const HomeSecond(),
    const SettingsPage()
  ];
  final List _navigationButtonProperties = [
    {
      "active_icon": FontAwesomeIcons.chartColumn,
      "non_active_icon": FontAwesomeIcons.chartColumn,
      "label": "Stats",
    },
    {
      "active_icon": FontAwesomeIcons.house,
      "non_active_icon": FontAwesomeIcons.house,
      "label": "Home",
    },
    {
      "active_icon": FontAwesomeIcons.gear,
      "non_active_icon": FontAwesomeIcons.gear,
      "label": "Settings",
    },
  ];

  final RxInt _indexNumber = 1.obs;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: CurrentUser(),
        initState: (currentState) {
          _rememberCurrentUser.getUserInfo();
        },
        builder: (controller) {
          return Scaffold(
              backgroundColor: color2,
              body: SafeArea(
                  child: Obx(
                () => _pages[_indexNumber.value],
              )),
              bottomNavigationBar: Obx(() => BottomNavigationBar(
                    backgroundColor: color2,
                    currentIndex: _indexNumber.value,
                    onTap: (value) {
                      _indexNumber.value = value;
                    },
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    selectedItemColor: color6,
                    unselectedItemColor: color4,
                    items: List.generate(3, (index) {
                      var navBtnProperty = _navigationButtonProperties[index];
                      return BottomNavigationBarItem(
                          backgroundColor: color2,
                          icon: Icon(
                            navBtnProperty["non_active_icon"],
                          ),
                          activeIcon: Icon(navBtnProperty["active_icon"]),
                          label: navBtnProperty["label"]);
                    }),
                  )),
              floatingActionButton: Obx(() => Visibility(
                    visible: _indexNumber.value == 1 ? true : false,
                    child: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: color6,
                      child: const Icon(
                        Icons.add,
                        size: 40,
                      ),
                    ),
                  )));
        });
  }
}
