import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/toast.dart';
import '../../core/utils/download_bytes.dart';
import '../templates/template_model.dart';
import '../templates/template_repository.dart';

class TemplatePublicController extends GetxController {
  TemplatePublicController({required this.templateId});

  final String templateId;
  final _repo = TemplateRepository();

  final isLoading = true.obs;
  final error = RxnString();
  final template = Rxn<TemplateModel>();

  final name = TextEditingController();
  final userImageBytes = Rxn<Uint8List>();
  final nameValue = ''.obs;

  final GlobalKey previewKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    name.addListener(() => nameValue.value = name.text);
    _load();
  }

  @override
  void onClose() {
    name.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    isLoading.value = true;
    error.value = null;
    try {
      template.value = await _repo.getById(templateId);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickUserImage(Uint8List bytes) async {
    userImageBytes.value = bytes;
  }

  Future<void> downloadPosterPng() async {
    try {
      final boundary = previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final png = byteData?.buffer.asUint8List();
      if (png == null) return;

      await downloadBytes(png, filename: 'poster.png', mimeType: 'image/png');

      Toast.success('Download', 'Poster downloaded.');
    } catch (e) {
      Toast.error('Download failed', e.toString());
    }
  }
}
