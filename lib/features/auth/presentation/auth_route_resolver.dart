import 'package:flutter/widgets.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/screens/home_screen.dart';
import 'package:swim/screens/parent_dashboard_screen.dart';
import 'package:swim/screens/swimmer_dashboard_screen.dart';

Widget dashboardForRole(String role) {
  switch (role) {
    case AppRoles.coach:
      return const HomeScreen();
    case AppRoles.parent:
      return const ParentDashboardScreen();
    case AppRoles.swimmer:
      return const SwimmerDashboardScreen();
    default:
      return const ParentDashboardScreen();
  }
}
