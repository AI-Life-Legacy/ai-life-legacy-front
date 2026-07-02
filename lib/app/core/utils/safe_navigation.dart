import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';

class SafeNavigation {
  const SafeNavigation._();

  static void back(
    BuildContext context, {
    Object? result,
    String fallbackRoute = Routes.home,
  }) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(result);
      return;
    }

    navigator.pushNamedAndRemoveUntil(fallbackRoute, (route) => false);
  }

  static void closeDialog(BuildContext context, {Object? result}) {
    Navigator.of(context, rootNavigator: true).pop(result);
  }
}
