import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/app_modal.dart';
import '../../core/widgets/image_cropper_stub.dart';
import '../../core/widgets/toast.dart';

class PublicFormController extends GetxController {
  final name = TextEditingController(text: 'Ganpat Dhameliya');
  final nameValue = 'Ganpat Dhameliya'.obs;
  final userImageBytes = Rxn<Uint8List>();

  final isGenerating = false.obs;
  final generatedBytes = Rxn<Uint8List>();

  @override
  void onInit() {
    super.onInit();
    name.addListener(() => nameValue.value = name.text);
  }

  @override
  void onClose() {
    name.dispose();
    super.onClose();
  }

  Future<void> pickUserImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    final file = result?.files.single;
    if (file?.bytes == null) return;
    final bytes = file!.bytes!;
    final cropped = await AppModal.show<Uint8List?>(
      title: 'Crop image',
      maxWidth: 520,
      child: ImageCropperStub(bytes: bytes),
    );
    if (cropped == null) return;
    userImageBytes.value = cropped;
  }

  Future<void> generate() async {
    isGenerating.value = true;
    generatedBytes.value = null;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    isGenerating.value = false;
    generatedBytes.value = userImageBytes.value; // demo placeholder
    Toast.success('Generated', 'Poster generated (demo).');
  }

  Future<void> download() async {
    Toast.success('Download', 'Download started (demo).');
  }
}
