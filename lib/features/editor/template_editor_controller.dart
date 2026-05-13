import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../core/widgets/toast.dart';
import '../../core/widgets/app_modal.dart';
import 'models/editor_layer.dart';
import 'share_link_dialog.dart';
import '../templates/template_model.dart';
import '../templates/template_repository.dart';

class TemplateEditorController extends GetxController {
  final _uuid = const Uuid();
  final _repo = TemplateRepository();

  final bgBytes = Rxn<Uint8List>();
  final bgUrl = RxnString();
  final bgTransform = TransformationController().obs;
  final bgFit = BoxFit.contain.obs;
  final bgEditMode = false.obs;
  final bgRotationDeg = 0.0.obs;
  final bgGradientEnabled = false.obs;
  final bgGradient1 = const Color(0xFF6C63FF).obs;
  final bgGradient2 = const Color(0xFF0F172A).obs;
  final bgGradientAngleDeg = 45.0.obs;
  final layers = <EditorLayer>[].obs;
  final selectedLayerId = RxnString();

  final zoom = 1.0.obs;
  final isBusy = false.obs;
  final templateId = RxnString();
  final title = TextEditingController();
  final creatorName = TextEditingController();
  final publishToMarketplace = false.obs;
  final category = TextEditingController();

  @override
  void onClose() {
    title.dispose();
    creatorName.dispose();
    category.dispose();
    bgTransform.value.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    creatorName.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
  }

  EditorLayer? get selectedLayer {
    final id = selectedLayerId.value;
    if (id == null) return null;
    for (final layer in layers) {
      if (layer.id == id) return layer;
    }
    return null;
  }

  Future<void> pickBackground() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = result?.files.single;
    if (file?.bytes == null) return;
    bgBytes.value = file!.bytes!;
    bgUrl.value = null;
    bgGradientEnabled.value = false;
    resetBackgroundAdjustments();
    Toast.success('Background added', 'You can now place layers.');
  }

  void resetBackgroundAdjustments() {
    bgTransform.value.value = Matrix4.identity();
    bgFit.value = BoxFit.contain;
    bgRotationDeg.value = 0;
    bgEditMode.value = false;
  }

  void toggleBgEditMode() => bgEditMode.toggle();

  void setBgFit(BoxFit fit) => bgFit.value = fit;

  void bgRotate(double deltaDeg) {
    bgRotationDeg.value = (bgRotationDeg.value + deltaDeg) % 360;
  }

  void bgNudge(Offset delta) {
    final m = bgTransform.value.value.clone();
    m.translate(delta.dx, delta.dy);
    bgTransform.value.value = m;
  }

  void bgZoom(double factor) {
    final m = bgTransform.value.value.clone();
    m.scale(factor, factor);
    bgTransform.value.value = m;
  }

  void addNameLayer() {
    layers.add(
      EditorLayer(
        id: _uuid.v4(),
        type: EditorLayerType.text,
        position: const Offset(80, 80),
        size: const Size(260, 56),
        text: 'Your Name',
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
        isPlaceholder: true,
      ),
    );
    selectedLayerId.value = layers.last.id;
  }

  void addTextLayer() {
    layers.add(
      EditorLayer(
        id: _uuid.v4(),
        type: EditorLayerType.text,
        position: const Offset(80, 90),
        size: const Size(300, 56),
        text: 'Text',
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        isPlaceholder: false,
      ),
    );
    selectedLayerId.value = layers.last.id;
  }

  Future<void> loadFromMarketplace(String marketplaceTemplateId) async {
    if (isBusy.value) return;
    isBusy.value = true;
    try {
      final t = await _repo.getById(marketplaceTemplateId);

      // Clone: user edits and saves as a new template.
      templateId.value = null;
      title.text = t.title.isEmpty ? 'Template' : t.title;
      creatorName.text = FirebaseAuth.instance.currentUser?.displayName ?? creatorName.text;
      publishToMarketplace.value = false;
      category.text = t.category ?? '';

      bgBytes.value = null;
      bgUrl.value = t.backgroundUrl;
      bgFit.value = t.backgroundFit == 'cover' ? BoxFit.cover : BoxFit.contain;
      bgTransform.value.value = Matrix4.fromList(t.backgroundMatrix);
      bgRotationDeg.value = t.backgroundRotationDeg;
      bgEditMode.value = false;

      bgGradientEnabled.value = t.backgroundGradient.enabled;
      bgGradient1.value = t.backgroundGradient.color1;
      bgGradient2.value = t.backgroundGradient.color2;
      bgGradientAngleDeg.value = t.backgroundGradient.angleDeg;

      layers.value = t.layers.map((e) => e.copy()).toList();
      selectedLayerId.value = null;

      Toast.success('Loaded', 'Template loaded. Customize and Save.');
    } catch (e) {
      Toast.error('Load failed', e.toString());
    } finally {
      isBusy.value = false;
    }
  }

  void toggleGradientBackground(bool enabled) {
    bgGradientEnabled.value = enabled;
    if (enabled) {
      bgBytes.value = null;
      bgUrl.value = null;
      resetBackgroundAdjustments();
    }
  }

  void setGradientAngle(double deg) => bgGradientAngleDeg.value = deg;

  Future<void> pickGradientColor1(BuildContext context) async {
    Color temp = bgGradient1.value;
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Gradient color 1'),
        content: SingleChildScrollView(
          child: ColorPicker(pickerColor: temp, onColorChanged: (c) => temp = c),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Get.back(result: true), child: const Text('Apply')),
        ],
      ),
    );
    if (ok == true) bgGradient1.value = temp;
  }

  Future<void> pickGradientColor2(BuildContext context) async {
    Color temp = bgGradient2.value;
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Gradient color 2'),
        content: SingleChildScrollView(
          child: ColorPicker(pickerColor: temp, onColorChanged: (c) => temp = c),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Get.back(result: true), child: const Text('Apply')),
        ],
      ),
    );
    if (ok == true) bgGradient2.value = temp;
  }

  void addImagePlaceholder() {
    layers.add(
      EditorLayer(
        id: _uuid.v4(),
        type: EditorLayerType.image,
        position: const Offset(80, 180),
        size: const Size(220, 260),
        isPlaceholder: true,
        cornerRadius: 22,
      ),
    );
    selectedLayerId.value = layers.last.id;
  }

  Future<void> addImageAsset() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;
    layers.add(
      EditorLayer(
        id: _uuid.v4(),
        type: EditorLayerType.image,
        position: const Offset(260, 120),
        size: const Size(160, 160),
        isPlaceholder: false,
        imageBytes: bytes,
        cornerRadius: 18,
      ),
    );
    selectedLayerId.value = layers.last.id;
  }

  Future<void> changeSelectedImage() async {
    final layer = selectedLayer;
    if (layer == null || layer.type != EditorLayerType.image) return;
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;
    layer.imageBytes = bytes;
    layer.imageUrl = null;
    layer.isPlaceholder = false;
    layers.refresh();
  }

  void select(EditorLayer layer) => selectedLayerId.value = layer.id;

  void deleteSelected() {
    final id = selectedLayerId.value;
    if (id == null) return;
    layers.removeWhere((e) => e.id == id);
    selectedLayerId.value = null;
  }

  void nudgeSelected(Offset delta) {
    final layer = selectedLayer;
    if (layer == null) return;
    layer.position += delta;
    layers.refresh();
  }

  void resizeSelected(Size size) {
    final layer = selectedLayer;
    if (layer == null) return;
    layer.size = size;
    layers.refresh();
  }

  void rotateSelected(double deltaDegrees) {
    final layer = selectedLayer;
    if (layer == null) return;
    layer.rotateBy(deltaDegrees);
    layers.refresh();
  }

  void updateText(String v) {
    final layer = selectedLayer;
    if (layer == null || layer.type != EditorLayerType.text) return;
    layer.text = v;
    layers.refresh();
  }

  void updateFontSize(double v) {
    final layer = selectedLayer;
    if (layer == null || layer.type != EditorLayerType.text) return;
    final style = layer.textStyle ?? const TextStyle();
    layer.textStyle = style.copyWith(fontSize: v);
    layers.refresh();
  }

  void updateFontWeight(FontWeight w) {
    final layer = selectedLayer;
    if (layer == null || layer.type != EditorLayerType.text) return;
    final style = layer.textStyle ?? const TextStyle();
    layer.textStyle = style.copyWith(fontWeight: w);
    layers.refresh();
  }

  void updateTextColor(Color color) {
    final layer = selectedLayer;
    if (layer == null || layer.type != EditorLayerType.text) return;
    final style = layer.textStyle ?? const TextStyle();
    layer.textStyle = style.copyWith(color: color);
    layers.refresh();
  }

  Future<void> pickTextColor(BuildContext context) async {
    final layer = selectedLayer;
    if (layer == null || layer.type != EditorLayerType.text) return;
    final current = (layer.textStyle?.color) ?? Colors.white;
    Color temp = current;
    await Get.dialog(
      AlertDialog(
        title: const Text('Pick text color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: current,
            onColorChanged: (c) => temp = c,
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(onPressed: () => Get.back(result: true), child: const Text('Apply')),
        ],
      ),
    );
    updateTextColor(temp);
  }

  Future<void> saveTemplate() async {
    if (isBusy.value) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Toast.error('Login required', 'Please sign in with Google to save templates.');
      return;
    }
    isBusy.value = true;
    try {
      final currentId = templateId.value;
      final trimmedTitle = title.text.trim();
      if (trimmedTitle.isEmpty) {
        Toast.error('Template title required', 'Enter your event/template name before saving.');
        return;
      }
      if (bgBytes.value == null && this.bgUrl.value == null && bgGradientEnabled.value == false) {
        Toast.error('Background required', 'Upload a background image, use a gradient, or pick a marketplace template.');
        return;
      }

      final bgMatrix = bgTransform.value.value.storage.toList();
      final bgFitStr = bgFit.value.name;
      final gradientMap = BackgroundGradient(
        enabled: bgGradientEnabled.value,
        color1: bgGradient1.value,
        color2: bgGradient2.value,
        angleDeg: bgGradientAngleDeg.value,
      ).toMap();

      // Upload any non-placeholder image layers (logos/assets) and store their URLs.
      for (final layer in layers) {
        if (layer.type == EditorLayerType.image && layer.isPlaceholder == false && layer.imageBytes != null) {
          // Ensure template id exists before uploading layer assets.
          // If we don't have an id yet, create one first.
          if (templateId.value == null) {
            final nowId = await _repo.upsert(
              templateId: null,
              title: trimmedTitle,
              ownerName: creatorName.text.trim(),
              backgroundUrl: null,
              backgroundFit: bgFitStr,
              backgroundMatrix: bgMatrix,
              backgroundRotationDeg: bgRotationDeg.value,
              backgroundGradient: gradientMap,
              isPublic: publishToMarketplace.value,
              category: category.text.trim().isEmpty ? null : category.text.trim(),
              layersAsMaps: const [],
            );
            templateId.value = nowId;
          }
          final idForUpload = templateId.value!;
          final url = await _repo.uploadLayerImageBytes(
            templateId: idForUpload,
            layerId: layer.id,
            bytes: layer.imageBytes!,
          );
          layer.imageUrl = url;
          layer.imageBytes = null; // reduce payload; persist via URL
        }
      }

      final layersMaps = layers.map(TemplateModel.layerToMap).toList();
      String? uploadedBgUrl;
      final bytes = bgBytes.value;
      final existingBgUrl = this.bgUrl.value;

      final newId = await _repo.upsert(
        templateId: currentId,
        title: trimmedTitle,
        ownerName: creatorName.text.trim(),
        backgroundUrl: existingBgUrl,
        backgroundFit: bgFitStr,
        backgroundMatrix: bgMatrix,
        backgroundRotationDeg: bgRotationDeg.value,
        backgroundGradient: gradientMap,
        isPublic: publishToMarketplace.value,
        category: category.text.trim().isEmpty ? null : category.text.trim(),
        layersAsMaps: layersMaps,
      );
      templateId.value = newId;

      if (bytes != null) {
        try {
          uploadedBgUrl = await _repo.uploadBackgroundBytes(templateId: newId, bytes: bytes);
        } on FirebaseException catch (e) {
          Toast.error('Background upload failed', '${e.code}: ${e.message ?? e.toString()}');
        }
        if (uploadedBgUrl == null) {
          Toast.error('Save incomplete', 'Background URL not generated. Check Storage bucket and rules, then Save again.');
        }
        this.bgUrl.value = uploadedBgUrl;
        await _repo.upsert(
          templateId: newId,
          title: trimmedTitle,
          ownerName: creatorName.text.trim(),
          backgroundUrl: uploadedBgUrl,
          backgroundFit: bgFitStr,
          backgroundMatrix: bgMatrix,
          backgroundRotationDeg: bgRotationDeg.value,
          backgroundGradient: gradientMap,
          isPublic: publishToMarketplace.value,
          category: category.text.trim().isEmpty ? null : category.text.trim(),
          layersAsMaps: layersMaps,
        );
      }

      Toast.success('Saved', 'Template saved.');
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        Toast.error(
          'Save failed',
          'Firestore is unavailable/offline. Check your internet, and ensure Firestore is enabled in Firebase Console.',
        );
      } else if (e.code == 'permission-denied') {
        Toast.error(
          'Save failed',
          'Permission denied. Update Firestore rules to allow the signed-in user to write templates.',
        );
      } else {
        Toast.error('Save failed', '${e.code}: ${e.message ?? e.toString()}');
      }
    } catch (e) {
      Toast.error('Save failed', e.toString());
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> generateLink() async {
    if (templateId.value == null) {
      await saveTemplate();
    }
    final id = templateId.value;
    if (id == null) return;
    final origin = Uri.base.origin;
    final link = '$origin/#/t/$id';
    await AppModal.show(
      title: 'Share link',
      maxWidth: 640,
      child: ShareLinkDialog(link: link),
    );
  }
}
