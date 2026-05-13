import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/responsive/screen_size.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/upload_tile.dart';
import 'models/editor_layer.dart';
import 'template_editor_controller.dart';

class TemplateEditorView extends StatelessWidget {
  const TemplateEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TemplateEditorController>();
    final size = screenSizeOf(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      child: switch (size) {
        ScreenSize.mobile => _MobileEditor(c: c),
        ScreenSize.tablet => _TabletEditor(c: c),
        ScreenSize.desktop => Row(
            children: [
              SizedBox(width: 300, child: _LayersPanel(c: c)),
              const SizedBox(width: 12),
              Expanded(child: _Canvas(c: c)),
              const SizedBox(width: 12),
              SizedBox(width: 340, child: _PropertiesPanel(c: c)),
            ],
          ),
      },
    );
  }
}

class _TabletEditor extends StatelessWidget {
  const _TabletEditor({required this.c});
  final TemplateEditorController c;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        drawer: Drawer(
          width: 360,
          child: SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: _LayersPanel(c: c))),
        ),
        endDrawer: Drawer(
          width: 380,
          child: SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: _PropertiesPanel(c: c))),
        ),
        body: Column(
          children: [
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Layers',
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.layers_outlined),
                  ),
                  IconButton(
                    tooltip: 'Properties',
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: const Icon(Icons.tune),
                  ),
                  const Spacer(),
                  Obx(
                    () => AppButton.primary(
                      label: c.isBusy.value ? 'Saving...' : 'Save',
                      icon: Icons.save_outlined,
                      onPressed: c.isBusy.value ? null : c.saveTemplate,
                      expand: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _Canvas(c: c)),
          ],
        ),
      ),
    );
  }
}

class _MobileEditor extends StatelessWidget {
  const _MobileEditor({required this.c});
  final TemplateEditorController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MobileToolbar(c: c),
        const SizedBox(height: 12),
        Expanded(child: _Canvas(c: c)),
      ],
    );
  }
}

class _MobileToolbar extends StatelessWidget {
  const _MobileToolbar({required this.c});
  final TemplateEditorController c;

  @override
  Widget build(BuildContext context) {
    void openSheet(Widget child) {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.74,
            child: child,
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(onPressed: c.pickBackground, icon: const Icon(Icons.photo_library_outlined)),
          IconButton(onPressed: c.toggleBgEditMode, icon: const Icon(Icons.open_with_outlined)),
          IconButton(onPressed: c.addNameLayer, icon: const Icon(Icons.text_fields)),
          IconButton(onPressed: c.addTextLayer, icon: const Icon(Icons.title_outlined)),
          IconButton(onPressed: c.addImagePlaceholder, icon: const Icon(Icons.account_circle_outlined)),
          const Spacer(),
          IconButton(
            tooltip: 'Layers',
            onPressed: () => openSheet(_LayersPanel(c: c)),
            icon: const Icon(Icons.layers_outlined),
          ),
          IconButton(
            tooltip: 'Properties',
            onPressed: () => openSheet(_PropertiesPanel(c: c)),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
    );
  }
}

class _LayersPanel extends StatelessWidget {
  const _LayersPanel({required this.c});
  final TemplateEditorController c;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          Text('Layers', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          TextField(
            controller: c.title,
            decoration: const InputDecoration(
              labelText: 'Template title',
              hintText: 'e.g. Event Invitation',
              prefixIcon: Icon(Icons.edit_outlined),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: c.creatorName,
            decoration: const InputDecoration(
              labelText: 'Organizer / Creator name',
              hintText: 'Shown on public form',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => SwitchListTile(
              value: c.publishToMarketplace.value,
              onChanged: (v) => c.publishToMarketplace.value = v,
              title: const Text('Publish to Marketplace'),
              subtitle: const Text('Make this template discoverable by others.'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: c.category,
            decoration: const InputDecoration(
              labelText: 'Category (optional)',
              hintText: 'Birthday / Seminar / Festival...',
              prefixIcon: Icon(Icons.category_outlined),
            ),
          ),
          const SizedBox(height: 12),
          UploadTile(
            title: 'Upload background poster',
            subtitle: 'Recommended: 1080×1350 (4:5). PNG/JPG supported.',
            icon: Icons.image_outlined,
            onTap: c.pickBackground,
            trailing: Obx(
              () => IconButton(
                tooltip: c.bgEditMode.value ? 'Done' : 'Adjust background',
                onPressed: c.bgBytes.value == null ? null : c.toggleBgEditMode,
                icon: Icon(c.bgEditMode.value ? Icons.check_circle_outline : Icons.tune),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => SwitchListTile(
              value: c.bgGradientEnabled.value,
              onChanged: c.toggleGradientBackground,
              title: const Text('Use gradient background'),
              subtitle: const Text('Use a brand gradient instead of an image.'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Obx(() {
            if (!c.bgGradientEnabled.value) return const SizedBox.shrink();
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppButton.ghost(
                        label: 'Color 1',
                        icon: Icons.palette_outlined,
                        onPressed: () => c.pickGradientColor1(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton.ghost(
                        label: 'Color 2',
                        icon: Icons.palette_outlined,
                        onPressed: () => c.pickGradientColor2(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Obx(
                  () => _SliderRow(
                    label: 'Gradient angle',
                    value: c.bgGradientAngleDeg.value,
                    min: 0,
                    max: 360,
                    onChanged: c.setGradientAngle,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton.ghost(label: 'Name', icon: Icons.text_fields, onPressed: c.addNameLayer),
              AppButton.ghost(label: 'Text', icon: Icons.title_outlined, onPressed: c.addTextLayer),
              AppButton.ghost(label: 'Image', icon: Icons.account_circle_outlined, onPressed: c.addImagePlaceholder),
              AppButton.ghost(label: 'Logo', icon: Icons.image_outlined, onPressed: c.addImageAsset),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (c.layers.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: EmptyState(
                  title: 'No layers yet',
                  message: 'Add a text layer or an image placeholder. Drag to position on the canvas.',
                  icon: Icons.layers_outlined,
                ),
              );
            }

            final layers = c.layers.reversed.toList(growable: false);
            return Column(
              children: [
                for (final layer in layers) ...[
                  InkWell(
                    onTap: () => c.select(layer),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: c.selectedLayerId.value == layer.id
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.14)
                            : Colors.transparent,
                        border: Border.all(
                          color: c.selectedLayerId.value == layer.id
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.32)
                              : Theme.of(context).dividerColor.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(layer.type == EditorLayerType.text ? Icons.text_fields : Icons.account_circle_outlined),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              layer.type == EditorLayerType.text
                                  ? (layer.isPlaceholder ? 'Name placeholder' : 'Text')
                                  : (layer.isPlaceholder ? 'User image placeholder' : 'Image asset'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.drag_indicator, color: Theme.of(context).iconTheme.color?.withOpacity(0.70)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          }),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Obx(() => AppButton.ghost(label: 'Delete', icon: Icons.delete_outline, onPressed: c.selectedLayerId.value == null ? null : c.deleteSelected))),
              const SizedBox(width: 10),
              Expanded(child: Obx(() => GradientButton(label: 'Save', icon: Icons.save_outlined, loading: c.isBusy.value, onPressed: c.saveTemplate))),
            ],
          ),
          const SizedBox(height: 10),
          Obx(
            () => GradientButton(
              label: 'Generate share link',
              icon: Icons.link,
              expand: true,
              loading: c.isBusy.value,
              onPressed: c.generateLink,
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Canvas extends StatelessWidget {
  const _Canvas({required this.c});
  final TemplateEditorController c;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Canvas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const Spacer(),
              IconButton(
                tooltip: 'Zoom out',
                onPressed: () => c.zoom.value = (c.zoom.value - 0.1).clamp(0.6, 1.6),
                icon: const Icon(Icons.remove),
              ),
              Obx(() => Text('${(c.zoom.value * 100).round()}%')),
              IconButton(
                tooltip: 'Zoom in',
                onPressed: () => c.zoom.value = (c.zoom.value + 0.1).clamp(0.6, 1.6),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.25)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Obx(
                      () => Transform.scale(
                        scale: c.zoom.value,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: AppColors.brandGradient(opacity: 0.12),
                                ),
                                child: c.bgBytes.value == null && c.bgUrl.value == null && c.bgGradientEnabled.value == false
                                    ? const Center(child: _DropHint())
                                    : ClipRect(
                                        child: Obx(
                                          () => Transform.rotate(
                                            angle: c.bgRotationDeg.value * 0.017453292519943295,
                                            alignment: Alignment.center,
                                            child: InteractiveViewer(
                                              transformationController: c.bgTransform.value,
                                              panEnabled: c.bgEditMode.value,
                                              scaleEnabled: c.bgEditMode.value,
                                              minScale: 0.7,
                                              maxScale: 4.0,
                                              boundaryMargin: const EdgeInsets.all(60),
                                              child: SizedBox.expand(
                                                child: c.bgGradientEnabled.value
                                                    ? DecoratedBox(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment.topLeft,
                                                            end: Alignment.bottomRight,
                                                            colors: [c.bgGradient1.value, c.bgGradient2.value],
                                                            transform: GradientRotation(c.bgGradientAngleDeg.value * 0.017453292519943295),
                                                          ),
                                                        ),
                                                      )
                                                    : (c.bgBytes.value != null
                                                        ? Image.memory(
                                                            c.bgBytes.value!,
                                                            fit: c.bgFit.value,
                                                            alignment: Alignment.center,
                                                          )
                                                        : Image.network(
                                                            c.bgUrl.value!,
                                                            fit: c.bgFit.value,
                                                            alignment: Alignment.center,
                                                            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined)),
                                                          )),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            for (final layer in c.layers) _LayerWidget(c: c, layer: layer),
                            if (c.bgEditMode.value)
                              Positioned(
                                left: 12,
                                top: 12,
                                    child: GlassCard(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      radius: 18,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.open_with_outlined, size: 18),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Background edit',
                                              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                                            ),
                                            const SizedBox(width: 10),
                                            DropdownButton<BoxFit>(
                                              value: c.bgFit.value,
                                              onChanged: (v) => v == null ? null : c.setBgFit(v),
                                              items: const [
                                                DropdownMenuItem(value: BoxFit.contain, child: Text('Fit')),
                                                DropdownMenuItem(value: BoxFit.cover, child: Text('Fill')),
                                              ],
                                            ),
                                            const SizedBox(width: 6),
                                            IconButton(
                                              tooltip: 'Rotate left',
                                              onPressed: () => c.bgRotate(-5),
                                              icon: const Icon(Icons.rotate_left, size: 18),
                                            ),
                                            IconButton(
                                              tooltip: 'Rotate right',
                                              onPressed: () => c.bgRotate(5),
                                              icon: const Icon(Icons.rotate_right, size: 18),
                                            ),
                                            const SizedBox(width: 6),
                                            IconButton(
                                              tooltip: 'Left',
                                              onPressed: () => c.bgNudge(const Offset(-8, 0)),
                                              icon: const Icon(Icons.keyboard_arrow_left, size: 18),
                                            ),
                                            IconButton(
                                              tooltip: 'Right',
                                              onPressed: () => c.bgNudge(const Offset(8, 0)),
                                              icon: const Icon(Icons.keyboard_arrow_right, size: 18),
                                            ),
                                            IconButton(
                                              tooltip: 'Up',
                                              onPressed: () => c.bgNudge(const Offset(0, -8)),
                                              icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                                            ),
                                            IconButton(
                                              tooltip: 'Down',
                                              onPressed: () => c.bgNudge(const Offset(0, 8)),
                                              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                            ),
                                            IconButton(
                                              tooltip: 'Zoom in',
                                              onPressed: () => c.bgZoom(1.05),
                                              icon: const Icon(Icons.add, size: 18),
                                            ),
                                            IconButton(
                                              tooltip: 'Zoom out',
                                              onPressed: () => c.bgZoom(0.95),
                                              icon: const Icon(Icons.remove, size: 18),
                                            ),
                                            const SizedBox(width: 6),
                                            IconButton(
                                              tooltip: 'Reset',
                                              onPressed: c.resetBackgroundAdjustments,
                                              icon: const Icon(Icons.refresh, size: 18),
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              tooltip: 'Done',
                                              onPressed: c.toggleBgEditMode,
                                              icon: const Icon(Icons.check, size: 18),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tip: Drag layers to position. Use Properties to fine tune size, rotation, fonts and colors.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75),
                ),
          ),
        ],
      ),
    );
  }
}

class _DropHint extends StatelessWidget {
  const _DropHint();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_upload_outlined, size: 34),
        const SizedBox(height: 8),
        Text('Upload a poster background', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Then add placeholders (name / photo).', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _LayerWidget extends StatelessWidget {
  const _LayerWidget({required this.c, required this.layer});
  final TemplateEditorController c;
  final EditorLayer layer;

  @override
  Widget build(BuildContext context) {
    final selected = c.selectedLayerId.value == layer.id;
    final border = selected ? AppColors.primary : Colors.transparent;
    final borderAlpha = selected ? 0.9 : 0.0;

    return Positioned(
      left: layer.position.dx,
      top: layer.position.dy,
      width: layer.size.width,
      height: layer.size.height,
      child: GestureDetector(
        onTap: () => c.select(layer),
        onPanUpdate: (d) {
          layer.position += d.delta;
          c.layers.refresh();
        },
        child: Transform.rotate(
          angle: layer.rotationRadians,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(layer.type == EditorLayerType.image ? layer.cornerRadius : 16),
              border: Border.all(color: border.withOpacity(borderAlpha), width: 2),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                layer.type == EditorLayerType.text ? _TextLayer(layer: layer) : _ImageLayer(layer: layer),
                if (selected)
                  ..._handles(layer, c),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _handles(EditorLayer layer, TemplateEditorController c) {
    Widget dot({required double left, required double top, required void Function(DragUpdateDetails) onPan}) {
      return Positioned(
        left: left,
        top: top,
        child: GestureDetector(
          onPanUpdate: onPan,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.92), width: 2),
            ),
          ),
        ),
      );
    }

    void setRect({double? left, double? top, double? width, double? height}) {
      final newLeft = left ?? layer.position.dx;
      final newTop = top ?? layer.position.dy;
      final newW = (width ?? layer.size.width).clamp(40.0, 2000.0);
      final newH = (height ?? layer.size.height).clamp(40.0, 2000.0);
      layer.position = Offset(newLeft, newTop);
      layer.size = Size(newW, newH);
      c.layers.refresh();
    }

    return [
      // rotation handle (top center)
      Positioned(
        left: layer.size.width / 2 - 10,
        top: -34,
        child: GestureDetector(
          onPanUpdate: (d) => c.rotateSelected(d.delta.dx),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.85)),
            ),
            child: const Icon(Icons.rotate_right, size: 14, color: Colors.white),
          ),
        ),
      ),
      // corners
      dot(
        left: -8,
        top: -8,
        onPan: (d) => setRect(
          left: layer.position.dx + d.delta.dx,
          top: layer.position.dy + d.delta.dy,
          width: layer.size.width - d.delta.dx,
          height: layer.size.height - d.delta.dy,
        ),
      ),
      dot(
        left: layer.size.width - 8,
        top: -8,
        onPan: (d) => setRect(
          top: layer.position.dy + d.delta.dy,
          width: layer.size.width + d.delta.dx,
          height: layer.size.height - d.delta.dy,
        ),
      ),
      dot(
        left: -8,
        top: layer.size.height - 8,
        onPan: (d) => setRect(
          left: layer.position.dx + d.delta.dx,
          width: layer.size.width - d.delta.dx,
          height: layer.size.height + d.delta.dy,
        ),
      ),
      dot(
        left: layer.size.width - 8,
        top: layer.size.height - 8,
        onPan: (d) => setRect(
          width: layer.size.width + d.delta.dx,
          height: layer.size.height + d.delta.dy,
        ),
      ),
      // mid-sides
      dot(
        left: layer.size.width / 2 - 8,
        top: -8,
        onPan: (d) => setRect(
          top: layer.position.dy + d.delta.dy,
          height: layer.size.height - d.delta.dy,
        ),
      ),
      dot(
        left: layer.size.width / 2 - 8,
        top: layer.size.height - 8,
        onPan: (d) => setRect(height: layer.size.height + d.delta.dy),
      ),
      dot(
        left: -8,
        top: layer.size.height / 2 - 8,
        onPan: (d) => setRect(
          left: layer.position.dx + d.delta.dx,
          width: layer.size.width - d.delta.dx,
        ),
      ),
      dot(
        left: layer.size.width - 8,
        top: layer.size.height / 2 - 8,
        onPan: (d) => setRect(width: layer.size.width + d.delta.dx),
      ),
    ];
  }
}

class _TextLayer extends StatelessWidget {
  const _TextLayer({required this.layer});
  final EditorLayer layer;

  @override
  Widget build(BuildContext context) {
    final style = layer.textStyle ??
        TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        );
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          layer.text,
          textAlign: TextAlign.center,
          style: style,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _ImageLayer extends StatelessWidget {
  const _ImageLayer({required this.layer});
  final EditorLayer layer;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(layer.cornerRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.10 : 0.06),
          borderRadius: BorderRadius.circular(layer.cornerRadius),
        ),
        child: layer.isPlaceholder
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline, size: 34, color: Theme.of(context).iconTheme.color?.withOpacity(0.80)),
                    const SizedBox(height: 8),
                    Text(
                      'User photo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.78),
                          ),
                    ),
                  ],
                ),
              )
            : (layer.imageBytes != null
                ? Image.memory(layer.imageBytes!, fit: BoxFit.cover)
                : (layer.imageUrl != null ? Image.network(layer.imageUrl!, fit: BoxFit.cover) : const SizedBox.shrink())),
      ),
    );
  }
}

class _PropertiesPanel extends StatelessWidget {
  const _PropertiesPanel({required this.c});
  final TemplateEditorController c;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Obx(() {
        final layer = c.selectedLayer;
        if (layer == null) {
          return const EmptyState(
            title: 'Select a layer',
            message: 'Tap a layer on canvas to edit properties: size, rotation, font & colors.',
            icon: Icons.tune,
          );
        }
        return ListView(
          children: [
            Row(
              children: [
                Text('Properties', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const Spacer(),
                IconButton(onPressed: c.deleteSelected, icon: const Icon(Icons.delete_outline)),
              ],
            ),
            const SizedBox(height: 10),
            _SectionTitle(icon: layer.type == EditorLayerType.text ? Icons.text_fields : Icons.account_circle_outlined, title: layer.type == EditorLayerType.text ? 'Text layer' : 'Image placeholder'),
            const SizedBox(height: 12),
            Text(
              'Resize on canvas using handles (corners/sides).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75)),
            ),
            const SizedBox(height: 10),
            _SliderRow(
              label: 'Rotate',
              value: layer.rotation,
              min: 0,
              max: 360,
              onChanged: (v) {
                layer.rotation = v;
                c.layers.refresh();
              },
            ),
            const SizedBox(height: 12),
            if (layer.type == EditorLayerType.text) ...[
              Text('Text', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: layer.text,
                decoration: const InputDecoration(
                  hintText: 'Placeholder',
                  prefixIcon: Icon(Icons.text_fields),
                ),
                onChanged: c.updateText,
              ),
              const SizedBox(height: 12),
              _SliderRow(
                label: 'Font size',
                value: (layer.textStyle?.fontSize ?? 24),
                min: 10,
                max: 64,
                onChanged: c.updateFontSize,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AppButton.ghost(
                      label: 'Color',
                      icon: Icons.palette_outlined,
                      onPressed: () => c.pickTextColor(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<FontWeight>(
                      value: layer.textStyle?.fontWeight ?? FontWeight.w800,
                      items: const [
                        DropdownMenuItem(value: FontWeight.w400, child: Text('Regular')),
                        DropdownMenuItem(value: FontWeight.w600, child: Text('SemiBold')),
                        DropdownMenuItem(value: FontWeight.w700, child: Text('Bold')),
                        DropdownMenuItem(value: FontWeight.w800, child: Text('ExtraBold')),
                      ],
                      onChanged: (v) => v == null ? null : c.updateFontWeight(v),
                      decoration: const InputDecoration(labelText: 'Weight'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              _SliderRow(
                label: 'Corner radius',
                value: layer.cornerRadius,
                min: 0,
                max: 80,
                onChanged: (v) {
                  layer.cornerRadius = v;
                  c.layers.refresh();
                },
              ),
              const SizedBox(height: 10),
              if (!layer.isPlaceholder)
                AppButton.ghost(
                  label: 'Change image',
                  icon: Icons.photo_library_outlined,
                  onPressed: c.changeSelectedImage,
                ),
            ],
            const SizedBox(height: 16),
            Text(
              'Position (fine tune)',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Mini(icon: Icons.keyboard_arrow_up, onTap: () => c.nudgeSelected(const Offset(0, -2))),
                _Mini(icon: Icons.keyboard_arrow_down, onTap: () => c.nudgeSelected(const Offset(0, 2))),
                _Mini(icon: Icons.keyboard_arrow_left, onTap: () => c.nudgeSelected(const Offset(-2, 0))),
                _Mini(icon: Icons.keyboard_arrow_right, onTap: () => c.nudgeSelected(const Offset(2, 0))),
                _Mini(icon: Icons.rotate_left, onTap: () => c.rotateSelected(-3)),
                _Mini(icon: Icons.rotate_right, onTap: () => c.rotateSelected(3)),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient(opacity: 0.85),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.tune, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900))),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.labelLarge)),
            Text(value.toStringAsFixed(0)),
          ],
        ),
        Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 46,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.35)),
        ),
        child: Icon(icon),
      ),
    );
  }
}
