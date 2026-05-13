import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_theme.dart';
import '../features/settings/theme_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.put(ThemeController(), permanent: true);
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PosterGen',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: theme.mode.value,
        initialRoute: AppRoutes.onboarding,
        getPages: AppPages.pages,
      ),
    );
  }
}
