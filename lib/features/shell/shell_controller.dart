import 'package:get/get.dart';

class ShellController extends GetxController {
  final index = 0.obs;
  final sidebarCollapsed = false.obs;

  void setIndex(int value) => index.value = value;
  void toggleSidebar() => sidebarCollapsed.toggle();
}

