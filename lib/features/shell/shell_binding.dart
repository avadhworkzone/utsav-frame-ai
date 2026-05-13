import 'package:get/get.dart';

import '../editor/template_editor_controller.dart';
import 'shell_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(() => ShellController(), fenix: true);
    Get.lazyPut<TemplateEditorController>(() => TemplateEditorController(), fenix: true);
  }
}
