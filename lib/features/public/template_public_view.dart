import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/responsive/screen_size.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../editor/models/editor_layer.dart';
import '../templates/template_model.dart';
import 'template_public_controller.dart';

class TemplatePublicView extends StatelessWidget {
  const TemplatePublicView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = (Get.parameters['id'] ?? '').trim();
    final c = Get.put(TemplatePublicController(templateId: id));
    final size = screenSizeOf(context);
    final pad = size == ScreenSize.mobile ? 14.0 : 18.0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(pad, 10, pad, pad),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: GlassCard(
                padding: const EdgeInsets.all(18),
                child: Obx(() {
                  if (id.isEmpty) {
                    return const EmptyState(title: 'Invalid link', message: 'Missing template id in URL.', icon: Icons.link_off);
                  }
                  if (c.isLoading.value) {
                    return const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()));
                  }
                  if (c.error.value != null) {
                    return EmptyState(title: 'Could not load template', message: c.error.value!, icon: Icons.error_outline);
                  }
                  final t = c.template.value;
                  if (t == null) return const EmptyState(title: 'Not found', message: 'Template not found.', icon: Icons.search_off);

                  final content = size == ScreenSize.mobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Header(title: t.title, ownerName: t.ownerName),
                            const SizedBox(height: 12),
                            _Preview(c: c, t: t),
                            const SizedBox(height: 14),
                            _Form(c: c, t: t),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _Preview(c: c, t: t)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _Header(title: t.title, ownerName: t.ownerName),
                                  const SizedBox(height: 12),
                                  _Form(c: c, t: t),
                                ],
                              ),
                            ),
                          ],
                        );

                  return content;
                }),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        final t = c.template.value;
        if (t == null) return const SizedBox.shrink();
        if (t.backgroundUrl != null) return const SizedBox.shrink();
        return Material(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              'Template background not saved yet. Open editor, click Save (after Storage rules allow upload), then generate link again.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.ownerName});
  final String title;
  final String ownerName;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.isEmpty ? 'Event Template' : title, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(
          ownerName.trim().isEmpty ? 'Fill your details to generate your poster.' : 'By $ownerName',
          style: tt.bodyMedium?.copyWith(color: tt.bodyMedium?.color?.withOpacity(0.75)),
        ),
      ],
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.c, required this.t});
  final TemplatePublicController c;
  final TemplateModel t;

  @override
  Widget build(BuildContext context) {
    final needsName = t.layers.any((l) => l.type == EditorLayerType.text && l.isPlaceholder);
    final needsImage = t.layers.any((l) => l.type == EditorLayerType.image && l.isPlaceholder);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (needsName) ...[
          TextField(
            controller: c.name,
            decoration: const InputDecoration(labelText: 'Your name', prefixIcon: Icon(Icons.badge_outlined)),
          ),
          const SizedBox(height: 12),
        ],
        if (needsImage) ...[
          Obx(
            () => AppButton.ghost(
              label: c.userImageBytes.value == null ? 'Upload profile image' : 'Change image',
              icon: Icons.photo_camera_outlined,
              expand: true,
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                final bytes = result?.files.single.bytes;
                if (bytes == null) return;
                await c.pickUserImage(bytes);
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (!needsName && !needsImage)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'No inputs required for this template.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75)),
            ),
          ),
        AppButton.primary(
          label: 'Download image',
          icon: Icons.download_outlined,
          expand: true,
          onPressed: c.downloadPosterPng,
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.c, required this.t});
  final TemplatePublicController c;
  final TemplateModel t;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Preview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        RepaintBoundary(
          key: c.previewKey,
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: t.backgroundUrl == null
                        ? (t.backgroundGradient.enabled
                            ? DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [t.backgroundGradient.color1, t.backgroundGradient.color2],
                                    transform: GradientRotation(t.backgroundGradient.angleDeg * 0.017453292519943295),
                                  ),
                                ),
                              )
                            : Container(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
                                child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 44)),
                              ))
                        : _Background(
                            url: t.backgroundUrl!,
                            fit: t.backgroundFit == 'cover' ? BoxFit.cover : BoxFit.contain,
                            matrix: t.backgroundMatrix,
                            rotationDeg: t.backgroundRotationDeg,
                          ),
                  ),
                  for (final layer in t.layers) _Layer(layer: layer, c: c),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({
    required this.url,
    required this.fit,
    required this.matrix,
    required this.rotationDeg,
  });

  final String url;
  final BoxFit fit;
  final List<double> matrix;
  final double rotationDeg;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Transform.rotate(
        angle: rotationDeg * 0.017453292519943295,
        alignment: Alignment.center,
        child: InteractiveViewer(
          transformationController: TransformationController(
            matrix.length == 16 ? Matrix4.fromList(matrix) : Matrix4.identity(),
          ),
          panEnabled: false,
          scaleEnabled: false,
          boundaryMargin: const EdgeInsets.all(60),
          minScale: 0.7,
          maxScale: 4.0,
          child: SizedBox.expand(
            child: Image.network(
              url,
              fit: fit,
              alignment: Alignment.center,
              errorBuilder: (context, error, stack) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      'Failed to load background.\n$url',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Layer extends StatelessWidget {
  const _Layer({required this.layer, required this.c});
  final EditorLayer layer;
  final TemplatePublicController c;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: layer.position.dx,
      top: layer.position.dy,
      width: layer.size.width,
      height: layer.size.height,
      child: Transform.rotate(
        angle: layer.rotationRadians,
        child: layer.type == EditorLayerType.text
            ? Center(
                child: Obx(
                  () => Text(
                    (layer.isPlaceholder ? (c.nameValue.value.isEmpty ? layer.text : c.nameValue.value) : layer.text),
                    textAlign: TextAlign.center,
                    style: layer.textStyle ?? const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            : Obx(() {
                if (layer.isPlaceholder) {
                  final Uint8List? bytes = c.userImageBytes.value;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(layer.cornerRadius),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        image: bytes == null ? null : DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover),
                      ),
                      child: bytes == null ? const Center(child: Icon(Icons.person_outline, size: 40)) : const SizedBox.shrink(),
                    ),
                  );
                }
                if (layer.imageUrl != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(layer.cornerRadius),
                    child: Image.network(layer.imageUrl!, fit: BoxFit.cover),
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(layer.cornerRadius),
                  child: Container(
                    color: Colors.white.withOpacity(0.10),
                    child: const Center(child: Icon(Icons.image_outlined)),
                  ),
                );
              }),
      ),
    );
  }
}
